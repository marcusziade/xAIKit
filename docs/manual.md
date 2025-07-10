# xAIKit CLI Manual

This manual provides comprehensive examples of all xAIKit CLI commands with their outputs.

## Table of Contents

- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Command Reference](#command-reference)
  - [Main Help](#main-help)
  - [Chat Commands](#chat-commands)
  - [Messages API](#messages-api)
  - [Image Generation](#image-generation)
  - [Model Information](#model-information)
  - [Tokenization](#tokenization)
  - [API Key Information](#api-key-information)
  - [Legacy Completion](#legacy-completion)
  - [Structured Output Testing](#structured-output-testing)

## Installation

```bash
# Build from source
swift build

# The CLI will be available at:
.build/debug/xai-cli
```

## Basic Usage

All commands require an API key, which can be provided via:
- `--api-key` flag
- `XAI_API_KEY` environment variable

```bash
export XAI_API_KEY="your-api-key-here"
```

## Command Reference

### Main Help

<details>
<summary>View command: <code>xai-cli -h</code></summary>

```
OVERVIEW: A command-line interface for testing the xAI API

USAGE: xai-cli <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  chat                    Chat completion commands
  messages                Messages API commands (Anthropic compatible)
  images                  Image generation commands
  models                  Model information commands
  tokenize                Tokenize text
  api-key                 Get API key information
  complete                Legacy completion commands
  test-structured-output  Test structured output functionality (json_object for
                          xAI, json_schema for OpenAI)

  See 'xai-cli help <subcommand>' for detailed help.
```

</details>

### Chat Commands

<details>
<summary>View command: <code>xai-cli chat -h</code></summary>

```
OVERVIEW: Chat completion commands

USAGE: xai-cli chat [--api-key <api-key>] [--api-url <api-url>] <subcommand>

OPTIONS:
  --api-key <api-key>     API key (defaults to XAI_API_KEY environment variable)
  --api-url <api-url>     API base URL
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  complete                Create a chat completion
  stream                  Create a streaming chat completion

  See 'xai-cli help chat <subcommand>' for detailed help.
```

</details>

#### Chat Complete

<details>
<summary>View command: <code>xai-cli chat complete -h</code></summary>

```
OVERVIEW: Create a chat completion

USAGE: xai-cli chat complete [--api-key <api-key>] [--api-url <api-url>] <message> [--model <model>] [--system <system>] [--max-tokens <max-tokens>] [--temperature <temperature>] [--json]

ARGUMENTS:
  <message>               The message to send

OPTIONS:
  --api-key <api-key>     API key
  --api-url <api-url>     API base URL
  --model <model>         The model to use (default: grok-3-mini-fast-latest)
  --system <system>       System prompt
  --max-tokens <max-tokens>
                          Maximum tokens to generate
  --temperature <temperature>
                          Temperature (0-2)
  --json                  Output raw JSON response
  --version               Show the version.
  -h, --help              Show help information.
```

</details>

<details>
<summary>Example: Simple chat completion with Grok-4</summary>

```bash
$ xai-cli chat complete "Hello, what is 2+2?" --model grok-4-0709
```

Output:
```
Hello! 2 + 2 equals 4. 😊 If that's not what you meant or if you have a trickier question, feel free to elaborate!

---
Model: grok-4-0709
Tokens: 16 prompt + 33 completion = 209 total
```

</details>

#### Chat Stream

<details>
<summary>Example: Streaming chat completion</summary>

```bash
$ xai-cli chat stream "Tell me a short joke" --model grok-4-0709
```

Output:
```
Why don't scientists trust atoms?

Because they make up everything!

---
Model: grok-4-0709
Tokens: 7 prompt + 14 completion = 21 total
```

</details>

### Messages API

<details>
<summary>View command: <code>xai-cli messages -h</code></summary>

```
OVERVIEW: Messages API commands (Anthropic compatible)

USAGE: xai-cli messages [--api-key <api-key>] [--api-url <api-url>] <subcommand>

OPTIONS:
  --api-key <api-key>     API key
  --api-url <api-url>     API base URL
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  create                  Create a message
  stream                  Create a streaming message

  See 'xai-cli help messages <subcommand>' for detailed help.
```

</details>

<details>
<summary>View command: <code>xai-cli messages create -h</code></summary>

```
OVERVIEW: Create a message

USAGE: xai-cli messages create [--api-key <api-key>] [--api-url <api-url>] <message> [--model <model>] [--system <system>] [--max-tokens <max-tokens>] [--temperature <temperature>] [--json]

ARGUMENTS:
  <message>               The message to send

OPTIONS:
  --api-key <api-key>     API key
  --api-url <api-url>     API base URL
  --model <model>         The model to use (default: grok-3-fast-latest)
  --system <system>       System prompt
  --max-tokens <max-tokens>
                          Maximum tokens to generate (default: 1024)
  --temperature <temperature>
                          Temperature (0-1)
  --json                  Output raw JSON response
  --version               Show the version.
  -h, --help              Show help information.
```

</details>

### Image Generation

<details>
<summary>View command: <code>xai-cli images -h</code></summary>

```
OVERVIEW: Image generation commands

USAGE: xai-cli images [--api-key <api-key>] [--api-url <api-url>] <subcommand>

OPTIONS:
  --api-key <api-key>     API key
  --api-url <api-url>     API base URL
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  generate                Generate images
  analyze                 Analyze an image using vision-capable chat models

  See 'xai-cli help images <subcommand>' for detailed help.
```

</details>

<details>
<summary>View command: <code>xai-cli images generate -h</code></summary>

```
OVERVIEW: Generate images

USAGE: xai-cli images generate [--api-key <api-key>] [--api-url <api-url>] <prompt> [--model <model>] [--n <n>] [--size <size>] [--quality <quality>] [--style <style>] [--base64]

ARGUMENTS:
  <prompt>                The prompt for image generation

OPTIONS:
  --api-key <api-key>     API key
  --api-url <api-url>     API base URL
  --model <model>         The model to use (default: grok-2-image)
  --n <n>                 Number of images to generate (default: 1)
  --size <size>           Image size (default: 1024x1024)
  --quality <quality>     Image quality (standard/hd) - Note: May not be
                          supported by xAI
  --style <style>         Image style (vivid/natural) - Note: May not be
                          supported by xAI
  --base64                Output base64 instead of URL
  --version               Show the version.
  -h, --help              Show help information.
```

</details>

### Model Information

<details>
<summary>View command: <code>xai-cli models list</code></summary>

```bash
$ xai-cli models list
```

Output:
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

### Tokenization

<details>
<summary>View command: <code>xai-cli tokenize -h</code></summary>

```
OVERVIEW: Tokenize text

USAGE: xai-cli tokenize [--api-key <api-key>] [--api-url <api-url>] <text> [--model <model>] [--details]

ARGUMENTS:
  <text>                  Text to tokenize

OPTIONS:
  --api-key <api-key>     API key
  --api-url <api-url>     API base URL
  --model <model>         Model to use for tokenization (default:
                          grok-3-fast-latest)
  --details               Show token details
  --version               Show the version.
  -h, --help              Show help information.
```

</details>

<details>
<summary>Example: Tokenize text</summary>

```bash
$ xai-cli tokenize "Hello world" --model grok-4-0709
```

Output:
```
Token count: 2
Token IDs: [17286, 2314]
```

</details>

### API Key Information

<details>
<summary>View command: <code>xai-cli api-key -h</code></summary>

```
OVERVIEW: Get API key information

USAGE: xai-cli api-key [--api-key <api-key>] [--api-url <api-url>]

OPTIONS:
  --api-key <api-key>     API key
  --api-url <api-url>     API base URL
  --version               Show the version.
  -h, --help              Show help information.
```

</details>

### Legacy Completion

<details>
<summary>View command: <code>xai-cli complete -h</code></summary>

```
OVERVIEW: Legacy completion commands

USAGE: xai-cli complete [--api-key <api-key>] [--api-url <api-url>] <subcommand>

OPTIONS:
  --api-key <api-key>     API key
  --api-url <api-url>     API base URL
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  openai                  Create a completion (OpenAI legacy format)
  anthropic               Create a completion (Anthropic legacy format)

  See 'xai-cli help complete <subcommand>' for detailed help.
```

</details>

### Structured Output Testing

<details>
<summary>View command: <code>xai-cli test-structured-output -h</code></summary>

```
OVERVIEW: Test structured output functionality (json_object for xAI,
json_schema for OpenAI)

USAGE: xai-cli test-structured-output [--api-key <api-key>] [--api-url <api-url>] [--model <model>] [--test-type <test-type>] [--json] [--no-structured]

OPTIONS:
  --api-key <api-key>     API key
  --api-url <api-url>     API URL
  --model <model>         Model to use (default: grok-3-mini-fast)
  --test-type <test-type> Test type: simple, complex, json-object, or all
                          (default: all)
  --json                  Output raw JSON response
  --no-structured         Disable structured output format (for APIs that don't
                          support it)
  --version               Show the version.
  -h, --help              Show help information.
```

</details>

## Environment Variables

- `XAI_API_KEY`: Your xAI API key
- `XAI_API_URL`: Override the default API base URL

## Tips and Best Practices

1. **Model Selection**: Use appropriate models for your use case:
   - `grok-4-0709`: Most capable model for complex tasks
   - `grok-3-fast`: Good balance of speed and capability
   - `grok-3-mini-fast`: Fastest model for simple tasks
   - `grok-2-image-1212`: For image generation
   - `grok-2-vision-1212`: For image analysis

2. **Streaming**: Use streaming for better user experience with long outputs
3. **Temperature**: Adjust temperature (0-2) for creativity vs consistency
4. **JSON Output**: Use `--json` flag to get raw API responses for debugging

## Error Handling

Common errors and solutions:

1. **Missing API Key**: Set `XAI_API_KEY` environment variable or use `--api-key` flag
2. **Invalid Model**: Check available models with `xai-cli models list`
3. **Rate Limits**: Implement appropriate delays between requests
4. **Network Issues**: Check your internet connection and API URL

## Additional Resources

- [xAIKit GitHub Repository](https://github.com/marcusziade/xAIKit)
- [xAI API Documentation](https://docs.x.ai/)
- [Swift Package Documentation](https://swiftpackageindex.com/marcusziade/xAIKit)