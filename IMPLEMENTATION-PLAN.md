# WritersBrew Implementation Plan

This plan is grounded in the September 2026 repository audit. Priorities favor correctness, trust, and product coherence over feature count.

## Audit Summary

The repo contains a promising native macOS prototype: an `NSTextView`-backed editor, document/project models, JSON persistence, Ghost Writer surfaces, cloud provider clients, an Ollama client, heuristic offline assistance, storyboard UI, analyzer heuristics, a preliminary voice model, and basic export/version snapshots.

Verified issues:

- Continue uses whole-document content and inserts at the end; selection Ask Ghost drops the selection; Ghost inserts append.
- Storyboard entities are global, with several name-based relationships.
- JSON writes are synchronous, non-atomic, immediate, and error-suppressed; deletion is permanent; decoding failure can lead to sample seeding.
- API keys are stored in `UserDefaults`.
- Missing cloud credentials silently resolve to Offline Creative; Grok routes through the OpenAI endpoint; all cloud “streams” wait for a complete response; Ollama is labeled Ollama/MLX.
- Offline Creative is a heuristic/template engine and includes nondeterministic continuations.
- Analyzer UI presents a synthetic universal percentage/quality label.
- Voice learning is seeded with fictional data and mainly extracts long words from accepted AI output.
- Theme moods force dark mode and type design despite separate editor preferences.
- `DocumentStore.shared` owns selection across windows.
- the right side can show Ghost and Analyzer simultaneously.
- several displayed shortcut hints are not wired; Command-S creates a version rather than following standard save expectations.
- `Tests/WritersBrewTests.swift` is a standalone assertion script; the Xcode project has no test target.
- README is effectively empty; `.DS_Store` and user workspace state are tracked.

## P0 — Trust and Correctness

### P0.1 Editor Context Model

**Problem:** AI actions do not have a durable, precise caret/selection target. Continue and proactive acceptance append; Ask Ghost discards its selection.

**Affected:** `FocusEditorView`, `MacEditorTextView`, `GhostWriterSidebar`, app commands, new `EditorSession`/`EditorContext` types.

**Proposed change:** Emit an immutable context containing caret, UTF-16 selection, selected text, bounded before/after text, document/project IDs, and document revision. Capture it per operation, validate before apply, and perform insertion/replacement through `NSTextView` as one undo transaction.

**Dependencies:** Per-window session ownership; stable document revision or content fingerprint; command routing to the focused editor.

**Risks:** UTF-16/String index mismatch, stale async targets, undo corruption, selection loss during SwiftUI updates.

**Acceptance criteria:** Continue inserts at the exact caret; rewrite replaces the exact captured selection; Ask Ghost retains selection context; stale targets cannot mutate unexpected text; typing remains responsive.

**Tests required:** Context calculation at start/middle/end and emoji; insertion; replacement; stale revision rejection; undo/redo; selection propagation.

### P0.2 Project Isolation

**Problem:** Characters, locations, and timeline events form one global universe; timeline relationships use display names.

**Affected:** storyboard models/views, `DocumentStore`/future `LibraryStore`, AI context assembly, persisted storyboard JSON.

**Proposed change:** Add project ownership and stable relationship IDs, then provide project-filtered APIs. Read legacy global records with a migration state; associate automatically only when unambiguous, otherwise ask the user or retain in an “Unassigned” recovery bucket.

**Dependencies:** Persistence schema envelope and current-project selection.

**Risks:** Orphaned legacy data, duplicate names, accidental cross-project context, irreversible migration.

**Acceptance criteria:** Every entity is project-owned or explicitly unassigned; AI receives only current-project entities by default; renamed entities keep relationships; legacy data remains readable/recoverable.

**Tests required:** Legacy decode, per-project filtering, rename stability, unassigned migration, context isolation.

### P0.3 Persistence Trust

**Problem:** Direct synchronous JSON writes use `try?`, are not explicitly atomic, have no schema/recovery status, and permanent deletion. Decode failure is indistinguishable from first launch.

**Affected:** `DocumentStore`, document/version models, Application Support files, library UI.

**Proposed change:** Preserve JSON but introduce an injectable persistence boundary, schema-versioned envelope, ordered debounced atomic saves, last-known-good backup, visible failure state, explicit first-launch marker, recovery loading, Trash, and version retention strategy.

**Dependencies:** Test target and storage injection; migration fixtures.

**Risks:** save reordering, backup of corrupt data, schema mistakes, disk-full handling, duplicate sample data.

**Acceptance criteria:** Typing does not synchronously write; failed writes are reported; interruption cannot destroy the last good library; legacy payload round-trips; corrupt input is quarantined rather than overwritten; deletion is recoverable.

**Tests required:** legacy/current round-trip, atomic replacement, simulated write failure, backup recovery, corrupt file quarantine, debounce ordering, Trash restore.

### P0.4 Secrets — Foundation Batch 1

**Problem:** Raw provider keys are stored in `UserDefaults`.

**Affected:** `PreferencesStore`, Settings, AI provider construction, new `CredentialStore`.

**Proposed change:** Store OpenAI, Anthropic, Gemini, and xAI credentials in macOS Keychain. Migrate legacy defaults idempotently and remove a legacy value only after successful Keychain write. Keep non-secrets in defaults.

**Dependencies:** Security framework; injectable credential/defaults stores.

**Risks:** Keychain access failure, migration loops, accidental deletion before save, test pollution of real Keychain.

**Acceptance criteria:** no raw key is written to defaults; Settings reads/writes Keychain; all four legacy keys migrate; failed migration retains the legacy value and exposes an error; secrets are never logged.

**Tests required:** successful migration/removal, empty value handling, failed-write retention, credential update/delete using in-memory stores; production Keychain compilation.

### P0.5 Provider Truth — Foundation Batch 1

**Problem:** provider labels and runtime behavior overclaim availability/streaming/local technology; missing credentials silently substitute a heuristic engine; xAI uses the wrong endpoint.

**Affected:** provider protocol/types, `AIService`, Settings, Ghost header, provider implementations.

**Proposed change:** Add capability/status metadata and exact provider resolution. Implement xAI against its documented OpenAI-compatible xAI endpoint or mark unavailable. Report full-response cloud/Ollama clients as non-streaming. Rename Ollama and Offline Creative honestly. Never substitute providers.

**Dependencies:** Credential store.

**Risks:** existing users see configuration errors where hidden fallback previously appeared successful; model names can age.

**Acceptance criteria:** selected provider is the invoked provider or a typed error is returned; status shows provider/model/local-cloud/configuration/streaming truth; no MLX claim; xAI does not use OpenAI's host; heuristic assistance is labeled as such.

**Tests required:** resolver matrix for every provider and configured state; capability assertions; xAI endpoint request test if feasible without network; no-fallback regression.

### P0.6 Real XCTest Baseline — Foundation Batch 1

**Problem:** no test target exists; the current script asserts duplicated literals rather than production behavior.

**Affected:** Xcode project/scheme, `Tests`, production initialization seams.

**Proposed change:** Add a macOS XCTest target importing the app module. Replace the script with deterministic tests of models, analyzer, voice engine, provider resolution, credential migration, and isolated document/project creation.

**Dependencies:** injectable defaults/credentials/library URL; no live services.

**Risks:** singleton initialization can touch real user data; project-file edits can break scheme configuration.

**Acceptance criteria:** `xcodebuild test` discovers and executes XCTest cases against production types; no test uses live APIs, real Application Support, or real credentials; no “100% healthy” placeholder assertions remain.

**Tests required:** the suite itself, plus a clean Debug build and test run.

### P0.7 Multi-window State Isolation

**Problem:** `DocumentStore.shared` owns global selection/filter state, so windows interfere.

**Affected:** app scene creation, `MainAppView`, sidebar, new `WorkspaceSession`.

**Proposed change:** Create one workspace session per window and keep only durable library data shared.

**Dependencies:** Library/session split.

**Risks:** binding churn, window restoration complexity.

**Acceptance criteria:** two windows can select different documents and inspector modes without changing each other.

**Tests required:** session unit tests; multi-window UI test after identifiers exist.

## P1 — Core UX and Product Coherence

### P1.1 Single Mode-based Inspector

**Problem:** Ghost and Analyzer can occupy simultaneous competing columns.

**Affected:** `MainAppView`, toolbar, Ghost/Analyzer/Project views.

**Proposed change:** One Inspector container with Ghost, Craft, and Project modes, retained per window.

**Dependencies:** `WorkspaceSession`; project filtering.

**Risks:** reduced discoverability if mode switching is unclear.

**Acceptance criteria:** only one right inspector is visible; canvas remains dominant; mode/visibility restore per window.

**Tests required:** state transitions, keyboard command, accessibility labels.

### P1.2 Craft Lens Reframing

**Problem:** heuristic metrics are presented as a universal quality score and synchronous analysis runs on text changes.

**Affected:** analysis models/service, analyzer UI, editor scheduling.

**Proposed change:** Remove score/quality verdict UI, expose descriptive signals with evidence ranges/method notes, and debounce/background analysis.

**Dependencies:** editor range/highlight path.

**Risks:** sentence tokenization/range mapping errors; analysis cost on large documents.

**Acceptance criteria:** no universal prose score; every actionable signal includes evidence; clicking evidence highlights text; typing path is unaffected.

**Tests required:** deterministic signal/evidence ranges, empty/Unicode/large input, debounce cancellation.

### P1.3 Theme Separation

**Problem:** canvas mood forces color scheme and typography.

**Affected:** `ThemeMood`, preferences, Settings, editor, shell.

**Proposed change:** independent Appearance, Canvas Mood, and Typography preferences with a backward-compatible mapping from saved moods.

**Dependencies:** preference migration.

**Risks:** visual regressions and low-contrast combinations.

**Acceptance criteria:** changing mood does not change appearance/typeface; System tracks macOS; accessibility contrast remains acceptable.

**Tests required:** preference migration and setting independence; visual/accessibility review.

### P1.4 Native Commands and Honest Hints

**Problem:** multiple shown shortcuts are not implemented; Command-S creates a version snapshot.

**Affected:** app commands, toolbar help, editor focus routing, UX copy.

**Proposed change:** implement/validate canonical commands from `UX-SPEC.md`, remove stale hints, and reserve standard save semantics.

**Dependencies:** editor/workspace sessions.

**Risks:** collisions with system text commands.

**Acceptance criteria:** every visible hint works from the relevant focus state; menu titles accurately describe behavior.

**Tests required:** command validation and focused-editor UI coverage.

### P1.5 Import, Export, Search, Versions, and Trash

**Problem:** export is limited and errors are silent; search scope/filter behavior is incomplete; versions have no browser/diff/restore; deletion is immediate.

**Affected:** library UI/store, export service, version views, models.

**Proposed change:** make file operations error-aware and safe; implement portable Markdown/plain text first, then evaluated DOCX/PDF; add document search, version browser/diff/restore, and Trash.

**Dependencies:** persistence hardening.

**Risks:** malformed HTML escaping, file access/sandbox behavior, version storage growth.

**Acceptance criteria:** export failures are visible; generated formats preserve content safely; search results open correctly; version restore is reversible; Trash can restore.

**Tests required:** export escaping/round-trip, search filters, version restoration, Trash lifecycle.

### P1.6 Accessibility and Reduced Effects

**Problem:** extensive material and spring effects do not consistently respond to accessibility settings; focus dimming mutates text attributes broadly.

**Affected:** component styles, editor, transitions, all inspectors.

**Proposed change:** centralize reduced-motion/transparency behavior, audit VoiceOver labels/focus, and ensure focus visuals do not alter semantic text accessibility.

**Dependencies:** stabilized shell/editor.

**Risks:** inconsistent fallback appearance.

**Acceptance criteria:** complete core flows with keyboard/VoiceOver; reduced settings produce legible stable UI.

**Tests required:** accessibility audit, UI navigation tests, manual system-setting matrix.

## P2 — Deeper Intelligence

### P2.1 Transparent Voice Profile

**Problem:** current claims exceed the heuristic evidence and prioritize accepted AI prose over author prose.

**Affected:** voice models/engine/UI, context assembly.

**Proposed change:** separate explicit preferences, author-prose observations, AI preference signals, and cited examples. Remove fictional seeded metrics.

**Dependencies:** evidence ranges, versions, project/document sampling consent.

**Risks:** false inference, privacy expectations, feedback loops from AI-authored text.

**Acceptance criteria:** observations are editable/removable and source-backed; author prose is primary; AI-origin text is labeled and weighted secondarily.

**Tests required:** source weighting, edits/removals, prompt serialization, reset/migration.

### P2.2 Project Memory Depth

**Problem:** current Storyboard is fiction-centric and shallowly integrated.

**Affected:** Project Memory models/UI/context assembler.

**Proposed change:** support people, places, events, concepts/lore/notes with adaptable labels, stable relationships, explicit AI inclusion, and consistency evidence.

**Dependencies:** P0.2 and Inspector.

**Risks:** schema sprawl and excessive context payloads.

**Acceptance criteria:** fiction and non-fiction projects are usable; context selection is inspectable; relationships survive renames.

**Tests required:** entity lifecycle, relationships, context size controls, project isolation.

### P2.3 Genuine Streaming and Local Model Path

**Problem:** current provider streams are full-response wrappers; Ollama requests `stream: false`.

**Affected:** provider transports and Ghost UI.

**Proposed change:** implement incremental parsing for chosen primary cloud provider and Ollama; keep capability flags false elsewhere until implemented. Evaluate MLX separately rather than implying it exists.

**Dependencies:** provider capability model.

**Risks:** cancellation, partial UTF-8/SSE frames, rate limits, incomplete result handling.

**Acceptance criteria:** supported providers visibly deliver transport-level increments and cancel cleanly; unsupported providers remain truthfully marked.

**Tests required:** mocked chunk parsing, cancellation, error mid-stream, full-response fallback UI.

### P2.4 Semantic Retrieval Evaluation

**Problem:** large projects eventually need relevant context, but embeddings add privacy, cost, and operational complexity.

**Affected:** optional indexing/retrieval service.

**Proposed change:** first benchmark deterministic project filters/search. Add semantic retrieval only if measured tasks improve, with visible sources and local index ownership.

**Dependencies:** mature Project Memory and evaluation corpus.

**Risks:** irrelevant context, hidden data transfer, stale indexes.

**Acceptance criteria:** documented evaluation shows benefit; sources are inspectable; index can rebuild/delete; no cross-project retrieval.

**Tests required:** retrieval relevance suite, isolation, rebuild/delete, offline behavior.

## Later

### L.1 iCloud and Continuity

**Problem:** multi-device access is desirable but unsafe without conflict/recovery foundations.

**Affected:** persistence/sync architecture and identity.

**Proposed change:** choose a sync model only after local schemas, versions, and conflict semantics are stable.

**Dependencies:** P0 persistence and multi-window work.

**Risks:** conflicts, duplication, data loss, account edge cases.

**Acceptance criteria:** offline edits reconcile without silent loss; conflicts are recoverable and observable.

**Tests required:** sync/conflict simulation, migration, offline/reconnect, account changes.

### L.2 iPad Experience

**Problem:** the Mac UI cannot simply be compressed onto iPad.

**Affected:** shared models/services and a platform-specific shell/editor.

**Proposed change:** design an iPad workflow after sync and core document guarantees mature.

**Dependencies:** iCloud/Continuity and shared testable core.

**Risks:** diluted Mac quality and divergent behavior.

**Acceptance criteria:** platform-native interaction with compatible documents and recovery guarantees.

**Tests required:** cross-platform document fixtures, sync, keyboard/touch accessibility.

### L.3 Publishing and Optional Collaboration

**Problem:** publishing/collaboration can add value but greatly expands document and identity complexity.

**Affected:** export/workflow services; later collaboration backend.

**Proposed change:** add focused publishing workflows first; consider collaboration only after versions/conflicts are proven.

**Dependencies:** durable formats, identity, sync/conflict model.

**Risks:** scope expansion, permissions, merge/data ownership issues.

**Acceptance criteria:** workflows preserve ownership and formatting; collaboration is opt-in and recoverable.

**Tests required:** format fixtures, permissions, history/restore, conflict scenarios.

## Foundation Batch 1 Scope

This batch implements P0.4, P0.5, P0.6, README/hygiene, and only the minimal injection seams necessary to test them. It explicitly defers Project Memory migration, persistence replacement, broad UI redesign, analyzer/voice renaming, iCloud, new providers, and editor-context implementation.

## Recommended Batch 2

Implement **Editor Context + true cursor/selection-aware AI**: `EditorSession`, immutable context capture, focused-editor command routing, exact insertion/replacement with revision validation, selection transfer into Ghost, and native undo transactions. This is the highest-value next step once Batch 1 establishes trust, capability truth, and tests.
