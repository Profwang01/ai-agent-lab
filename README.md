# ai-agent-lab

A Node.js project wrapping [OpenClaw](https://github.com/openclaw/openclaw) (v2026.2.15), a multi-channel AI gateway and personal assistant platform.

OpenClaw connects to messaging platforms (WhatsApp, Telegram, Slack, Discord, Signal, Google Chat, iMessage, Microsoft Teams, Matrix, WebChat, and more) and routes messages through an AI agent with tool access.

## Architecture

```
Messaging Channels (WhatsApp/Telegram/Slack/Discord/etc.)
         |
         v
+-------------------------+
|   Gateway (WS control   |  ws://127.0.0.1:18789
|   plane)                |  Sessions, presence, config, cron, webhooks
+------------+------------+
             |
             +-- Pi Agent (RPC) -- LLM agent with tool streaming
             +-- CLI (openclaw ...)
             +-- WebChat UI
             +-- macOS app (menu bar)
             +-- iOS / Android nodes
```

## Prerequisites

- Node.js >= 22.12.0
- pnpm (recommended) or npm
- An LLM API key (e.g. Anthropic, OpenAI, Google Gemini)

## Setup

```bash
# Install dependencies
pnpm install

# First-time onboarding
npx openclaw onboard --install-daemon
```

## Configuration

Config file: `~/.openclaw/openclaw.json` (JSON5 format)

Minimal config:

```json5
{
  agents: {
    defaults: {
      model: {
        primary: "anthropic/claude-opus-4-6"
      }
    }
  },
  env: {
    ANTHROPIC_API_KEY: "sk-ant-YOUR_KEY_HERE"
  }
}
```

### Supported LLM Providers

| Provider | Environment Variable |
|----------|---------------------|
| Anthropic | `ANTHROPIC_API_KEY` |
| OpenAI | `OPENAI_API_KEY` |
| Google Gemini | `GEMINI_API_KEY` |
| xAI | `XAI_API_KEY` |
| OpenRouter | `OPENROUTER_API_KEY` |
| Mistral | `MISTRAL_API_KEY` |
| Groq | `GROQ_API_KEY` |

## Usage

```bash
# Run the agent locally
npx openclaw agent --local --agent main --message "Hello"

# Start the gateway
npx openclaw gateway --port 18789 --verbose

# Send a message via gateway
npx openclaw agent --agent main --message "Hello"

# Diagnostics
npx openclaw doctor
```

## License

ISC
