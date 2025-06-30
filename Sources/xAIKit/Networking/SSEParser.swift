import Foundation

/// Parser for Server-Sent Events (SSE) format.
///
/// Handles parsing of streaming responses from the xAI API, which uses the
/// SSE format for real-time data delivery. SSE is a standard for server-to-client
/// streaming of text-based event data.
///
/// ## SSE Format
/// ```
/// event: message
/// data: {"content": "Hello"}
/// 
/// event: done
/// data: [DONE]
/// ```
///
/// ## Usage
/// The parser is used internally by the HTTP client to process streaming responses,
/// converting raw SSE data into structured events that can be processed by the SDK.
public struct SSEParser {
    /// Represents a single Server-Sent Event.
    ///
    /// Contains all fields that can be present in an SSE message:
    /// - `id`: Optional event identifier
    /// - `event`: Event type (e.g., "message", "error", "done")
    /// - `data`: The actual event data, typically JSON
    /// - `retry`: Reconnection time in milliseconds
    public struct Event {
        public let id: String?
        public let event: String?
        public let data: String
        public let retry: Int?
    }
    
    /// Parse SSE data into events.
    ///
    /// Processes a complete chunk of SSE-formatted data and extracts all events
    /// contained within. Handles multi-line data fields and proper event boundaries.
    ///
    /// - Parameter data: Raw SSE data from the server
    /// - Returns: Array of parsed events
    ///
    /// ## Example
    /// ```swift
    /// let sseData = "event: message\ndata: {\"text\": \"Hello\"}\n\n".data(using: .utf8)!
    /// let events = SSEParser.parse(sseData)
    /// ```
    public static func parse(_ data: Data) -> [Event] {
        guard let string = String(data: data, encoding: .utf8) else {
            return []
        }
        
        var events: [Event] = []
        let lines = string.components(separatedBy: .newlines)
        
        var currentEvent: (id: String?, event: String?, data: [String], retry: Int?) = (nil, nil, [], nil)
        
        for line in lines {
            if line.isEmpty {
                // End of event
                if !currentEvent.data.isEmpty {
                    let event = Event(
                        id: currentEvent.id,
                        event: currentEvent.event,
                        data: currentEvent.data.joined(separator: "\n"),
                        retry: currentEvent.retry
                    )
                    events.append(event)
                }
                currentEvent = (nil, nil, [], nil)
                continue
            }
            
            if line.hasPrefix(":") {
                // Comment, ignore
                continue
            }
            
            if let colonIndex = line.firstIndex(of: ":") {
                let field = String(line[..<colonIndex])
                var value = String(line[line.index(after: colonIndex)...])
                
                // Remove leading space if present
                if value.hasPrefix(" ") {
                    value = String(value.dropFirst())
                }
                
                switch field {
                case "id":
                    currentEvent.id = value
                case "event":
                    currentEvent.event = value
                case "data":
                    currentEvent.data.append(value)
                case "retry":
                    currentEvent.retry = Int(value)
                default:
                    break
                }
            }
        }
        
        // Handle last event if data ends without empty line
        if !currentEvent.data.isEmpty {
            let event = Event(
                id: currentEvent.id,
                event: currentEvent.event,
                data: currentEvent.data.joined(separator: "\n"),
                retry: currentEvent.retry
            )
            events.append(event)
        }
        
        return events
    }
    
    /// Parse streaming data buffer incrementally.
    ///
    /// Designed for processing streaming data as it arrives. Maintains state in the
    /// buffer and extracts complete events while preserving incomplete data for the
    /// next iteration.
    ///
    /// - Parameter buffer: Mutable buffer containing accumulated streaming data
    /// - Returns: A complete parsed event, or `nil` if no complete event is available
    ///
    /// - Note: This method modifies the buffer, removing processed data
    public static func parseBuffer(_ buffer: inout Data) -> Event? {
        var currentEvent: (id: String?, event: String?, data: [String], retry: Int?) = (nil, nil, [], nil)
        var foundCompleteEvent = false
        
        // Process lines in buffer
        while let newlineRange = buffer.range(of: Data([0x0A])) {
            let lineData = buffer[..<newlineRange.lowerBound]
            buffer.removeSubrange(..<newlineRange.upperBound)
            
            guard let line = String(data: lineData, encoding: .utf8) else {
                continue
            }
            
            if line.isEmpty {
                // End of event
                if !currentEvent.data.isEmpty {
                    foundCompleteEvent = true
                    break
                }
                continue
            }
            
            if line.hasPrefix(":") {
                // Comment, ignore
                continue
            }
            
            if let colonIndex = line.firstIndex(of: ":") {
                let field = String(line[..<colonIndex])
                var value = String(line[line.index(after: colonIndex)...])
                
                // Remove leading space if present
                if value.hasPrefix(" ") {
                    value = String(value.dropFirst())
                }
                
                switch field {
                case "id":
                    currentEvent.id = value
                case "event":
                    currentEvent.event = value
                case "data":
                    currentEvent.data.append(value)
                case "retry":
                    currentEvent.retry = Int(value)
                default:
                    break
                }
            }
        }
        
        if foundCompleteEvent && !currentEvent.data.isEmpty {
            return Event(
                id: currentEvent.id,
                event: currentEvent.event,
                data: currentEvent.data.joined(separator: "\n"),
                retry: currentEvent.retry
            )
        }
        
        return nil
    }
    
    /// Parse streaming chat completion chunks
    /// - Parameter event: SSE event
    /// - Returns: Decoded chunk or nil if parsing fails
    public static func parseChatCompletionChunk(_ event: Event) -> ChatCompletionChunk? {
        guard event.data != "[DONE]" else {
            return nil
        }
        
        guard let data = event.data.data(using: .utf8) else {
            return nil
        }
        
        return try? JSONDecoder().decode(ChatCompletionChunk.self, from: data)
    }
    
    /// Parse streaming message chunks (Anthropic format)
    /// - Parameter event: SSE event
    /// - Returns: Decoded chunk or nil if parsing fails
    public static func parseMessageChunk(_ event: Event) -> MessageStreamEvent? {
        guard let data = event.data.data(using: .utf8) else {
            return nil
        }
        
        return try? JSONDecoder().decode(MessageStreamEvent.self, from: data)
    }
}