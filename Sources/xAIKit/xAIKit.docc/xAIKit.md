# ``xAIKit``

A modern, feature-rich Swift SDK for xAI's API, providing comprehensive support for Grok models and advanced AI capabilities.

## Overview

xAIKit delivers a powerful, type-safe Swift interface to xAI's complete API suite, empowering developers to seamlessly integrate cutting-edge AI capabilities into their iOS, macOS, tvOS, watchOS, and visionOS applications. Built with modern Swift concurrency and best practices, xAIKit offers a robust foundation for AI-powered applications.

### Key Features

- **🚀 Complete API Coverage**: Full support for chat completions, messages, image generation, tokenization, and model management
- **🛡️ Type-Safe Architecture**: Leveraging Swift's type system for compile-time safety and predictable behavior
- **⚡ Modern Concurrency**: Native async/await support with structured concurrency throughout
- **📡 Real-Time Streaming**: Efficient streaming responses for interactive, responsive experiences
- **🖼️ Multi-Modal Support**: Handle text and image inputs seamlessly in conversations
- **🎯 Structured Outputs**: JSON schema validation for reliable, structured AI responses
- **🔧 Function Calling**: Enable AI to interact with your application's functions and tools
- **📱 Universal Platform Support**: Runs on iOS 16+, macOS 13+, watchOS 9+, tvOS 16+, and visionOS 1+
- **🧪 Comprehensive Testing**: Extensive test coverage ensuring reliability and stability

## Topics

### Getting Started

- <doc:GettingStarted>
- ``xAIClient``
- ``xAIConfiguration``

### Core APIs

- **Chat Completions**
  - ``ChatRequest``
  - ``ChatResponse``
  - ``StreamChoice``
  - ``FinishReason``
  
- **Messages API**
  - ``MessageRequest``
  - ``MessageResponse``
  - ``MessageContent``
  
- **Image Generation**
  - ``ImageGenerationRequest``
  - ``ImageGenerationResponse``
  - ``GeneratedImage``

### Models and Roles

- ``Model``
- ``Message``
- ``Role``
- ``MessageContent``
- ``LanguageModel``
- ``ImageGenerationModel``

### Advanced Features

- **Structured Outputs**
  - ``ResponseFormat``
  - ``JSONSchema``
  - ``StructuredOutput``
  
- **Function Calling**
  - ``Tool``
  - ``ToolChoice``
  - ``ToolCall``
  - ``FunctionParameter``
  
- **Streaming**
  - ``StreamChoice``
  - ``StreamDelta``
  - ``ChunkChoice``

### Configuration and Management

- **API Management**
  - ``APIKeyInfo``
  - ``APIKeyPermission``
  - ``ModelInfo``
  
- **Tokenization**
  - ``TokenizationRequest``
  - ``TokenizationResponse``
  - ``TokenCount``

### Error Handling

- ``xAIError``
- ``APIError``
- ``APIErrorResponse``
- ``StreamingError``

### Networking

- ``HTTPClient``
- ``HTTPClientProtocol``
- ``SSEParser``

### Platform Integration

- **SwiftUI Support**: Ready-to-use with SwiftUI's modern data flow
- **UIKit Compatibility**: Seamless integration with traditional UIKit apps
- **Background Processing**: Support for background API calls on supported platforms
- **Network Efficiency**: Optimized for mobile data usage and battery life