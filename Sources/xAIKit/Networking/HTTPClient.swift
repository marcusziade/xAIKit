import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import AsyncHTTPClient
import NIO
import NIOFoundationCompat
import NIOHTTP1

/// Protocol for HTTP client implementations
public protocol HTTPClientProtocol {
    func sendRequest<T: Decodable>(_ request: HTTPRequest) async throws -> T
    func sendStreamingRequest(_ request: HTTPRequest) async throws -> AsyncThrowingStream<StreamEvent, Error>
}

/// HTTP request configuration
public struct HTTPRequest {
    public let method: HTTPMethod
    public let url: URL
    public let headers: [String: String]
    public let body: Data?
    public let timeoutInterval: TimeInterval
    
    public init(
        method: HTTPMethod,
        url: URL,
        headers: [String: String] = [:],
        body: Data? = nil,
        timeoutInterval: TimeInterval = 60
    ) {
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
        self.timeoutInterval = timeoutInterval
    }
}

/// HTTP methods
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

/// Events received during streaming
public enum StreamEvent {
    case data(Data)
    case done
}

/// Main HTTP client implementation
public final class xAIHTTPClient: HTTPClientProtocol {
    private let configuration: xAIConfiguration
    private let asyncHTTPClient: AsyncHTTPClient.HTTPClient
    
    public init(configuration: xAIConfiguration) {
        self.configuration = configuration
        
        // Configure AsyncHTTPClient
        var clientConfig = AsyncHTTPClient.HTTPClient.Configuration()
        clientConfig.timeout = .init(
            connect: .seconds(10),
            read: .seconds(Int64(configuration.timeoutInterval))
        )
        
        self.asyncHTTPClient = AsyncHTTPClient.HTTPClient(
            eventLoopGroupProvider: .singleton,
            configuration: clientConfig
        )
    }
    
    deinit {
        try? asyncHTTPClient.syncShutdown()
    }
    
    public func sendRequest<T: Decodable>(_ request: HTTPRequest) async throws -> T {
        #if os(macOS) && !targetEnvironment(macCatalyst)
        // Use URLSession on macOS for non-streaming requests
        if !configuration.useStreaming {
            return try await sendRequestWithURLSession(request)
        }
        #endif
        
        // Use AsyncHTTPClient for Linux and streaming
        return try await sendRequestWithAsyncHTTPClient(request)
    }
    
    public func sendStreamingRequest(_ request: HTTPRequest) async throws -> AsyncThrowingStream<StreamEvent, Error> {
        // Always use AsyncHTTPClient for streaming
        return try await sendStreamingRequestWithAsyncHTTPClient(request)
    }
    
    #if os(macOS) && !targetEnvironment(macCatalyst)
    private func sendRequestWithURLSession<T: Decodable>(_ request: HTTPRequest) async throws -> T {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        urlRequest.timeoutInterval = request.timeoutInterval
        
        // Set headers
        urlRequest.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("xAIKit/\(xAIKit.version)", forHTTPHeaderField: "User-Agent")
        
        for (key, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        for (key, value) in configuration.customHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw xAIError.invalidResponse
        }
        
        if httpResponse.statusCode == 429 {
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
            throw xAIError.rateLimitExceeded(retryAfter: retryAfter)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw xAIError.apiError(
                    statusCode: httpResponse.statusCode,
                    message: errorResponse.error.message
                )
            }
            // Try to get raw error message
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw xAIError.apiError(
                statusCode: httpResponse.statusCode,
                message: errorMessage
            )
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw xAIError.decodingError(error)
        }
    }
    #endif
    
    private func sendRequestWithAsyncHTTPClient<T: Decodable>(_ request: HTTPRequest) async throws -> T {
        var headers = NIOHTTP1.HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(configuration.apiKey)")
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "User-Agent", value: "xAIKit/\(xAIKit.version)")
        
        for (key, value) in request.headers {
            headers.add(name: key, value: value)
        }
        
        for (key, value) in configuration.customHeaders {
            headers.add(name: key, value: value)
        }
        
        let httpRequest = try AsyncHTTPClient.HTTPClient.Request(
            url: request.url.absoluteString,
            method: NIOHTTP1.HTTPMethod(rawValue: request.method.rawValue),
            headers: headers,
            body: request.body.map { .data($0) }
        )
        
        let response = try await asyncHTTPClient.execute(request: httpRequest).get()
        
        if response.status.code == 429 {
            let retryAfter = response.headers["Retry-After"].first.flatMap(Int.init)
            throw xAIError.rateLimitExceeded(retryAfter: retryAfter)
        }
        
        guard (200...299).contains(response.status.code) else {
            if let body = response.body {
                let data = Data(buffer: body)
                if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    throw xAIError.apiError(
                        statusCode: Int(response.status.code),
                        message: errorResponse.error.message
                    )
                }
                // Try to get raw error message
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw xAIError.apiError(
                    statusCode: Int(response.status.code),
                    message: errorMessage
                )
            }
            throw xAIError.apiError(
                statusCode: Int(response.status.code),
                message: "Unknown error"
            )
        }
        
        guard let body = response.body else {
            throw xAIError.invalidResponse
        }
        
        let data = Data(buffer: body)
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw xAIError.decodingError(error)
        }
    }
    
    private func sendStreamingRequestWithAsyncHTTPClient(_ request: HTTPRequest) async throws -> AsyncThrowingStream<StreamEvent, Error> {
        var headers = NIOHTTP1.HTTPHeaders()
        headers.add(name: "Authorization", value: "Bearer \(configuration.apiKey)")
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "User-Agent", value: "xAIKit/\(xAIKit.version)")
        headers.add(name: "Accept", value: "text/event-stream")
        
        for (key, value) in request.headers {
            headers.add(name: key, value: value)
        }
        
        for (key, value) in configuration.customHeaders {
            headers.add(name: key, value: value)
        }
        
        let httpRequest = try AsyncHTTPClient.HTTPClient.Request(
            url: request.url.absoluteString,
            method: NIOHTTP1.HTTPMethod(rawValue: request.method.rawValue),
            headers: headers,
            body: request.body.map { .data($0) }
        )
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let delegate = StreamingResponseDelegate(continuation: continuation)
                    _ = try await asyncHTTPClient.execute(
                        request: httpRequest,
                        delegate: delegate
                    ).get()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

/// Actor for managing buffer state safely
private actor StreamingBuffer {
    private var buffer = Data()
    
    func append(_ data: Data) {
        buffer.append(data)
    }
    
    func extractEvents() -> [Data] {
        var events: [Data] = []
        
        // Process complete SSE events
        while let range = buffer.range(of: "\n\n".data(using: .utf8)!) {
            let eventData = buffer[..<range.lowerBound]
            buffer.removeSubrange(..<range.upperBound)
            
            if !eventData.isEmpty {
                events.append(eventData)
            }
        }
        
        return events
    }
    
    func getRemainingData() -> Data {
        let remaining = buffer
        buffer = Data()
        return remaining
    }
}

/// Delegate for handling streaming responses
private final class StreamingResponseDelegate: AsyncHTTPClient.HTTPClientResponseDelegate {
    typealias Response = Void
    
    private let continuation: AsyncThrowingStream<StreamEvent, Error>.Continuation
    private let buffer = StreamingBuffer()
    
    init(continuation: AsyncThrowingStream<StreamEvent, Error>.Continuation) {
        self.continuation = continuation
    }
    
    func didReceiveHead(task: HTTPClient.Task<Response>, _ head: HTTPResponseHead) -> EventLoopFuture<Void> {
        if head.status.code == 429 {
            let retryAfter = head.headers["Retry-After"].first.flatMap(Int.init)
            continuation.finish(throwing: xAIError.rateLimitExceeded(retryAfter: retryAfter))
            return task.eventLoop.makeSucceededFuture(())
        }
        
        guard (200...299).contains(head.status.code) else {
            continuation.finish(throwing: xAIError.apiError(
                statusCode: Int(head.status.code),
                message: "Streaming request failed"
            ))
            return task.eventLoop.makeSucceededFuture(())
        }
        
        return task.eventLoop.makeSucceededFuture(())
    }
    
    func didReceiveBodyPart(task: HTTPClient.Task<Response>, _ buffer: ByteBuffer) -> EventLoopFuture<Void> {
        let data = Data(buffer: buffer)
        
        Task {
            await self.buffer.append(data)
            let events = await self.buffer.extractEvents()
            for eventData in events {
                continuation.yield(.data(eventData))
            }
        }
        
        return task.eventLoop.makeSucceededFuture(())
    }
    
    func didFinishRequest(task: HTTPClient.Task<Response>) throws -> Response {
        Task {
            let remaining = await buffer.getRemainingData()
            if !remaining.isEmpty {
                continuation.yield(.data(remaining))
            }
            continuation.yield(.done)
            continuation.finish()
        }
    }
}