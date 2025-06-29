# xAIKit

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20visionOS%20%7C%20Linux-blue.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![CI](https://github.com/marcusziade/xAIKit/actions/workflows/ci.yml/badge.svg)](https://github.com/marcusziade/xAIKit/actions/workflows/ci.yml)
[![Documentation](https://img.shields.io/badge/Documentation-DocC-blue.svg)](https://marcusziade.github.io/xAIKit/)

Swift SDK for xAI's API with support for Grok models, image generation, and vision capabilities.

## Features

- **Complete API Coverage** - Chat completions, image generation, vision, and model management
- **Streaming Support** - Real-time streaming responses
- **Type-Safe** - Full Swift type safety and modern concurrency
- **Cross-Platform** - macOS, iOS, tvOS, watchOS, visionOS, and Linux
- **CLI Tool** - Command-line interface for all features

## Installation

Add xAIKit to your Swift package dependencies:

```swift
.package(url: "https://github.com/marcusziade/xAIKit.git", from: "1.0.0")
```

## Quick Start

```swift
import xAIKit

let client = xAIClient(apiKey: "your-api-key")

let response = try await client.chat.completions(
    messages: [ChatMessage(role: .user, content: "Hello!")],
    model: "grok-3-mini-fast-latest"
)

print(response.choices.first?.message.content ?? "")
```

## Documentation

- [🚀 Tutorials](https://marcusziade.github.io/xAIKit/tutorials/xaikit-tutorials) - Step-by-step guides
- [📖 API Reference](https://marcusziade.github.io/xAIKit/documentation/xaikit) - Complete API documentation

## CLI Tool

```bash
export XAI_API_KEY="your-api-key"

# Chat
xai-cli chat complete "What is Swift?"

# Generate image
xai-cli images generate "A futuristic city"

# Analyze image with vision
xai-cli images edit "image-url" "What do you see?" --model grok-2-vision
```

## Requirements

- Swift 5.9+
- macOS 13+, iOS 16+, tvOS 16+, watchOS 9+, visionOS 1+, Linux
- xAI API key from [x.ai](https://x.ai)

## License

MIT - see [LICENSE](LICENSE)