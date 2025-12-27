# Unison UCM Dev Container Feature

[![Build and Test](https://github.com/kn0ll/unison-devcontainer-feature/actions/workflows/test.yaml/badge.svg)](https://github.com/kn0ll/unison-devcontainer-feature/actions/workflows/test.yaml)

A [Dev Container Feature](https://containers.dev/features) that installs the [Unison Codebase Manager (UCM)](https://www.unison-lang.org/) CLI.

## Features

| Feature | Description |
|---------|-------------|
| [ucm](src/ucm) | Installs the Unison Codebase Manager (UCM) CLI |

## Usage

Add this feature to your `devcontainer.json`:

```jsonc
{
  "name": "My Dev Container",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/kn0ll/unison-devcontainer/ucm:1": {}
  }
}
```

### Options

```jsonc
{
  "features": {
    "ghcr.io/kn0ll/unison-devcontainer/ucm:1": {
      "version": "latest"  // or a specific version like "1.0.1"
    }
  }
}
```

## What is Unison?

[Unison](https://www.unison-lang.org/) is a modern, statically-typed purely functional programming language. It uses a unique content-addressed approach where definitions are identified by their content hash rather than by name.

### Key Features

- **Content-addressed code**: No more merge conflicts on refactoring
- **Built-in distributed computing support**: Send code to remote nodes
- **UCM (Unison Codebase Manager)**: Interactive CLI for managing code
- **Structural typing and editing**: Revolutionary code management

## Development

### Testing Locally

```bash
# Install the devcontainer CLI
npm install -g @devcontainers/cli

# Test the feature
devcontainer features test \
  --features ucm \
  --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
  --project-folder .
```

### Publishing

The feature is automatically published to GitHub Container Registry when changes are pushed to the `main` branch.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Unison Language](https://www.unison-lang.org/) - The Unison programming language team
- [Dev Containers](https://containers.dev/) - The Dev Container specification and tools
