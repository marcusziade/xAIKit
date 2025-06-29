import Foundation

/// Parser for Server-Sent Events (SSE) format
public struct SSEParser {
    /// Represents a single SSE event
    public struct Event {
        public let id: String?
        public let event: String?
        public let data: String
        public let retry: Int?
    }
    
    /// Parse SSE data into events
    /// - Parameter data: Raw SSE data
    /// - Returns: Array of parsed events
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