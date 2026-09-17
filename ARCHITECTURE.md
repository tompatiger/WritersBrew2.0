# WritersBrew Architecture

This is the intended architecture and migration direction. It is not a claim that the current prototype already conforms to it. Migration should be incremental, data-compatible, and covered by tests.

## 1. Architectural Goals

- Keep typing, selection, and undo independent from persistence, analysis, and networking.
- Separate shared durable content from per-window and per-editor state.
- Make provider choice, credentials, persistence failures, and AI context explicit.
- Support deterministic unit tests without writing into a developer's real Application Support or Keychain data.
- Preserve the current JSON data while introducing schemas and recoverability.

## 2. State Ownership

### `LibraryStore`

Shared durable application data:

- projects, folders, and documents;
- project-scoped Project Memory entities;
- document versions and Trash metadata;
- persistence orchestration and error state.

`LibraryStore` may be shared across windows, but it must not own the active document for every window. Mutations should be explicit methods that can schedule persistence. A protocol-backed persistence dependency allows in-memory tests.

The current `DocumentStore.shared` combines durable data, global UI selection, seed behavior, and direct file I/O. Keep it operational during migration, introduce injection seams, then move responsibilities in small batches.

### `WorkspaceSession`

Per-window transient state:

- selected project and document;
- navigator selection/filter;
- sidebar and inspector visibility;
- inspector mode (`ghost`, `craft`, `project`);
- focus mode and window-specific navigation.

Each `WindowGroup` scene creates its own session. This prevents multiple windows from changing each other's selection while retaining one durable library.

### `EditorSession`

Per-editor transient state:

- caret position and selected UTF-16 range;
- selected text, text before caret, and text after caret;
- document/project identity captured with the context;
- pending AI request and immutable edit target;
- preview result and insertion/replacement intent;
- cancellation and undo transaction state.

Editor context must be emitted by the `NSTextView` bridge and validated against the document revision before applying an AI result. Stale operations are never silently applied to a different range.

## 3. Editor Boundary

SwiftUI owns layout and high-level state. AppKit/TextKit owns native text editing behavior. The bridge should:

- report text and selection/caret changes;
- preserve valid selections during external model updates;
- expose focused editor commands;
- apply AI edits through the text system/undo manager;
- convert ranges explicitly as UTF-16 `NSRange` values;
- avoid whole-document attribute churn on each keystroke;
- respect accessibility and text services.

An `EditorContext` value should be immutable and contain document ID, project ID, document revision, selection, caret, selected text, bounded text before/after the caret, and request timestamp.

## 4. Persistence Boundary

Introduce a `LibraryPersistence` protocol around encoded payload load/save/recovery. The first production implementation can retain JSON while adding:

- an envelope with schema version;
- atomic replacement writes;
- debounced saves from a serial actor/task;
- a last-known-good backup before replacement;
- recovery from backup with a visible diagnostic;
- surfaced errors rather than `try?` suppression;
- injectable URLs for tests;
- explicit first-launch sample creation rather than treating any empty/corrupt library as first launch.

Deletion should move records to a recoverable Trash model. Versions should eventually be stored with retention rules rather than allowing unbounded payload growth inside each document.

Migration order: read legacy payload → map into current in-memory model → write versioned envelope only after a successful mutation/save → retain backup. Never destroy the legacy file before a verified new write.

## 5. Credential Boundary

`CredentialStore` is the only component that reads or writes provider API credentials. Its production implementation uses macOS Keychain Services with an app-specific service name and provider account names. It exposes no logging or enumeration of secret values.

`PreferencesStore` retains only non-secret choices: active provider, endpoint URL, editor settings, and feature toggles. On initialization it performs a one-time, idempotent migration for each legacy `UserDefaults` key:

1. Read a non-empty legacy value.
2. Write it to Keychain.
3. Verify the Keychain operation succeeded.
4. Remove the legacy default only after success.
5. Surface migration failure without printing the value.

Tests use an in-memory credential store and isolated `UserDefaults` suite.

## 6. AI Service and Provider Boundaries

### Provider description

Provider metadata is separate from the transport object and includes stable ID, display name, default model, local/cloud kind, implementation availability, configuration status, genuine streaming support, and supported operations.

### Provider resolution

A provider factory/resolver receives preferences and credentials and returns either the exact selected provider or a typed error. It never silently returns a different provider. Offline Creative is selected only when the user explicitly chooses it.

### Transport

`LLMProvider` performs generation for one declared provider/model. Batch 1 may keep full-response APIs, but those providers report `supportsStreaming == false`. Later transports may expose genuine incremental streams.

### Errors and UI

Typed errors distinguish unconfigured, unavailable, invalid response, network, and context-size failures. UI displays configuration status before invocation and an actionable error after failure.

## 7. Project Memory Context Assembly

Project Memory entities gain `projectId`. Relationships use entity IDs with migration support for current names. A dedicated context assembler receives:

- current project/document IDs;
- explicitly enabled context chips;
- selected entity IDs;
- size/privacy limits.

It returns an inspectable context manifest plus the serialized prompt content. It never reads all global entities by default. Existing global prototype records require a user-visible migration choice or deterministic association where evidence is unambiguous.

## 8. Versioning and Recovery Boundary

- Automatic versions occur at meaningful checkpoints, not every keystroke.
- Manual versions remain explicit.
- Restore creates a new version before changing current content.
- Diff and copy do not mutate the manuscript.
- Recovery journals/last-known-good snapshots are operational safeguards, distinct from writer-visible versions.
- Retention and cleanup policies are explicit and testable.

## 9. Concurrency

- UI-observed stores/sessions are `@MainActor` where appropriate.
- File encoding/writes and analysis execute away from the typing event path.
- Saves are ordered so an older task cannot overwrite newer content.
- AI work is cancellable and its result is checked against the captured edit target.
- Provider transports do not mutate editor state directly.

## 10. Testing Strategy

- A real XCTest bundle imports the production app module with `@testable`.
- Stores accept temporary directories, isolated defaults, and in-memory credential stores.
- No test performs a live AI request or touches the user's real credentials/library.
- Unit coverage prioritizes migrations, provider resolution, model relationships, editor range calculations, persistence recovery, analyzer signals, and voice preference updates.
- UI tests are added after stable accessibility identifiers and core flows exist.

## 11. Incremental Migration Sequence

1. Add Keychain-backed credentials and truthful provider resolution/capabilities.
2. Establish a test target and inject safe storage dependencies.
3. Add `EditorSession`/`EditorContext` and undo-aware range operations.
4. Move window selection into `WorkspaceSession`.
5. Harden JSON persistence behind `LibraryPersistence`.
6. Migrate Project Memory to project scope and stable relationships.
7. Consolidate the right side into a single mode-based Inspector.

Each step must leave the app buildable and legacy data readable.
