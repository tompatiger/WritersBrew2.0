# WritersBrew 2.0

WritersBrew is an actively developed native Mac writing studio focused on the page, project memory, personal voice, trust, and native macOS craft. It combines an AppKit/TextKit editing surface with SwiftUI application chrome and optional, contextual writing assistance.

The product direction is “writing instrument first, AI product second.” The editor, documents, search, recovery, versions, and export must stand on their own when AI is hidden.

## Current state

This repository is a substantial prototype, not a production-ready release. It currently includes:

- an `NSTextView`-backed editor with focus and typography controls;
- projects, chapters, standalone documents, and JSON-backed local persistence;
- Ghost Writer chat/actions with OpenAI, Anthropic, Gemini, Ollama, and offline heuristic implementations;
- preliminary Storyboard/Project Memory, prose analysis, Voice Skill, version snapshots, themes, and export;
- a macOS XCTest target covering credential migration, provider resolution, document creation/round-trip, analyzer behavior, and voice behavior.

Known architectural and product gaps are deliberately documented rather than hidden. In particular, editor AI is not yet truly caret-aware, Project Memory is not yet project-isolated, and the current persistence layer still needs atomic/debounced writes and recovery. See the implementation plan.

## Product and engineering documents

- [Master Vision v1.2](WritersBrew_Master_Vision_v1.2.md) — current working product direction
- [Implementation Plan](IMPLEMENTATION-PLAN.md) — audited P0/P1/P2 roadmap and acceptance criteria
- [Architecture](ARCHITECTURE.md) — target boundaries and incremental migration plan
- [UX Specification](UX-SPEC.md) — intended writing, AI, Craft Lens, version, and keyboard flows
- [Master Vision v1.1](WritersBrew_Master_Vision_v1.1.md) — retained historical draft

## Requirements

- macOS 15.0 or later (current deployment target)
- A recent Xcode capable of opening project object version 77 (the project was created with Xcode 16.4)
- No third-party dependencies

The target currently uses Swift 5 language mode and SwiftUI/AppKit platform frameworks.

## Build and run

Open `WritersBrew.xcodeproj`, select the shared `WritersBrew` scheme, and Run on My Mac.

Command-line build:

```sh
xcodebuild \
  -project WritersBrew.xcodeproj \
  -scheme WritersBrew \
  -configuration Debug \
  -destination 'platform=macOS' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Run tests (no live API calls are made):

```sh
xcodebuild \
  -project WritersBrew.xcodeproj \
  -scheme WritersBrew \
  -configuration Debug \
  -destination 'platform=macOS' \
  CODE_SIGNING_ALLOWED=NO \
  test
```

## Privacy and AI providers

- OpenAI, Anthropic, Gemini, and xAI credentials are stored in macOS Keychain, not `UserDefaults`.
- Legacy credentials from older builds are migrated to Keychain and removed from `UserDefaults` only after a successful Keychain write.
- Provider selection is exact: an unconfigured cloud provider returns a configuration error and is never silently replaced with a different provider.
- OpenAI, Anthropic, and Gemini are implemented as cloud, full-response clients. True transport streaming is not yet implemented.
- xAI credentials can be stored, but xAI generation is explicitly unavailable until its transport is implemented correctly.
- Ollama is the currently implemented local-model connection. MLX is not implemented.
- Offline Creative runs locally without a network request, but it is a heuristic/template engine—not a local language model.

Provider keys are entered in WritersBrew Settings. Never commit credentials to this repository.

## Local data

The current prototype stores library and storyboard JSON under the user's Application Support `WritersBrew` directory. This format is being preserved while the planned schema versioning, atomic writes, recovery, Trash, and version-retention work is introduced incrementally.

## Contributing

Start with `IMPLEMENTATION-PLAN.md`. Preserve user data, avoid silent AI/provider behavior, keep network and analysis work off the typing path, and add deterministic production-code tests for behavioral changes.
