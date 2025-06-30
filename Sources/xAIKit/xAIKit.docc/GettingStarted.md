# Getting Started with xAIKit

Learn how to integrate xAIKit into your Swift project and start building AI-powered applications with xAI's powerful models.

## Installation

### Swift Package Manager

Add xAIKit to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/marcusziade/xAIKit", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["xAIKit"]
    )
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/marcusziade/xAIKit`
3. Select your desired version rule
4. Click "Add Package"

### Platform Requirements

- **iOS** 16.0+
- **macOS** 13.0+
- **watchOS** 9.0+
- **tvOS** 16.0+
- **visionOS** 1.0+

## Quick Start

### 1. Initialize the Client

```swift
import xAIKit

// Basic initialization
let client = xAIClient(apiKey: "your-api-key")

// Advanced configuration
let config = xAIConfiguration(
    apiKey: "your-api-key",
    baseURL: "https://api.x.ai", // Optional: custom endpoint
    timeoutInterval: 60.0,        // Optional: custom timeout
    defaultModel: .grokBeta       // Optional: default model
)
let client = xAIClient(configuration: config)
```

### 2. Send Your First Message

```swift
// Simple chat completion
let request = ChatRequest(
    model: .grokBeta,
    messages: [
        Message(role: .system, content: "You are a helpful assistant."),
        Message(role: .user, content: "What is quantum computing?")
    ]
)

do {
    let response = try await client.chat.completions(request)
    if let content = response.choices.first?.message.content {
        print("AI Response: \(content)")
    }
} catch {
    print("Error: \(error)")
}
```

## Core Features

### Streaming Responses

Enable real-time streaming for a more interactive experience:

```swift
let request = ChatRequest(
    model: .grokBeta,
    messages: [
        Message(role: .user, content: "Explain the theory of relativity")
    ],
    stream: true
)

do {
    for try await chunk in client.chat.stream(request) {
        if let content = chunk.choices.first?.delta?.content {
            print(content, terminator: "")
            fflush(stdout) // Ensure immediate output
        }
    }
} catch {
    print("Streaming error: \(error)")
}
```

### Image Generation

Generate images from text descriptions:

```swift
let imageRequest = ImageGenerationRequest(
    prompt: "A serene mountain landscape at sunset",
    model: .grok2Image,
    n: 1 // Number of images to generate
)

do {
    let response = try await client.images.generate(imageRequest)
    if let imageURL = response.data.first?.url {
        print("Generated image URL: \(imageURL)")
        // Download and display the image in your app
    }
} catch {
    print("Image generation error: \(error)")
}
```

### Multi-Modal Conversations

Combine text and images in your conversations:

```swift
let messageContent = MessageContent.array([
    .text("What's in this image?"),
    .imageURL(MessageContent.ImageURL(
        url: "https://example.com/image.jpg"
    ))
])

let request = ChatRequest(
    model: .grokBeta,
    messages: [
        Message(role: .user, content: messageContent)
    ]
)

let response = try await client.chat.completions(request)
```

### Structured Outputs

Get responses in a specific JSON format:

```swift
// Define your expected structure
let schema = JSONSchema(
    type: .object,
    properties: [
        "name": JSONSchema(type: .string),
        "age": JSONSchema(type: .integer),
        "skills": JSONSchema(
            type: .array,
            items: JSONSchema(type: .string)
        )
    ],
    required: ["name", "age"]
)

let request = ChatRequest(
    model: .grokBeta,
    messages: [
        Message(role: .user, content: "Generate a character profile")
    ],
    responseFormat: .jsonSchema(
        JSONSchemaFormat(
            name: "character_profile",
            schema: schema,
            strict: true
        )
    )
)

let response = try await client.chat.completions(request)
// Response will be valid JSON matching your schema
```

## API Key Management

### Environment Variables (Recommended)

The safest approach for development:

```swift
guard let apiKey = ProcessInfo.processInfo.environment["XAI_API_KEY"] else {
    fatalError("Please set XAI_API_KEY environment variable")
}
let client = xAIClient(apiKey: apiKey)
```

Set the environment variable:
```bash
export XAI_API_KEY="your-api-key-here"
```

### Keychain Storage (Production)

For production apps, use the Keychain for secure storage:

```swift
import Security

class APIKeyManager {
    static let shared = APIKeyManager()
    private let serviceName = "com.yourapp.xaikit"
    private let accountName = "xai-api-key"
    
    func saveAPIKey(_ apiKey: String) throws {
        let data = apiKey.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName,
            kSecValueData as String: data
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unableToSave
        }
    }
    
    func retrieveAPIKey() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountName,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let apiKey = String(data: data, encoding: .utf8) else {
            throw KeychainError.itemNotFound
        }
        
        return apiKey
    }
}

// Usage
do {
    let apiKey = try APIKeyManager.shared.retrieveAPIKey()
    let client = xAIClient(apiKey: apiKey)
} catch {
    print("Failed to retrieve API key: \(error)")
}
```

## Error Handling

xAIKit provides comprehensive error handling:

```swift
do {
    let response = try await client.chat.completions(request)
    // Process response
} catch let error as xAIError {
    switch error {
    case .invalidAPIKey:
        print("Invalid API key. Please check your credentials.")
    case .rateLimitExceeded(let retryAfter):
        print("Rate limit exceeded. Retry after \(retryAfter ?? 0) seconds.")
    case .networkError(let underlying):
        print("Network error: \(underlying.localizedDescription)")
    case .decodingError(let details):
        print("Failed to decode response: \(details)")
    default:
        print("Unexpected error: \(error)")
    }
} catch {
    print("Unknown error: \(error)")
}
```

## Best Practices

### 1. Use Configuration Objects

For complex setups, use configuration objects:

```swift
let config = xAIConfiguration(
    apiKey: apiKey,
    defaultModel: .grokBeta,
    defaultTemperature: 0.7,
    defaultMaxTokens: 2000,
    headers: ["X-Custom-Header": "value"]
)
```

### 2. Handle Rate Limits Gracefully

Implement exponential backoff for rate limits:

```swift
func makeRequestWithRetry() async throws -> ChatResponse {
    var retryCount = 0
    let maxRetries = 3
    
    while retryCount < maxRetries {
        do {
            return try await client.chat.completions(request)
        } catch xAIError.rateLimitExceeded(let retryAfter) {
            let delay = retryAfter ?? Double(pow(2, Double(retryCount)))
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            retryCount += 1
        }
    }
    
    throw xAIError.rateLimitExceeded(retryAfter: nil)
}
```

### 3. Monitor Token Usage

Track your token consumption:

```swift
let response = try await client.chat.completions(request)
if let usage = response.usage {
    print("Prompt tokens: \(usage.promptTokens)")
    print("Completion tokens: \(usage.completionTokens)")
    print("Total tokens: \(usage.totalTokens)")
}
```

## Next Steps

- 📚 Explore the <doc:Tutorials> to build complete applications
- 🔧 Dive into advanced features like function calling and structured outputs
- 🎯 Check out example projects in the repository
- 💬 Join the community discussions for tips and best practices