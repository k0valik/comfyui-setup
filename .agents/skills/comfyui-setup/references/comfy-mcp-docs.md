**Public beta.** Comfy MCP is in public beta. APIs, tools, and behavior may change while we iterate. See [Feedback](#feedback) to report issues or share suggestions.

## Overview

**Comfy MCP** connects AI agents to ComfyUI over the [Model Context Protocol](https://modelcontextprotocol.io/). Once connected, you can generate images, video, audio and 3D, search models, nodes and templates, and run real ComfyUI workflows from a chat with your agent.

It comes with two connections: a **Comfy Cloud** connection and a **local ComfyUI** connection, with the local one fully open source.

**Stuck on anything below? The best way is to hand this page to your agent and ask for help.**

### Which connection do I want?

**For new users, we recommend starting with the cloud connection** — it is the simplest setup. If you use claude.ai, ChatGPT, or the Claude Desktop chat app, the cloud connection is also the more compatible choice.

**If you already run ComfyUI locally or in your own deployed environment, or you work mostly in a coding agent** like Claude Code, Cursor, or Codex, start with the **local** connection.

**For Mac users, if you plan to run open-source models, we recommend the cloud connection.** Today’s open-weight models — the local versions of MiniMax H3, LTX-2.3, and similar — are large, and will not run at a workable speed on the Apple GPU.

Running both at once is normal, and most clients host two MCP servers happily. They sign in to the same Comfy account, but **separately** — one sign-in does not cover the other.



## Local Comfy MCP Connection

The open-source connection: your client launches the server on your machine and it drives the ComfyUI installed there.

[**comfy-mcp**](https://github.com/Comfy-Org/comfy-mcp) is Comfy’s **first-party local MCP server** — the official way to drive a **local** ComfyUI install from AI agents (Claude Code, Claude Desktop, Cursor, and other MCP clients).

Unlike the cloud and partner servers, it talks to the ComfyUI running on **your own machine** — so it can run your workflows and inspect the nodes, custom nodes, and models your install actually has.

**The fastest setup: hand it to your agent.** Paste `https://docs.comfy.org/agent-tools/mcp#installation` into your AI client and ask it to set up the local connection for you.

### Requirements

- **Python 3.10+**
- **[comfy-cli](https://github.com/Comfy-Org/comfy-cli)** on your `PATH` (`pip install "comfy-cli>=1.14.0"`) — the engine every tool wraps
- **A ComfyUI workspace** — create one with `comfy install` if you don’t have one (an existing checkout works via `comfy set-default <path>`)
- **A running ComfyUI for execution tools.** Start it with `comfy launch`, or call `launch_comfyui`. The server does not launch ComfyUI implicitly.

---

### Installation

From [PyPI](https://pypi.org/project/comfy-mcp/):

```shellscript
pip install comfy-mcp
```

This puts a `comfy-mcp` console script on your `PATH` — that command is the MCP server (it speaks MCP over stdio). Point your AI client at it below. (Hacking on the server itself? `pip install -e .` from a checkout of the [repository](https://github.com/Comfy-Org/comfy-mcp) instead.)

**`COMFY_BIN` (optional).** MCP clients launch the server with their own environment, which often does **not** include your shell’s `PATH`. If `comfy` lives in a virtualenv or a non-standard location, set `COMFY_BIN` to its absolute path (for example `/path/to/venv/bin/comfy`). Every client example below shows where it goes; drop it if `comfy` is already on the environment your client launches the server with.

---

### Manual configuration

All clients speak the same MCP stdio contract: run the `comfy-mcp` command as a server. Pick your client:

- Claude Desktop
- Claude Code
- Cursor

Edit `claude_desktop_config.json` (Settings → Developer → Edit Config; on macOS it lives at `~/Library/Application Support/Claude/claude_desktop_config.json`), add the server, then restart Claude Desktop:

```json
{
  "mcpServers": {
    "comfy-mcp": {
      "command": "comfy-mcp",
      "env": { "COMFY_BIN": "/path/to/venv/bin/comfy" }
    }
  }
}
```

One command registers the server:

```shellscript
claude mcp add comfy-mcp -e COMFY_BIN=/path/to/venv/bin/comfy -- comfy-mcp
```

Or check it into a project with a `.mcp.json` at the repo root:

```json
{
  "mcpServers": {
    "comfy-mcp": {
      "command": "comfy-mcp",
      "env": { "COMFY_BIN": "/path/to/venv/bin/comfy" }
    }
  }
}
```

Add the server to `~/.cursor/mcp.json` (global) or `.cursor/mcp.json` (per project):

```json
{
  "mcpServers": {
    "comfy-mcp": {
      "command": "comfy-mcp",
      "env": { "COMFY_BIN": "/path/to/venv/bin/comfy" }
    }
  }
}
```

---

### Quickstart

Zero to a generated image:

---

### Tools

Each tool maps onto a `comfy-cli` command, run with `--where local`. Highlights:

| Tool | Purpose |
| --- | --- |
| `server_info()` | Is a local ComfyUI running, where, and which workspace. **Call first.** |
| `run_workflow(workflow_path, wait=True)` | Run a workflow JSON; `wait=False` submits async and returns a `prompt_id`. |
| `job_status` / `wait_for_job` / `watch_job` | Poll, wait on, or stream a submitted job. |
| `fetch_outputs(prompt_id, out_dir)` | Copy a finished job’s outputs into `out_dir`. |
| `launch_comfyui` / `stop_comfyui` | Start or stop the local ComfyUI. |
| `search_templates` / `fetch_template` | Find a built-in template and write its runnable workflow JSON. |
| `search_nodes` / `get_node` / `list_nodes` | Inspect the node classes in your **live local** install (custom nodes included). |
| `search_models` | List the model files on disk. |
| `validate_workflow` | Pre-flight a workflow against the live `object_info` before a slow run. |

Node introspection and model search read your **live install** — custom nodes included — which is the local differentiator from the cloud connection. See the [repository](https://github.com/Comfy-Org/comfy-mcp) for the full tool list and reference.

---

## Related resources

| Resource | What it’s for |
| --- | --- |
| [Comfy Skills](https://github.com/Comfy-Org/comfy-skills/) | Claude Code plugin marketplace and community skill library. The **comfy-cloud** plugin used above is distributed here; browse or contribute additional skills for Comfy workflows. |
| [Comfy Cloud on ClawHub](https://clawhub.ai/comfy-org/skills/comfy) | OpenClaw skill (`openclaw skills install @comfy-org/comfy`) for the hosted Comfy Cloud MCP server. |
| [Comfy CLI](https://docs.comfy.org/agent-tools/cli) | Command-line tool for local ComfyUI install/launch and for calling hosted partner nodes from scripts or CI (`comfy generate`, in beta). Complements MCP when you need terminal or automation workflows. |
| [Share a workflow on Comfy Cloud](https://docs.comfy.org/cloud/share-workflow) | Share workflows from the Comfy Cloud UI (the MCP `share_workflow` tool does this from an agent session). |

## Related: Comfy In-App Agent

Want the agent experience **inside** Comfy Cloud (chat that builds and edits your graph), not an external MCP client?

## [Comfy In-App Agent](https://docs.comfy.org/agent-tools/in-app-agent)

Private alpha on Comfy Cloud. Join the waitlist to request access.

## Feedback

Comfy MCP is in public beta. Please try it out and tell us what works and what doesn’t:

- **[Feedback survey](https://links.comfy.org/cloudmcpbeta)**: report bugs, request features, or share general impressions.
- **Discord**: [#comfy-mcp-and-cli](https://discord.gg/xWJn6nhE3R) on the Comfy Discord for questions and discussion.

## FAQ

### Getting started

Which clients are supported?

Any MCP-compatible client.

The **cloud connection** needs remote HTTP support. **Claude Code**, **Claude Desktop**, **Cursor**, **Codex** and **OpenClaw** have first-class setup above; **Windsurf**, **Amp** and others use the same URL with OAuth or an API key.

The **local connection** needs a client that can launch a local stdio server as a subprocess. That rules out browser-based clients. [claude.ai](https://claude.ai/) and ChatGPT accept remote connectors only.

What's the server URL?

The cloud connection runs at `https://cloud.comfy.org/mcp`.

The local connection has no URL. Your client launches the `comfy-mcp` command directly and talks to it over stdio.

Can I use it with my local ComfyUI?

Yes. That is the [Local Comfy MCP Connection](#local-comfy-mcp-connection). It drives the ComfyUI installed on your own machine, so your agent sees the models, LoRAs and custom nodes you actually have, and runs on your GPU.

Can I connect both the cloud and local connections at once?

Yes, and we recommend it if you run ComfyUI locally. Most clients host two MCP servers happily, and your agent keeps them straight. Each connection runs its own workflows and returns its own results.

The two sign-ins are **separate**, though. Signing in on one does not sign you in on the other, even though it is the same Comfy account.

How do I know if my machine can run the local connection?

Ask your agent. It reads your hardware before starting anything heavy.

On a **Mac**, use the cloud connection for generating: today’s open-weight models are too large to run at a workable speed on the Apple GPU. On a **PC with a dedicated graphics card**, 24 GB or more of VRAM handles most things including video; 8–24 GB is fine for images but video will be slow or will not fit; under 8 GB, use cloud.

Is it generally available?

The cloud connection is in **public beta**. APIs, tools and behavior may change while we iterate. The local connection is available for local ComfyUI installations. See [Feedback](#feedback) to report issues.

### Cost and access

Does it cost anything?

Discovery is free on both connections: searching templates, models and nodes needs only a Comfy account.

On the **cloud connection**, running generations requires an active Comfy Cloud subscription; new users get 5 free runs. On the **local connection**, runs are free because they happen on your hardware, with one exception: partner models execute on partner infrastructure and spend credits.

Do I need an API key?

Not for interactive clients that support OAuth, including Claude Code, Claude Desktop, Codex and OpenClaw.

**Cursor** requires a Comfy Cloud API key in your MCP config; there is no MCP OAuth there yet. Headless and CI setups with no browser need one too. See the **Cursor** and **Other clients** tabs under [Set up the cloud connection](#set-up-the-cloud-connection).

### Using it

What can my agent do once connected?

You do not call MCP tools yourself — your agent picks them based on what you ask for. Typically it **discovers** what is available (`search_templates`, `search_models`, `search_nodes`), **runs** a generation, then **waits and retrieves** the output. See [What your agent can do](#what-your-agent-can-do).

Where do my outputs go?

On the **cloud connection**, the server never writes to your machine: `get_output` returns a temporary signed URL and a ready-to-run download command for your agent to execute in your shell. See [Uploads and downloads](#uploads-and-downloads).

On the **local connection**, ComfyUI writes into your workspace’s `output/` directory, and `fetch_outputs(prompt_id, out_dir)` copies a finished job’s files anywhere you name.

I started on one connection and now I need the other. What do I do?

Nothing to undo — add the second connection alongside the first.

Going **local → cloud** (you need Cloud GPUs or partner models): ask your agent to sign you in, then add `https://cloud.comfy.org/mcp` to your client.

Going **cloud → local** (you want your own models and custom nodes): install ComfyUI and the local server, then point your client at it. Your agent can do most of this for you.

How do I switch between the local and cloud connections?

Just ask your agent. With both connections added, say where you want a job to run — “run this one on Comfy Cloud”, “do this locally” — and it uses the right connection. There is no mode to toggle and nothing to reconfigure between runs.

If a workflow turns out to be too heavy for your machine, your agent can tell you and offer to run it on Comfy Cloud instead. And if only one connection is set up, ask it to add the other — see [Set up the cloud connection](#set-up-the-cloud-connection) or the [Local Comfy MCP Connection](#local-comfy-mcp-connection).

How do I update Comfy MCP?

On the **cloud connection**, nothing to do — it is hosted, so you are always on the current version.

On the **local connection**, ask your agent to handle it. Afterwards, **restart your client** or start a new session: MCP servers load when a session starts, so a running one keeps serving the old version until you do.

### Troubleshooting

Do slash commands work in Claude Desktop?

No. Slash commands ship in the Claude Code plugin. Claude Desktop connects to the same MCP server — the tools work if you ask in plain language or use the prompt picker — but it does not support Claude Code plugins or slash commands.

I typed /comfy or /cloud and nothing came up.

There is no `/comfy` or `/cloud` command. Commands appear under one of two prefixes depending on how you connected:

- **Plugin (recommended):** `/comfy-cloud:generate-image`, `/comfy-cloud:generate-video`, … — type `/comfy-cloud:` to see them all.
- **Direct connection (no plugin):** `/mcp__comfy-cloud__generate-image`, … — type `/mcp__` to see them.

Either way you can just ask in plain language (“generate an image of …”). The MCP tools are model-invoked and do not require a slash command.

The sign-in did not open a browser.

In Claude Code, run `/mcp`, select **comfy-cloud**, and choose **Authenticate**. In Claude Desktop, reopen the connector from **Customize → Connectors** and trigger sign-in.