import XCTest
@testable import xAIKit

final class ClientTests: XCTestCase {
    
    func testClientInitializationWithConfiguration() {
        let config = xAIConfiguration(apiKey: "test-key")
        let client = xAIClient(configuration: config)
        
        XCTAssertNotNil(client.chat)
        XCTAssertNotNil(client.messages)
        XCTAssertNotNil(client.images)
        XCTAssertNotNil(client.models)
        XCTAssertNotNil(client.tokenization)
        XCTAssertNotNil(client.apiKey)
        XCTAssertNotNil(client.completions)
    }
    
    func testClientInitializationWithAPIKey() {
        let client = xAIClient(apiKey: "test-key")
        
        XCTAssertNotNil(client.chat)
        XCTAssertNotNil(client.messages)
        XCTAssertNotNil(client.images)
        XCTAssertNotNil(client.models)
        XCTAssertNotNil(client.tokenization)
        XCTAssertNotNil(client.apiKey)
        XCTAssertNotNil(client.completions)
    }
    
    func testClientInitializationWithCustomURLs() {
        let apiURL = URL(string: "https://custom.api.com")!
        let managementURL = URL(string: "https://custom.management.com")!
        
        let client = xAIClient(
            apiKey: "test-key",
            apiBaseURL: apiURL,
            managementAPIBaseURL: managementURL
        )
        
        XCTAssertNotNil(client)
    }
    
    func testVersionConstant() {
        XCTAssertEqual(xAIKit.version, "1.0.0")
    }
    
    func testDefaultURLConstants() {
        XCTAssertEqual(xAIKit.defaultAPIBaseURL, "https://api.x.ai")
        XCTAssertEqual(xAIKit.defaultManagementAPIBaseURL, "https://management-api.x.ai")
    }
}