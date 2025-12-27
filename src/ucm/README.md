# Unison UCM (ucm)

Installs the [Unison Codebase Manager (UCM)](https://www.unison-lang.org/) CLI for the Unison programming language.

## Example Usage

```json
"features": {
    "ghcr.io/kn0ll/unison-devcontainer/ucm:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version of UCM to install. | string | latest |

## Customizations

### VS Code Extensions

- `unison-lang.unison` - Official Unison language extension with syntax highlighting, LSP integration, autocomplete, and more.

## What is Unison?

[Unison](https://www.unison-lang.org/) is a modern, statically-typed purely functional language. Unison has a unique approach to managing code: definitions are identified by content, not by name. This makes refactoring, code sharing, and distributed programming much easier.

### Key Features

- **Content-addressed code**: Functions and types are identified by their content hash
- **Built-in support for distributed computing**: Code can be sent to remote nodes
- **Structured editing**: No more text-based merge conflicts
- **Codebase Manager (UCM)**: Interactive CLI for managing Unison code

## Getting Started

After installing, you can start UCM by running:

```bash
ucm
```

For a new project, run:

```bash
ucm init
```

For more information, see the [Unison documentation](https://www.unison-lang.org/docs/).

## OS Support

This Feature should work on recent versions of:

- **Debian/Ubuntu** and derivatives
- **RHEL/Fedora/CentOS/Rocky Linux/Alma Linux**
- **Alpine Linux**
- **macOS** (Intel and Apple Silicon)

Both `x86_64` (amd64) and `aarch64` (arm64) architectures are supported.

`bash` is required to execute the `install.sh` script.

## Source

This feature downloads UCM from the official [Unison GitHub releases](https://github.com/unisonweb/unison/releases).

---

_Note: This file was auto-generated from the [devcontainer-feature.json](devcontainer-feature.json). Add additional notes to a `NOTES.md`._
