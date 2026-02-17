# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ai-agent-lab** is a Node.js project that wraps [OpenClaw](https://github.com/openclaw/openclaw) (v2026.2.15), a multi-channel AI gateway and personal assistant platform. OpenClaw connects to messaging platforms (WhatsApp, Telegram, Slack, Discord, Signal, Google Chat, iMessage, Microsoft Teams, Matrix, WebChat, and more) and routes messages through an AI agent with tool access.

## Setup

- **Runtime:** Node >= 22.12.0
- **Package manager:** npm (OpenClaw source uses pnpm; bun also works)
- **Module type:** CommonJS (root project); OpenClaw itself is ESM

```bash
npm install
```

## Running OpenClaw

```bash
# Onboarding wizard (first-time setup)
npx openclaw onboard --install-daemon

# Start the gateway
npx openclaw gateway --port 18789 --verbose

# Send a message
npx openclaw message send --to <recipient> --message "Hello"

# Run the agent directly
npx openclaw agent --message "prompt" --thinking high

# Diagnostics
npx openclaw doctor
```

## Architecture

```
Messaging Channels (WhatsApp/Telegram/Slack/Discord/etc.)
         │
         ▼
┌─────────────────────────┐
│   Gateway (WS control   │  ws://127.0.0.1:18789
│   plane)                │  Sessions, presence, config, cron, webhooks
└────────────┬────────────┘
             │
             ├─ Pi Agent (RPC) — LLM agent with tool streaming
             ├─ CLI (openclaw ...)
             ├─ WebChat UI
             ├─ macOS app (menu bar)
             └─ iOS / Android nodes
```

**Key subsystems:**
- **Gateway** — WebSocket control plane managing sessions, channels, tools, events, and the Control UI/WebChat
- **Pi Agent Runtime** — LLM agent runner (RPC mode) with tool streaming and block streaming
- **Session Model** — `main` sessions for direct chats, group isolation, activation modes, queue modes
- **Media Pipeline** — Image/audio/video handling, transcription, size caps
- **Plugin SDK** — Extensible via `openclaw/plugin-sdk` exports (TypeScript types at `dist/plugin-sdk/`)
- **Skills** — 40+ bundled integrations in `skills/` (Apple Notes, GitHub, Notion, Obsidian, etc.)
- **Extensions** — Additional channel integrations in `extensions/` (Teams, Matrix, Zalo, IRC, LINE, etc.)

**CLI commands:** `gateway`, `agent`, `send`, `message`, `tui`, `onboard`, `wizard`, `doctor`, `dashboard`, `pairing`, `update`

## Configuration

- Config file: `~/.openclaw/openclaw.json` (JSON5 format)
- Workspace: `~/.openclaw/workspace/` with `AGENTS.md`, `SOUL.md`, `TOOLS.md`
- Skills: `~/.openclaw/workspace/skills/<skill>/SKILL.md`
- Credentials: `~/.openclaw/credentials/`

Minimal config:
```json5
{
  agent: {
    model: "anthropic/claude-opus-4-6",
  },
}
```

Full reference: https://docs.openclaw.ai/gateway/configuration

## OpenClaw Development (from source)

If cloning the OpenClaw source for development:

```bash
git clone https://github.com/openclaw/openclaw.git && cd openclaw
pnpm install
pnpm ui:build
pnpm build
```

**Dev loop:** `pnpm gateway:watch` (auto-reload on TS changes)

**Testing (Vitest):**
- `pnpm test` — parallel unit tests
- `pnpm test:fast` — quick unit tests only (`vitest.unit.config.ts`)
- `pnpm test:e2e` — end-to-end tests (`vitest.e2e.config.ts`)
- `pnpm test:live` — live model tests (requires `OPENCLAW_LIVE_TEST=1`, uses `vitest.live.config.ts`)
- `pnpm test:watch` — watch mode
- `pnpm test:coverage` — coverage with v8

**Linting & formatting:**
- `pnpm lint` — oxlint (type-aware)
- `pnpm lint:fix` — auto-fix lint + format
- `pnpm format` — oxfmt
- `pnpm check` — format check + TypeScript + lint (full CI check)

**Build tooling:** tsdown (bundler), oxfmt (formatter), oxlint (linter), tsc (type definitions)

## Security Notes

- Inbound DMs are **untrusted input** — default `dmPolicy="pairing"` requires approval codes
- Main session tools run on the host with full access
- Non-main sessions (groups/channels) can be sandboxed via Docker: `agents.defaults.sandbox.mode: "non-main"`
