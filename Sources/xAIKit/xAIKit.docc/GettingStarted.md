# Getting Started with xAIKit

Learn how to integrate xAIKit into your Swift project and make your first API call.

## Installation

### Swift Package Manager

Add xAIKit to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/xAIKit", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/yourusername/xAIKit`
3. Click "Add Package"

## Basic Usage

### Initialize the Client

```swift
import xAIKit

let client = xAIClient(apiKey: "your-api-key")
```

### Send a Message

```swift
let request = ChatRequest(
    model: .grokBeta,
    messages: [
        Message(role: .user, content: "What is quantum computing?")
    ]
)

let response = try await client.chat.completions(request)
print(response.choices.first?.message.content ?? "")
```

### Streaming Responses

```swift
let request = ChatRequest(
    model: .grokBeta,
    messages: [
        Message(role: .user, content: "Explain the theory of relativity")
    ],
    stream: true
)

for try await chunk in client.chat.stream(request) {
    if let content = chunk.choices.first?.delta?.content {
        print(content, terminator: "")
    }
}
```

## API Key Management

### Environment Variables

The recommended way to manage your API key is through environment variables:

```swift
let client = xAIClient(apiKey: ProcessInfo.processInfo.environment["XAI_API_KEY"] ?? "")
```

### Keychain Storage

For production apps, consider storing the API key in the Keychain:

```swift
import Security

// Store API key
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: "xai-api-key",
    kSecValueData as String: apiKey.data(using: .utf8)!
]
SecItemAdd(query as CFDictionary, nil)

// Retrieve API key
var result: AnyObject?
let status = SecItemCopyMatching(query as CFDictionary, &result)
if status == errSecSuccess,
   let data = result as? Data,
   let apiKey = String(data: data, encoding: .utf8) {
    let client = xAIClient(apiKey: apiKey)
}
```

## Next Steps

- Explore the <doc:Tutorials> to build a complete AI assistant
- Check out the API documentation for advanced features
- Browse example projects in the repository