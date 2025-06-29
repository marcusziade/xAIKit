import XCTest
@testable import xAIKit

final class ErrorTests: XCTestCase {
    
    func testErrorDescriptions() {
        XCTAssertEqual(xAIError.invalidAPIKey.localizedDescription, "Invalid API key provided")
        
        let networkError = NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network failed"])
        XCTAssertEqual(xAIError.networkError(networkError).localizedDescription, "Network error: Network failed")
        
        XCTAssertEqual(xAIError.invalidRequest("Bad parameters").localizedDescription, "Invalid request: Bad parameters")
        
        XCTAssertEqual(xAIError.apiError(statusCode: 400, message: "Bad request").localizedDescription, "API error (status 400): Bad request")
        
        let decodingError = NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Decoding failed"])
        XCTAssertEqual(xAIError.decodingError(decodingError).localizedDescription, "Failed to decode response: Decoding failed")
        
        XCTAssertEqual(xAIError.streamingError("Stream interrupted").localizedDescription, "Streaming error: Stream interrupted")
        
        XCTAssertEqual(xAIError.timeout.localizedDescription, "Request timed out")
        
        XCTAssertEqual(xAIError.rateLimitExceeded(retryAfter: 60).localizedDescription, "Rate limit exceeded. Retry after 60 seconds")
        XCTAssertEqual(xAIError.rateLimitExceeded(retryAfter: nil).localizedDescription, "Rate limit exceeded")
        
        XCTAssertEqual(xAIError.invalidResponse.localizedDescription, "Invalid response format")
        
        XCTAssertEqual(xAIError.missingParameter("api_key").localizedDescription, "Missing required parameter: api_key")
        
        XCTAssertEqual(xAIError.unsupportedOperation("streaming").localizedDescription, "Unsupported operation: streaming")
    }
    
    func testAPIErrorResponseCoding() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let errorDetail = APIErrorDetail(message: "Test error", type: "invalid_request", code: "E001")
        let errorResponse = APIErrorResponse(error: errorDetail)
        
        let data = try! encoder.encode(errorResponse)
        let decoded = try! decoder.decode(APIErrorResponse.self, from: data)
        
        XCTAssertEqual(decoded.error.message, "Test error")
        XCTAssertEqual(decoded.error.type, "invalid_request")
        XCTAssertEqual(decoded.error.code, "E001")
    }
    
    func testAPIErrorResponseWithNilFields() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let errorDetail = APIErrorDetail(message: "Test error", type: nil, code: nil)
        let errorResponse = APIErrorResponse(error: errorDetail)
        
        let data = try! encoder.encode(errorResponse)
        let decoded = try! decoder.decode(APIErrorResponse.self, from: data)
        
        XCTAssertEqual(decoded.error.message, "Test error")
        XCTAssertNil(decoded.error.type)
        XCTAssertNil(decoded.error.code)
    }
}