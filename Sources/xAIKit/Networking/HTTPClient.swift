import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

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

/// Simple network error wrapper
struct NetworkError: LocalizedError {
    let message: String
    
    var errorDescription: String? {
        return message
    }
}

/// Factory function to create platform-appropriate HTTP client
public func createHTTPClient(configuration: xAIConfiguration) -> HTTPClientProtocol {
    #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    return URLSessionHTTPClient(configuration: configuration)
    #else
    return CURLHTTPClient(configuration: configuration)
    #endif
}

/// URLSession-based HTTP client for Apple platforms
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
public final class URLSessionHTTPClient: HTTPClientProtocol {
    private let configuration: xAIConfiguration
    private let session: URLSession
    
    public init(configuration: xAIConfiguration) {
        self.configuration = configuration
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = configuration.timeoutInterval
        config.timeoutIntervalForResource = configuration.timeoutInterval * 2
        self.session = URLSession(configuration: config)
    }
    
    public func sendRequest<T: Decodable>(_ request: HTTPRequest) async throws -> T {
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
        
        let (data, response) = try await session.data(for: urlRequest)
        
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
    
    public func sendStreamingRequest(_ request: HTTPRequest) async throws -> AsyncThrowingStream<StreamEvent, Error> {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        urlRequest.timeoutInterval = request.timeoutInterval
        
        // Set headers
        urlRequest.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("xAIKit/\(xAIKit.version)", forHTTPHeaderField: "User-Agent")
        urlRequest.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        
        for (key, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        for (key, value) in configuration.customHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let (bytes, response) = try await session.bytes(for: urlRequest)
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        continuation.finish(throwing: xAIError.invalidResponse)
                        return
                    }
                    
                    if httpResponse.statusCode == 429 {
                        let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
                        continuation.finish(throwing: xAIError.rateLimitExceeded(retryAfter: retryAfter))
                        return
                    }
                    
                    guard (200...299).contains(httpResponse.statusCode) else {
                        // Try to collect error data
                        var errorData = Data()
                        for try await byte in bytes {
                            errorData.append(byte)
                        }
                        
                        if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: errorData) {
                            continuation.finish(throwing: xAIError.apiError(
                                statusCode: httpResponse.statusCode,
                                message: errorResponse.error.message
                            ))
                        } else {
                            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                            continuation.finish(throwing: xAIError.apiError(
                                statusCode: httpResponse.statusCode,
                                message: errorMessage
                            ))
                        }
                        return
                    }
                    
                    // Buffer for accumulating data until we have complete lines
                    var buffer = Data()
                    
                    for try await byte in bytes {
                        buffer.append(byte)
                        
                        // Check for complete lines
                        while let newlineRange = buffer.range(of: Data([0x0A])) { // \n
                            let line = buffer[..<newlineRange.lowerBound]
                            buffer.removeSubrange(..<newlineRange.upperBound)
                            
                            // Check if this is a complete SSE event (double newline)
                            if line.isEmpty && !buffer.isEmpty {
                                // Look for another newline to complete the double newline
                                if buffer.first == 0x0A {
                                    buffer.removeFirst()
                                    // We have a complete event, process what we've accumulated
                                    continuation.yield(.data(Data())) // Empty line to signal event boundary
                                }
                            } else {
                                // Yield the line data including the newline
                                var lineWithNewline = line
                                lineWithNewline.append(0x0A)
                                continuation.yield(.data(lineWithNewline))
                            }
                        }
                    }
                    
                    // Send any remaining data
                    if !buffer.isEmpty {
                        continuation.yield(.data(buffer))
                    }
                    
                    continuation.yield(.done)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
#endif

/// CURL-based HTTP client for Linux
#if os(Linux)
public final class CURLHTTPClient: HTTPClientProtocol {
    private let configuration: xAIConfiguration
    
    public init(configuration: xAIConfiguration) {
        self.configuration = configuration
    }
    
    public func sendRequest<T: Decodable>(_ request: HTTPRequest) async throws -> T {
        // Use URLSession with synchronous wrapper for non-streaming requests on Linux
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
        
        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                    continuation.resume(throwing: xAIError.invalidResponse)
                    return
                }
                
                if httpResponse.statusCode == 429 {
                    let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
                    continuation.resume(throwing: xAIError.rateLimitExceeded(retryAfter: retryAfter))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                        continuation.resume(throwing: xAIError.apiError(
                            statusCode: httpResponse.statusCode,
                            message: errorResponse.error.message
                        ))
                    } else {
                        let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                        continuation.resume(throwing: xAIError.apiError(
                            statusCode: httpResponse.statusCode,
                            message: errorMessage
                        ))
                    }
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    continuation.resume(returning: decoded)
                } catch {
                    continuation.resume(throwing: xAIError.decodingError(error))
                }
            }
            task.resume()
        }
    }
    
    public func sendStreamingRequest(_ request: HTTPRequest) async throws -> AsyncThrowingStream<StreamEvent, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    // Prepare CURL command
                    var curlCommand = ["/usr/bin/curl", "-N", "--no-buffer", "-s", "-i"]
                    
                    // Add method
                    curlCommand.append("-X")
                    curlCommand.append(request.method.rawValue)
                    
                    // Add headers
                    curlCommand.append("-H")
                    curlCommand.append("Authorization: Bearer \(configuration.apiKey)")
                    curlCommand.append("-H")
                    curlCommand.append("Content-Type: application/json")
                    curlCommand.append("-H")
                    curlCommand.append("User-Agent: xAIKit/\(xAIKit.version)")
                    curlCommand.append("-H")
                    curlCommand.append("Accept: text/event-stream")
                    
                    for (key, value) in request.headers {
                        curlCommand.append("-H")
                        curlCommand.append("\(key): \(value)")
                    }
                    
                    for (key, value) in configuration.customHeaders {
                        curlCommand.append("-H")
                        curlCommand.append("\(key): \(value)")
                    }
                    
                    // Add body if present
                    if let body = request.body {
                        curlCommand.append("-d")
                        curlCommand.append(String(data: body, encoding: .utf8) ?? "")
                    }
                    
                    // Add URL
                    curlCommand.append(request.url.absoluteString)
                    
                    // Create process
                    let process = Process()
                    process.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
                    process.arguments = Array(curlCommand.dropFirst())
                    
                    let outputPipe = Pipe()
                    let errorPipe = Pipe()
                    process.standardOutput = outputPipe
                    process.standardError = errorPipe
                    
                    try process.run()
                    
                    let outputHandle = outputPipe.fileHandleForReading
                    var buffer = Data()
                    var headersComplete = false
                    var statusCode: Int = 0
                    
                    // Read data from process
                    while process.isRunning || outputHandle.availableData.count > 0 {
                        let chunk = outputHandle.availableData
                        if chunk.isEmpty {
                            // Small delay to avoid busy waiting
                            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
                            continue
                        }
                        
                        buffer.append(chunk)
                        
                        // Parse headers if not yet complete
                        if !headersComplete {
                            if let doubleNewlineRange = buffer.range(of: Data("\r\n\r\n".utf8)) {
                                let headerData = buffer[..<doubleNewlineRange.lowerBound]
                                buffer.removeSubrange(..<doubleNewlineRange.upperBound)
                                
                                if let headerString = String(data: headerData, encoding: .utf8) {
                                    let lines = headerString.components(separatedBy: "\r\n")
                                    if let statusLine = lines.first {
                                        let components = statusLine.components(separatedBy: " ")
                                        if components.count >= 2 {
                                            statusCode = Int(components[1]) ?? 0
                                        }
                                    }
                                    
                                    // Check for retry-after header
                                    var retryAfter: Int? = nil
                                    for line in lines {
                                        if line.lowercased().hasPrefix("retry-after:") {
                                            let value = line.dropFirst("retry-after:".count).trimmingCharacters(in: .whitespaces)
                                            retryAfter = Int(value)
                                        }
                                    }
                                    
                                    if statusCode == 429 {
                                        continuation.finish(throwing: xAIError.rateLimitExceeded(retryAfter: retryAfter))
                                        process.terminate()
                                        return
                                    }
                                    
                                    if !(200...299).contains(statusCode) {
                                        // Collect error body
                                        var errorData = buffer
                                        while process.isRunning || outputHandle.availableData.count > 0 {
                                            let chunk = outputHandle.availableData
                                            if !chunk.isEmpty {
                                                errorData.append(chunk)
                                            }
                                        }
                                        
                                        if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: errorData) {
                                            continuation.finish(throwing: xAIError.apiError(
                                                statusCode: statusCode,
                                                message: errorResponse.error.message
                                            ))
                                        } else {
                                            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                                            continuation.finish(throwing: xAIError.apiError(
                                                statusCode: statusCode,
                                                message: errorMessage
                                            ))
                                        }
                                        process.terminate()
                                        return
                                    }
                                }
                                
                                headersComplete = true
                            }
                        } else {
                            // Process body data line by line
                            while let newlineRange = buffer.range(of: Data([0x0A])) {
                                let line = buffer[..<newlineRange.lowerBound]
                                buffer.removeSubrange(..<newlineRange.upperBound)
                                
                                // Check if this is a complete SSE event (double newline)
                                if line.isEmpty && !buffer.isEmpty {
                                    // Look for another newline to complete the double newline
                                    if buffer.first == 0x0A {
                                        buffer.removeFirst()
                                        // We have a complete event, process what we've accumulated
                                        continuation.yield(.data(Data())) // Empty line to signal event boundary
                                    }
                                } else {
                                    // Yield the line data including the newline
                                    var lineWithNewline = line
                                    lineWithNewline.append(0x0A)
                                    continuation.yield(.data(lineWithNewline))
                                }
                            }
                        }
                    }
                    
                    // Wait for process to complete
                    process.waitUntilExit()
                    
                    // Send any remaining data
                    if !buffer.isEmpty && headersComplete {
                        continuation.yield(.data(buffer))
                    }
                    
                    // Check if process exited with error
                    if process.terminationStatus != 0 {
                        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                        let errorMessage = String(data: errorData, encoding: .utf8) ?? "CURL process failed"
                        continuation.finish(throwing: xAIError.networkError(NetworkError(message: errorMessage)))
                        return
                    }
                    
                    continuation.yield(.done)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
#endif

/// Main HTTP client wrapper
public final class xAIHTTPClient: HTTPClientProtocol {
    private let configuration: xAIConfiguration
    private let httpClient: HTTPClientProtocol
    
    public init(configuration: xAIConfiguration) {
        self.configuration = configuration
        self.httpClient = createHTTPClient(configuration: configuration)
    }
    
    public func sendRequest<T: Decodable>(_ request: HTTPRequest) async throws -> T {
        return try await httpClient.sendRequest(request)
    }
    
    public func sendStreamingRequest(_ request: HTTPRequest) async throws -> AsyncThrowingStream<StreamEvent, Error> {
        return try await httpClient.sendStreamingRequest(request)
    }
}