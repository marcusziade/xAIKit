#!/usr/bin/env swift

import Foundation

let html = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>xAIKit - Swift SDK for xAI</title>
    <style>
        :root {
            --xai-black: #000000;
            --xai-white: #FFFFFF;
            --xai-blue: #1E90FF;
            --xai-dark-blue: #0066CC;
            --xai-light-blue: #4DA6FF;
            --xai-gray: #666666;
            --xai-light-gray: #F5F5F5;
            --xai-border: #E0E0E0;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--xai-white);
            color: var(--xai-black);
            line-height: 1.6;
        }
        
        .hero {
            background: linear-gradient(135deg, var(--xai-black) 0%, #1a1a1a 100%);
            color: var(--xai-white);
            padding: 120px 0;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        
        .hero::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, var(--xai-blue) 0%, transparent 70%);
            opacity: 0.1;
            animation: pulse 8s ease-in-out infinite;
        }
        
        @keyframes pulse {
            0%, 100% { transform: scale(1); opacity: 0.1; }
            50% { transform: scale(1.1); opacity: 0.15; }
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            position: relative;
            z-index: 1;
        }
        
        h1 {
            font-size: 3.5em;
            font-weight: 700;
            margin-bottom: 20px;
            letter-spacing: -1px;
        }
        
        .tagline {
            font-size: 1.5em;
            color: var(--xai-light-blue);
            margin-bottom: 40px;
            font-weight: 300;
        }
        
        .buttons {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .button {
            display: inline-block;
            padding: 16px 32px;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            font-size: 1.1em;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }
        
        .button:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(30, 144, 255, 0.3);
        }
        
        .button.primary {
            background-color: var(--xai-blue);
            color: var(--xai-white);
        }
        
        .button.primary:hover {
            background-color: var(--xai-dark-blue);
        }
        
        .button.secondary {
            background-color: transparent;
            color: var(--xai-white);
            border-color: var(--xai-white);
        }
        
        .button.secondary:hover {
            background-color: var(--xai-white);
            color: var(--xai-black);
        }
        
        .features {
            padding: 80px 0;
            background-color: var(--xai-light-gray);
        }
        
        .features h2 {
            text-align: center;
            font-size: 2.5em;
            margin-bottom: 60px;
            color: var(--xai-black);
        }
        
        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 30px;
        }
        
        .feature-card {
            background: var(--xai-white);
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            transition: all 0.3s ease;
            border: 1px solid var(--xai-border);
        }
        
        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            border-color: var(--xai-blue);
        }
        
        .feature-card h3 {
            font-size: 1.5em;
            margin-bottom: 15px;
            color: var(--xai-black);
        }
        
        .feature-card p {
            color: var(--xai-gray);
            line-height: 1.8;
        }
        
        .platforms {
            padding: 80px 0;
            text-align: center;
            background-color: var(--xai-white);
        }
        
        .platforms h2 {
            font-size: 2.5em;
            margin-bottom: 40px;
            color: var(--xai-black);
        }
        
        .platform-icons {
            display: flex;
            justify-content: center;
            gap: 40px;
            flex-wrap: wrap;
            margin-top: 40px;
        }
        
        .platform-icon {
            font-size: 3em;
            color: var(--xai-gray);
            transition: color 0.3s ease;
        }
        
        .platform-icon:hover {
            color: var(--xai-blue);
        }
        
        .code-example {
            padding: 80px 0;
            background-color: var(--xai-black);
            color: var(--xai-white);
        }
        
        .code-example h2 {
            text-align: center;
            font-size: 2.5em;
            margin-bottom: 40px;
            color: var(--xai-white);
        }
        
        pre {
            background-color: #0a0a0a;
            border: 1px solid #333;
            border-radius: 8px;
            padding: 30px;
            overflow-x: auto;
            font-size: 1em;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
        }
        
        code {
            font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', monospace;
        }
        
        .keyword { color: var(--xai-blue); }
        .string { color: #50C878; }
        .comment { color: #666; }
        .function { color: var(--xai-light-blue); }
        
        footer {
            background-color: var(--xai-black);
            color: var(--xai-white);
            padding: 40px 0;
            text-align: center;
            border-top: 1px solid #333;
        }
        
        footer a {
            color: var(--xai-light-blue);
            text-decoration: none;
            margin: 0 15px;
            transition: color 0.3s ease;
        }
        
        footer a:hover {
            color: var(--xai-white);
        }
        
        @media (max-width: 768px) {
            h1 {
                font-size: 2.5em;
            }
            
            .tagline {
                font-size: 1.2em;
            }
            
            .buttons {
                flex-direction: column;
                align-items: center;
            }
            
            .button {
                width: 200px;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <section class="hero">
        <div class="container">
            <h1>xAIKit</h1>
            <p class="tagline">Swift SDK for xAI's Powerful Language Models</p>
            <div class="buttons">
                <a href="documentation/xaikit/" class="button primary">View Documentation</a>
                <a href="tutorials/xaikit-tutorials" class="button secondary">Tutorials</a>
            </div>
        </div>
    </section>
    
    <section class="features">
        <div class="container">
            <h2>Why xAIKit?</h2>
            <div class="feature-grid">
                <div class="feature-card">
                    <h3>🚀 Modern Swift</h3>
                    <p>Built with Swift's latest features including async/await, structured concurrency, and type-safe APIs for the best developer experience.</p>
                </div>
                <div class="feature-card">
                    <h3>⚡ Real-time Streaming</h3>
                    <p>Support for streaming responses enables you to build interactive experiences with real-time AI feedback.</p>
                </div>
                <div class="feature-card">
                    <h3>🛡️ Type-Safe</h3>
                    <p>Leverage Swift's powerful type system to catch errors at compile time and write more reliable code.</p>
                </div>
                <div class="feature-card">
                    <h3>📱 Cross-Platform</h3>
                    <p>Works seamlessly across all Apple platforms - iOS, macOS, tvOS, watchOS, and visionOS.</p>
                </div>
                <div class="feature-card">
                    <h3>🤖 Grok Models</h3>
                    <p>Access xAI's advanced Grok models with their powerful reasoning and conversation capabilities.</p>
                </div>
                <div class="feature-card">
                    <h3>📚 Well Documented</h3>
                    <p>Comprehensive documentation and interactive tutorials help you get started quickly and efficiently.</p>
                </div>
            </div>
        </div>
    </section>
    
    <section class="platforms">
        <div class="container">
            <h2>Build for Every Apple Platform</h2>
            <div class="platform-icons">
                <span class="platform-icon">📱</span>
                <span class="platform-icon">💻</span>
                <span class="platform-icon">📺</span>
                <span class="platform-icon">⌚</span>
                <span class="platform-icon">🥽</span>
                <span class="platform-icon">🐧</span>
            </div>
            <p style="margin-top: 20px; color: var(--xai-gray);">iOS 16+ • macOS 13+ • tvOS 16+ • watchOS 9+ • visionOS 1+ • Linux</p>
        </div>
    </section>
    
    <section class="code-example">
        <div class="container">
            <h2>Simple & Powerful</h2>
            <pre><code><span class="keyword">import</span> xAIKit

<span class="comment">// Initialize the client</span>
<span class="keyword">let</span> client = <span class="function">xAIClient</span>(apiKey: <span class="string">"your-api-key"</span>)

<span class="comment">// Create a chat completion</span>
<span class="keyword">let</span> response = <span class="keyword">try await</span> client.chat.<span class="function">completions</span>(
    messages: [
        <span class="function">ChatMessage</span>(role: .user, content: <span class="string">"Explain quantum computing"</span>)
    ],
    model: <span class="string">"grok-3-mini-fast-latest"</span>
)

<span class="comment">// Print the response</span>
<span class="function">print</span>(response.choices.first?.message.content ?? <span class="string">""</span>)</code></pre>
        </div>
    </section>
    
    <footer>
        <div class="container">
            <div style="margin-top: 20px;">
                <a href="https://github.com/marcusziade/xAIKit">GitHub</a>
                <a href="documentation/xaikit/">Documentation</a>
                <a href="tutorials/xaikit-tutorials">Tutorials</a>
            </div>
        </div>
    </footer>
</body>
</html>
"""

// Create docs directory if it doesn't exist
let fileManager = FileManager.default
let docsPath = "./docs"

do {
    try fileManager.createDirectory(atPath: docsPath, withIntermediateDirectories: true, attributes: nil)
    
    // Write the HTML file
    let indexPath = "\(docsPath)/index.html"
    try html.write(toFile: indexPath, atomically: true, encoding: .utf8)
    
    print("✅ Successfully created landing page at: \(indexPath)")
} catch {
    print("❌ Error creating landing page: \(error)")
    exit(1)
}