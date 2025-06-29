import XCTest
@testable import xAIKit

final class ModelTests: XCTestCase {
    
    // MARK: - Chat Message Tests
    
    func testChatMessageCreation() {
        let message = ChatMessage(role: .user, content: "Hello")
        XCTAssertEqual(message.role, .user)
        XCTAssertEqual(message.stringContent, "Hello")
        
        // Test the content enum directly
        if case .text(let text) = message.content {
            XCTAssertEqual(text, "Hello")
        } else {
            XCTFail("Expected text content")
        }
    }
    
    func testChatMessageWithImageContent() {
        let imageContent = ChatMessage.Content.image(url: "https://example.com/image.jpg")
        let textContent = ChatMessage.Content.text("Check this out")
        let message = ChatMessage(role: .user, content: [imageContent, textContent])
        
        XCTAssertEqual(message.role, .user)
        XCTAssertEqual(message.stringContent, "Check this out")
        
        if case .parts(let parts) = message.content {
            XCTAssertEqual(parts.count, 2)
            if case .image(let url) = parts[0] {
                XCTAssertEqual(url, "https://example.com/image.jpg")
            } else {
                XCTFail("Expected image content")
            }
            if case .text(let text) = parts[1] {
                XCTAssertEqual(text, "Check this out")
            } else {
                XCTFail("Expected text content")
            }
        } else {
            XCTFail("Expected parts content")
        }
    }
    
    func testChatRoleRawValues() {
        XCTAssertEqual(ChatRole.system.rawValue, "system")
        XCTAssertEqual(ChatRole.user.rawValue, "user")
        XCTAssertEqual(ChatRole.assistant.rawValue, "assistant")
    }
    
    // MARK: - Stop Sequence Tests
    
    func testStopSequenceSingle() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let stop = StopSequence.single("STOP")
        let data = try! encoder.encode(stop)
        let decoded = try! decoder.decode(StopSequence.self, from: data)
        
        if case .single(let value) = decoded {
            XCTAssertEqual(value, "STOP")
        } else {
            XCTFail("Expected single stop sequence")
        }
    }
    
    func testStopSequenceMultiple() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let stop = StopSequence.multiple(["STOP1", "STOP2"])
        let data = try! encoder.encode(stop)
        let decoded = try! decoder.decode(StopSequence.self, from: data)
        
        if case .multiple(let values) = decoded {
            XCTAssertEqual(values, ["STOP1", "STOP2"])
        } else {
            XCTFail("Expected multiple stop sequences")
        }
    }
    
    // MARK: - Response Format Tests
    
    func testResponseFormatTypes() {
        XCTAssertEqual(ResponseFormatType.text.rawValue, "text")
        XCTAssertEqual(ResponseFormatType.jsonObject.rawValue, "json_object")
        XCTAssertEqual(ResponseFormatType.jsonSchema.rawValue, "json_schema")
    }
    
    // MARK: - Image Generation Tests
    
    func testImageSizes() {
        XCTAssertEqual(ImageSize.size256x256.rawValue, "256x256")
        XCTAssertEqual(ImageSize.size512x512.rawValue, "512x512")
        XCTAssertEqual(ImageSize.size1024x1024.rawValue, "1024x1024")
        XCTAssertEqual(ImageSize.size1792x1024.rawValue, "1792x1024")
        XCTAssertEqual(ImageSize.size1024x1792.rawValue, "1024x1792")
    }
    
    func testImageQuality() {
        XCTAssertEqual(ImageQuality.standard.rawValue, "standard")
        XCTAssertEqual(ImageQuality.hd.rawValue, "hd")
    }
    
    func testImageStyle() {
        XCTAssertEqual(ImageStyle.vivid.rawValue, "vivid")
        XCTAssertEqual(ImageStyle.natural.rawValue, "natural")
    }
    
    func testImageResponseFormat() {
        XCTAssertEqual(ImageResponseFormat.url.rawValue, "url")
        XCTAssertEqual(ImageResponseFormat.b64Json.rawValue, "b64_json")
    }
    
    // MARK: - Message Tests
    
    func testMessageRoles() {
        XCTAssertEqual(MessageRole.user.rawValue, "user")
        XCTAssertEqual(MessageRole.assistant.rawValue, "assistant")
    }
    
    func testMessageContentText() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let content = MessageContent.text("Hello world")
        let data = try! encoder.encode(content)
        let decoded = try! decoder.decode(MessageContent.self, from: data)
        
        if case .text(let text) = decoded {
            XCTAssertEqual(text, "Hello world")
        } else {
            XCTFail("Expected text content")
        }
    }
    
    func testMessageContentMultipart() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let parts = [
            MessageContentPart(text: "Check out this image:"),
            MessageContentPart(imageURL: "https://example.com/image.jpg")
        ]
        let content = MessageContent.multipart(parts)
        let data = try! encoder.encode(content)
        let decoded = try! decoder.decode(MessageContent.self, from: data)
        
        if case .multipart(let decodedParts) = decoded {
            XCTAssertEqual(decodedParts.count, 2)
            XCTAssertEqual(decodedParts[0].type, .text)
            XCTAssertEqual(decodedParts[0].text, "Check out this image:")
            XCTAssertEqual(decodedParts[1].type, .image)
            XCTAssertEqual(decodedParts[1].image?.url, "https://example.com/image.jpg")
        } else {
            XCTFail("Expected multipart content")
        }
    }
    
    // MARK: - Completion Prompt Tests
    
    func testCompletionPromptString() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let prompt = CompletionPrompt.string("Complete this")
        let data = try! encoder.encode(prompt)
        let decoded = try! decoder.decode(CompletionPrompt.self, from: data)
        
        if case .string(let value) = decoded {
            XCTAssertEqual(value, "Complete this")
        } else {
            XCTFail("Expected string prompt")
        }
    }
    
    func testCompletionPromptStringArray() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let prompt = CompletionPrompt.stringArray(["First", "Second"])
        let data = try! encoder.encode(prompt)
        let decoded = try! decoder.decode(CompletionPrompt.self, from: data)
        
        if case .stringArray(let values) = decoded {
            XCTAssertEqual(values, ["First", "Second"])
        } else {
            XCTFail("Expected string array prompt")
        }
    }
    
    func testCompletionPromptTokenArray() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let prompt = CompletionPrompt.tokenArray([123, 456])
        let data = try! encoder.encode(prompt)
        let decoded = try! decoder.decode(CompletionPrompt.self, from: data)
        
        if case .tokenArray(let values) = decoded {
            XCTAssertEqual(values, [123, 456])
        } else {
            XCTFail("Expected token array prompt")
        }
    }
}