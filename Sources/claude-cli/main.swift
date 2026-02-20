import Foundation

// MARK: - API Types

struct MessagesRequest: Encodable {
    let model: String
    let max_tokens: Int
    let system: String?
    let messages: [Message]

    struct Message: Encodable {
        let role: String
        let content: String
    }
}

struct MessagesResponse: Decodable {
    let content: [ContentBlock]
    let usage: Usage?
    let stop_reason: String?

    struct ContentBlock: Decodable {
        let type: String
        let text: String?
    }
    struct Usage: Decodable {
        let input_tokens: Int
        let output_tokens: Int
    }
}

struct APIError: Decodable {
    let error: ErrorDetail
    struct ErrorDetail: Decodable {
        let type: String
        let message: String
    }
}

// MARK: - Argument Parsing

struct Args {
    var model = "claude-sonnet-4-6"
    var maxTokens = 4096
    var system: String? = nil
    var prompt: String = ""
    var verbose = false

    static func parse() -> Args {
        var args = Args()
        let argv = CommandLine.arguments.dropFirst()
        var positional: [String] = []
        var iter = argv.makeIterator()

        while let arg = iter.next() {
            switch arg {
            case "--model", "-m":
                if let val = iter.next() { args.model = val }
            case "--max-tokens", "-t":
                if let val = iter.next(), let n = Int(val) { args.maxTokens = n }
            case "--system", "-s":
                if let val = iter.next() { args.system = val }
            case "--verbose", "-v":
                args.verbose = true
            case "--help", "-h":
                printUsage()
                exit(0)
            default:
                positional.append(arg)
            }
        }

        if !positional.isEmpty {
            args.prompt = positional.joined(separator: " ")
        }

        return args
    }

    static func printUsage() {
        let help = """
        claude-cli — Call the Claude API from the command line

        USAGE:
            claude-cli [OPTIONS] "your prompt here"
            echo "your prompt" | claude-cli [OPTIONS]

        OPTIONS:
            -m, --model <MODEL>        Model ID (default: claude-sonnet-4-6)
            -t, --max-tokens <N>       Max output tokens (default: 4096)
            -s, --system <PROMPT>      System prompt
            -v, --verbose              Show model, tokens used, stop reason
            -h, --help                 Show this help

        ENVIRONMENT:
            ANTHROPIC_API_KEY          Required. Your Anthropic API key.

        EXAMPLES:
            claude-cli "Explain monads in one sentence"
            claude-cli -m claude-opus-4-6 "Review this code"
            echo "Summarize this" | claude-cli -t 200
            cat file.swift | claude-cli -s "You are a code reviewer" "Review this code"
        """
        FileHandle.standardError.write(Data(help.utf8))
    }
}

// MARK: - Main

func main() async throws {
    let args = Args.parse()

    guard let apiKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"], !apiKey.isEmpty else {
        FileHandle.standardError.write(Data("Error: ANTHROPIC_API_KEY environment variable not set\n".utf8))
        exit(1)
    }

    // Read prompt from args or stdin
    var prompt = args.prompt
    if prompt.isEmpty {
        if isatty(fileno(stdin)) != 0 {
            FileHandle.standardError.write(Data("Error: No prompt provided. Pass as argument or pipe via stdin.\n".utf8))
            Args.printUsage()
            exit(1)
        }
        let stdinData = FileHandle.standardInput.availableData
        if let stdinStr = String(data: stdinData, encoding: .utf8) {
            prompt = stdinStr.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    // If there's stdin AND positional args, combine: stdin becomes context, args become instruction
    if !args.prompt.isEmpty && isatty(fileno(stdin)) == 0 {
        let stdinData2 = FileHandle.standardInput.availableData
        if let stdinStr = String(data: stdinData2, encoding: .utf8),
           !stdinStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            prompt = stdinStr + "\n\n" + args.prompt
        }
    }

    guard !prompt.isEmpty else {
        FileHandle.standardError.write(Data("Error: Empty prompt\n".utf8))
        exit(1)
    }

    // Build request
    let body = MessagesRequest(
        model: args.model,
        max_tokens: args.maxTokens,
        system: args.system,
        messages: [.init(role: "user", content: prompt)]
    )

    var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
    request.httpMethod = "POST"
    request.timeoutInterval = 300  // 5 minutes — Opus can be slow on long responses
    request.setValue("application/json", forHTTPHeaderField: "content-type")
    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
    request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

    let encoder = JSONEncoder()
    request.httpBody = try encoder.encode(body)

    // Make request
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 300
    config.timeoutIntervalForResource = 300
    let session = URLSession(configuration: config)
    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
        FileHandle.standardError.write(Data("Error: Invalid response\n".utf8))
        exit(1)
    }

    if httpResponse.statusCode != 200 {
        if let apiErr = try? JSONDecoder().decode(APIError.self, from: data) {
            FileHandle.standardError.write(Data("Error \(httpResponse.statusCode): \(apiErr.error.message)\n".utf8))
        } else {
            let body = String(data: data, encoding: .utf8) ?? "unknown"
            FileHandle.standardError.write(Data("Error \(httpResponse.statusCode): \(body)\n".utf8))
        }
        exit(1)
    }

    let result = try JSONDecoder().decode(MessagesResponse.self, from: data)

    // Output text blocks
    let text = result.content
        .compactMap(\.text)
        .joined()

    print(text)

    // Verbose info to stderr
    if args.verbose {
        var info = "--- \(args.model)"
        if let usage = result.usage {
            info += " | \(usage.input_tokens) in / \(usage.output_tokens) out"
        }
        if let stop = result.stop_reason {
            info += " | \(stop)"
        }
        info += " ---"
        FileHandle.standardError.write(Data("\(info)\n".utf8))
    }
}

try await main()
