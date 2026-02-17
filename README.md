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

# Open WebChat UI (after gateway is running)
# Visit http://127.0.0.1:18789/__openclaw__/canvas/

# Diagnostics
npx openclaw doctor
npx openclaw doctor --fix   # Auto-fix detected issues
```

## Current Status (Doctor Diagnostics)

Last checked: 2026-02-17

| Component | Status | Details |
|-----------|--------|---------|
| Gateway | OK | `ws://127.0.0.1:18789`, mode: local |
| Agent (main) | OK | Model: `anthropic/claude-opus-4-6` |
| WebChat UI | OK | `http://127.0.0.1:18789/__openclaw__/canvas/` |
| Security | OK | No channel security warnings |
| Skills | OK | 5 eligible, 44 missing requirements |
| Plugins | OK | 4 loaded, 32 disabled, 0 errors |
| LINE Channel | OK | Connected via ngrok webhook tunnel |
| Memory Search | Not configured | No embedding provider set (see below) |
| Other Channels | Not configured | Telegram, Discord, Slack, etc. not yet added |

### Memory Search (TODO)

Memory Search is enabled by default but currently **not functional** because no embedding provider is configured. Semantic recall will not work until this is resolved.

To enable it later, pick one of the following:

```bash
# Option 1: Add an OpenAI or Gemini key for embeddings
npx openclaw auth add --provider openai
# or set OPENAI_API_KEY / GEMINI_API_KEY in ~/.openclaw/openclaw.json env block

# Option 2: Configure local embeddings
# Set agents.defaults.memorySearch.provider and local model path in config

# Option 3: Explicitly disable (suppress doctor warnings)
npx openclaw config set agents.defaults.memorySearch.enabled false

# Verify status
npx openclaw memory status --deep
```

### LINE Channel (Connected)

LINE Messaging API is connected. Setup requires:

1. A [LINE Developers Console](https://developers.line.biz/console/) account with a Messaging API channel
2. **Channel Access Token** and **Channel Secret** added to `~/.openclaw/openclaw.json`:

   ```json5
   {
     channels: {
       line: {
         enabled: true,
         channelAccessToken: "YOUR_TOKEN",
         channelSecret: "YOUR_SECRET",
         dmPolicy: "open",
         webhookPath: "/line"
       }
     }
   }
   ```

3. A public HTTPS URL for the webhook (e.g. via [ngrok](https://ngrok.com/)):

   ```bash
   ngrok http 18789
   # Set the resulting URL + /line as Webhook URL in LINE Developers Console
   ```

### Other Messaging Channels (TODO)

Other channels (Telegram, Discord, Slack, WhatsApp, etc.) are not yet connected. Add bot tokens to `~/.openclaw/openclaw.json` as needed. WhatsApp uses QR code pairing and does not require a token.

## License

ISC
