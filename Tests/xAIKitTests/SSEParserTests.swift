import XCTest
@testable import xAIKit

final class SSEParserTests: XCTestCase {
    
    func testParseSimpleEvent() {
        let data = "data: Hello World\n\n".data(using: .utf8)!
        let events = SSEParser.parse(data)
        
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].data, "Hello World")
        XCTAssertNil(events[0].id)
        XCTAssertNil(events[0].event)
        XCTAssertNil(events[0].retry)
    }
    
    func testParseEventWithAllFields() {
        let data = """
        id: 123
        event: message
        retry: 5000
        data: Test data
        
        """.data(using: .utf8)!
        
        let events = SSEParser.parse(data)
        
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].id, "123")
        XCTAssertEqual(events[0].event, "message")
        XCTAssertEqual(events[0].data, "Test data")
        XCTAssertEqual(events[0].retry, 5000)
    }
    
    func testParseMultilineData() {
        let data = """
        data: Line 1
        data: Line 2
        data: Line 3
        
        """.data(using: .utf8)!
        
        let events = SSEParser.parse(data)
        
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].data, "Line 1\nLine 2\nLine 3")
    }
    
    func testParseMultipleEvents() {
        let data = """
        data: Event 1
        
        data: Event 2
        
        data: Event 3
        
        """.data(using: .utf8)!
        
        let events = SSEParser.parse(data)
        
        XCTAssertEqual(events.count, 3)
        XCTAssertEqual(events[0].data, "Event 1")
        XCTAssertEqual(events[1].data, "Event 2")
        XCTAssertEqual(events[2].data, "Event 3")
    }
    
    func testParseWithComments() {
        let data = """
        : This is a comment
        data: Actual data
        : Another comment
        
        """.data(using: .utf8)!
        
        let events = SSEParser.parse(data)
        
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].data, "Actual data")
    }
    
    func testParseWithLeadingSpace() {
        let data = "data: Test data with space\n\n".data(using: .utf8)!
        let events = SSEParser.parse(data)
        
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].data, "Test data with space")
    }
    
    func testParseEmptyData() {
        let data = "".data(using: .utf8)!
        let events = SSEParser.parse(data)
        
        XCTAssertEqual(events.count, 0)
    }
    
    func testParseEventWithoutEmptyLine() {
        let data = "data: Event without empty line".data(using: .utf8)!
        let events = SSEParser.parse(data)
        
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].data, "Event without empty line")
    }
    
    func testParseChatCompletionChunkDone() {
        let event = SSEParser.Event(id: nil, event: nil, data: "[DONE]", retry: nil)
        let chunk = SSEParser.parseChatCompletionChunk(event)
        
        XCTAssertNil(chunk)
    }
    
    func testParseInvalidChatCompletionChunk() {
        let event = SSEParser.Event(id: nil, event: nil, data: "invalid json", retry: nil)
        let chunk = SSEParser.parseChatCompletionChunk(event)
        
        XCTAssertNil(chunk)
    }
}