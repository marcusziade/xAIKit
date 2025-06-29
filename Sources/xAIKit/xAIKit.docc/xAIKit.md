# ``xAIKit``

A modern Swift SDK for xAI's API, including support for Grok models.

## Overview

xAIKit provides a clean, type-safe Swift interface to xAI's API, enabling developers to integrate powerful AI capabilities into their iOS, macOS, tvOS, watchOS, and visionOS applications.

### Features

- **Complete API Coverage**: Full support for xAI's chat completions API
- **Type-Safe**: Leveraging Swift's type system for safe, predictable code
- **Modern Concurrency**: Built with async/await and structured concurrency
- **Streaming Support**: Real-time streaming responses for interactive experiences
- **Cross-Platform**: Works on all Apple platforms
- **Well-Tested**: Comprehensive test coverage

## Topics

### Essentials

- <doc:GettingStarted>
- ``xAIClient``
- ``ChatRequest``
- ``ChatResponse``

### Models

- ``Model``
- ``Message``
- ``Role``
- ``StreamChoice``

### Advanced Features

- ``ToolChoice``
- ``ResponseFormat``
- ``FinishReason``

### Error Handling

- ``xAIError``
- ``APIError``