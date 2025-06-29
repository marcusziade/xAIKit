# xAIKit

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20visionOS%20%7C%20Linux-blue.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![CI](https://github.com/marcusziade/xAIKit/actions/workflows/ci.yml/badge.svg)](https://github.com/marcusziade/xAIKit/actions/workflows/ci.yml)
[![Documentation](https://img.shields.io/badge/Documentation-DocC-blue.svg)](https://github.com/marcusziade/xAIKit)

A production-ready Swift SDK for the xAI API, providing comprehensive access to all xAI services including chat completions, image generation, and model management.

## Features

- 🚀 **Complete API Coverage**: Full implementation of all xAI API endpoints
- 🔄 **Streaming Support**: Real-time streaming for chat and message completions
- 🖼️ **Image Generation**: Create images with various sizes and styles
- 🛡️ **Type-Safe**: Leveraging Swift's type system for safe API interactions
- 🐧 **Cross-Platform**: Works on all Apple platforms (macOS 13+, iOS 16+, watchOS 9+, tvOS 16+, visionOS 1+) and Linux
- 📚 **Well-Documented**: Comprehensive DocC documentation for all public APIs
- 🧪 **Thoroughly Tested**: Unit tests for all non-networking components
- 🔧 **CLI Tool**: Included command-line tool for testing all API features

## Installation

### Swift Package Manager

Add xAIKit to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/marcusziade/xAIKit.git", from: "1.0.0")
]
```

Then add it to your target dependencies:

```swift
.target(
    name: "YourApp",
    dependencies: ["xAIKit"]
)
```

## Quick Start

```swift
import xAIKit

// Initialize the client
let client = xAIClient(apiKey: "your-api-key")

// Create a chat completion
let response = try await client.chat.completions(
    messages: [
        ChatMessage(role: .system, content: "You are a helpful assistant."),
        ChatMessage(role: .user, content: "Hello, how are you?")
    ],
    model: "grok-3-mini-fast-latest"
)

print(response.choices.first?.message.content ?? "No response")
```

## Usage Examples

### Chat Completions (OpenAI Compatible)

```swift
// Simple chat completion
let response = try await client.chat.completions(
    messages: [ChatMessage(role: .user, content: "What is the meaning of life?")],
    model: "grok-3-mini-fast-latest",
    temperature: 0.7
)

// Streaming chat completion
let stream = try await client.chat.completionsStream(
    messages: messages,
    model: "grok-3-mini-fast-latest"
)

for try await chunk in stream {
    if let content = chunk.choices.first?.delta.content {
        print(content, terminator: "")
    }
}
```

### Messages API (Anthropic Compatible)

```swift
// Create a message
let response = try await client.messages.create(
    messages: [Message(role: .user, content: .text("Tell me a joke"))],
    model: "grok-3-fast-latest",
    maxTokens: 100
)

// Streaming messages
let stream = try await client.messages.createStream(
    messages: messages,
    model: "grok-3-fast-latest",
    maxTokens: 1000
)

for try await event in stream {
    switch event.type {
    case .contentBlockDelta:
        if let text = event.delta?.text {
            print(text, terminator: "")
        }
    default:
        break
    }
}
```

### Image Generation

```swift
// Generate an image
let response = try await client.images.generate(
    prompt: "A beautiful sunset over mountains",
    model: "grok-2-image"
)

if let imageURL = response.data.first?.url {
    print("Generated image: \(imageURL)")
}

// Or use the convenience method
let imageURL = try await client.images.generateImageURL(
    prompt: "A cute cat playing with yarn"
)
print("Image URL: \(imageURL)")
```

### Model Information

```swift
// List all models
let models = try await client.models.list()
for model in models {
    print("\(model.id) - \(model.ownedBy)")
}

// Get detailed language model info
let languageModels = try await client.models.listLanguageModels()
for model in languageModels {
    print("\(model.id): \(model.inputModalities ?? [])")
}
```

### Tokenization

```swift
// Tokenize text
let tokens = try await client.tokenization.tokenize(
    text: "Hello, world!",
    model: "grok-3-fast-latest"
)

print("Token count: \(tokens.tokenIds.count)")
```

## CLI Tool

The package includes a comprehensive CLI tool for testing all API features:

```bash
# Build the CLI tool
swift build -c release

# Set your API key
export XAI_API_KEY="your-api-key"

# Chat completion
.build/release/xai-cli chat complete "What is Swift?"

# Streaming chat
.build/release/xai-cli chat stream "Tell me a story"

# Generate an image
.build/release/xai-cli images generate "A cat in space"

# List models
.build/release/xai-cli models list

# Get API key info
.build/release/xai-cli api-key
```

## Configuration

```swift
// Custom configuration
let config = xAIConfiguration(
    apiKey: "your-api-key",
    apiBaseURL: URL(string: "https://api.x.ai")!,
    timeoutInterval: 60,
    useStreaming: true,
    customHeaders: ["X-Custom-Header": "value"]
)

let client = xAIClient(configuration: config)
```

## Error Handling

xAIKit provides comprehensive error handling:

```swift
do {
    let response = try await client.chat.completions(messages: messages, model: model)
} catch let error as xAIError {
    switch error {
    case .invalidAPIKey:
        print("Invalid API key")
    case .rateLimitExceeded(let retryAfter):
        print("Rate limit exceeded. Retry after \(retryAfter ?? 0) seconds")
    case .apiError(let statusCode, let message):
        print("API error \(statusCode): \(message)")
    default:
        print("Error: \(error.localizedDescription)")
    }
}
```

## Documentation

Full API documentation is available through DocC. To build the documentation:

```bash
swift package generate-documentation
```

## Testing

Run the test suite:

```bash
swift test
```

Run tests in Docker:

```bash
docker build -t xaikit .
docker run --rm xaikit swift test
```

## Requirements

- Swift 5.9+
- Platforms:
  - macOS 13+
  - iOS 16+
  - watchOS 9+
  - tvOS 16+
  - visionOS 1+
  - Linux
- xAI API key

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Marcus Ziadé - [@marcusziade](https://github.com/marcusziade)