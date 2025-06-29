import XCTest
@testable import xAIKit

final class ConfigurationTests: XCTestCase {
    func testDefaultConfiguration() {
        let config = xAIConfiguration(apiKey: "test-key")
        
        XCTAssertEqual(config.apiKey, "test-key")
        XCTAssertEqual(config.apiBaseURL.absoluteString, "https://api.x.ai")
        XCTAssertEqual(config.managementAPIBaseURL.absoluteString, "https://management-api.x.ai")
        XCTAssertEqual(config.timeoutInterval, 60)
        XCTAssertFalse(config.useStreaming)
        XCTAssertTrue(config.customHeaders.isEmpty)
    }
    
    func testCustomConfiguration() {
        let customURL = URL(string: "https://custom.api.com")!
        let customManagementURL = URL(string: "https://custom.management.com")!
        let customHeaders = ["X-Custom": "Value"]
        
        let config = xAIConfiguration(
            apiKey: "custom-key",
            apiBaseURL: customURL,
            managementAPIBaseURL: customManagementURL,
            timeoutInterval: 120,
            useStreaming: true,
            customHeaders: customHeaders
        )
        
        XCTAssertEqual(config.apiKey, "custom-key")
        XCTAssertEqual(config.apiBaseURL, customURL)
        XCTAssertEqual(config.managementAPIBaseURL, customManagementURL)
        XCTAssertEqual(config.timeoutInterval, 120)
        XCTAssertTrue(config.useStreaming)
        XCTAssertEqual(config.customHeaders, customHeaders)
    }
}