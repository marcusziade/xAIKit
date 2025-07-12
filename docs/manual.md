# xAIKit CLI Manual

This manual provides comprehensive examples of all xAIKit CLI commands with real outputs.

## Table of Contents

- [Setup](#setup)
- [Basic Commands](#basic-commands)
- [Chat Completions](#chat-completions)
- [Messages API](#messages-api)
- [Image Generation](#image-generation)
- [Model Information](#model-information)
- [Tokenization](#tokenization)
- [API Key Information](#api-key-information)
- [Structured Output](#structured-output)

## Setup

First, set your API key as an environment variable:

```bash
export XAI_API_KEY="your-api-key-here"
```

Build the CLI tool:

```bash
swift build
```

The CLI will be available at `.build/debug/xai-cli`

## Basic Commands

### List Available Models

<details>
<summary>View example</summary>

**Command:**
```bash
xai-cli models list
```

**Output:**
```
Available models:
- grok-2-1212 (owned by: xai)
- grok-2-vision-1212 (owned by: xai)
- grok-3 (owned by: xai)
- grok-3-fast (owned by: xai)
- grok-3-mini (owned by: xai)
- grok-3-mini-fast (owned by: xai)
- grok-4-0709 (owned by: xai)
- grok-2-image-1212 (owned by: xai)
```

</details>

## Chat Completions

### Simple Chat Completion

<details>
<summary>View example</summary>

**Command:**
```bash
xai-cli chat complete "What is the capital of France?" --model grok-4-0709
```

**Output:**
```
The capital of France is **Paris**. It's not only the political center but also a global hub for art, fashion, and culture. If you have more questions about France or travel tips, feel free to ask! 😊

---
Model: grok-4-0709
Tokens: 14 prompt + 45 completion = 160 total
```

</details>

### Creative Writing

<details>
<summary>View example</summary>

**Command:**
```bash
xai-cli chat complete "Write a haiku about programming" --model grok-3-fast
```

**Output:**
```
Code flows like a stream,
Lines of logic weave and dream,
Digital thoughts gleam.

---
Model: grok-3-fast
Tokens: 12 prompt + 17 completion = 29 total
```

</details>

### Adjusting Temperature

<details>
<summary>View example</summary>

**Command:**
```bash
xai-cli chat complete "Explain quantum computing in one sentence" --model grok-3-mini-fast --temperature 0.5
```

**Output:**
```
Quantum computing is an advanced form of computing that harnesses quantum mechanical phenomena, such as superposition and entanglement, to perform complex calculations on qubits that can exist in multiple states simultaneously, enabling it to solve certain problems much faster than classical computers.

---
Model: grok-3-mini-fast
Tokens: 12 prompt + 47 completion = 331 total
```

</details>

### Streaming Responses

<details>
<summary>View example</summary>

**Command:**
```bash
xai-cli chat stream "Tell me a joke" --model grok-3-mini-fast
```

**Output:**
```
Why did the computer go to the doctor? Because it had a virus! 😄

Hope that brought a smile to your face—got any more
```

*Note: Streaming responses appear character by character in real-time*

</details>

## Messages API

The Messages API provides Anthropic-compatible message formatting:

<details>
<summary>View example</summary>

**Command:**
```bash
xai-cli messages create "What's the weather like today?" --model grok-3-fast
```

**Output:**
```
I'm sorry, but I don't have access to real-time data like current weather information since my knowledge is up to date only until October 2023. However, I can help you find out the weather by suggesting ways to check it!

- **Use a weather app**: Apps like Weather Underground, AccuWeather, or the default weather app on your phone can give you up-to-date information based on your location.
- **Check online**: Websites like weather.com or bbc.com/weather allow you to search for your city or zip code.
- **Ask a virtual assistant**: If you're using a device with a virtual assistant like Siri, Google Assistant, or Alexa, you can ask them directly for the current weather.
- **Local news**: Tuning into a local news channel or radio station often provides weather updates.

If you tell me your location, I can guide you to a specific resource or let you know about typical weather patterns for that area based on historical data. Where are you located?

---
Model: grok-3-fast
Stop reason: end_turn
Tokens: 12 input + 201 output
```

</details>

## Image Generation

### Generate an Image

<details>
<summary>View example</summary>

**Command:**
```bash
xai-cli images generate "A serene mountain landscape at sunset with a lake" --model grok-2-image-1212
```

**Output:**
```
Generated 1 image(s):

Image 1:
URL: https://imgen.x.ai/xai-imgen/xai-tmp-imgen-d8d46bf7-8544-4ff9-a33f-44c9d066b599.jpeg

Revised prompt: A high-resolution photograph of a serene mountain landscape at sunset, featuring a calm lake that reflects the vibrant colors of the sky. The mountains are silhouetted against a backdrop of deep oranges and purples, with a few clouds enhancing the sunset's beauty. The lake is surrounded by trees that line its edges, adding depth to the scene without distracting from the main focus. The overall composition emphasizes tranquility and natural beauty, with no additional foreground elements to maintain the focus on the sunset and the lake. The scene is devoid of any human presence or modern elements, preserving the untouched nature of the setting.
```

</details>

## Model Information

### Get Specific Model Details

<details>
<summary>View example</summary>

**Command:**
```bash
xai-cli models get grok-4-0709
```

**Output:**
```
Model: grok-4-0709
Created: 2025-07-09 00:00:00 +0000
Owned by: xai
```

</details>

## Tokenization

### Basic Tokenization

<details>
<summary>View example</summary>

**Command:**
```bash
xai-cli tokenize "Hello, world!" --model grok-4-0709
```

**Output:**
```
Token count: 4
Token IDs: [17286, 172, 2314, 161]
```

</details>

### Detailed Tokenization

<details>
<summary>View example</summary>

**Command:**
```bash
xai-cli tokenize "Hello, world!" --model grok-4-0709 --details
```

**Output:**
```
Token count: 4

Tokens:
  ID: 17286, String: 'Hello'
  ID: 172, String: ','
  ID: 2314, String: ' world'
  ID: 161, String: '!'
```

</details>

## API Key Information

<details>
<summary>View example</summary>

**Command:**
```bash
xai-cli api-key
```

**Output:**
```
API Key Information:
  Key: xai-...rKpr
  Name: ultima-cli-linux
  User ID: 2cf429b4-a08e-4ebd-bd9f-f3c7ec1c772d
  Team ID: 575e0d53-b356-407c-a345-d142489020cd
  Created: 
  Modified: 
  Status:
    Disabled: No
    Blocked: No
    Team blocked: No
  Permissions: api-key:endpoint:*, api-key:model:*
```

</details>

## Structured Output

### JSON Object Format (xAI Compatible)

<details>
<summary>View example</summary>

**Command:**
```bash
xai-cli test-structured-output --model grok-3-mini-fast --test-type json-object
```

**Output:**
```
Testing JSON Object Response Format (xAI Compatible)
===================================================

Request Details:
- Model: grok-3-mini-fast
- Response Format Type: json_object

Sending request...

Response:
Content: {"name":"John Doe","age":30,"email":"john.doe@example.com"}

Parsed JSON:
- age: 30
- name: John Doe
- email: john.doe@example.com
```

</details>

## Tips and Best Practices

### Model Selection Guide

- **grok-4-0709**: Most capable model for complex reasoning and analysis
- **grok-3-fast**: Balanced performance and speed for general tasks
- **grok-3-mini-fast**: Fastest responses for simple queries
- **grok-2-image-1212**: Image generation capabilities
- **grok-2-vision-1212**: Image analysis and understanding

### Performance Optimization

1. Use streaming for long responses to improve perceived latency
2. Choose appropriate models based on task complexity
3. Adjust temperature (0-2) for consistency vs creativity:
   - Lower values (0-0.5): More focused and deterministic
   - Higher values (1.5-2): More creative and varied

### Error Handling

Common issues and solutions:

- **Rate Limits**: Implement delays between requests
- **Timeouts**: Use streaming for long-running requests
- **Invalid Models**: Check available models with `xai-cli models list`

## Additional Resources

- [xAIKit GitHub Repository](https://github.com/guitaripod/xAIKit)
- [xAI API Documentation](https://docs.x.ai/)
- [Swift Package Documentation](https://guitaripod.github.io/xAIKit/)