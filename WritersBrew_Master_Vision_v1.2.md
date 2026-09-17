# WritersBrew

**Master Product Vision & Working Specification**
Version 1.2 · September 2026

> A writing instrument first. Contextual intelligence second. The page remains sacred.

This document supersedes v1.1 as the current working product direction. Version 1.1 remains in the repository as historical context, not as an implementation contract.

## 1. Product Position

WritersBrew is the native Mac writing studio that protects a writer's flow, voice, project memory, and ownership. AI appears exactly where useful, understands the work, and every AI action is transparent and reversible.

The product must remain excellent when AI is completely hidden. Its enduring advantage is:

**The Page + Project Memory + Personal Voice + Trust + Native Mac Craft**

Provider count is not a product moat. A calm, precise writing surface; durable project context; a voice profile the writer can inspect; and trustworthy handling of prose are.

## 2. Product Principles

### Writing instrument first

The primary job is writing. The editor must feel immediate, stable, typographically considered, and predictable for long sessions. Intelligence must support the page rather than compete with it.

### Writer-controlled intelligence

AI is optional, hideable, and invoked at the point of intent. Generated prose is always a proposal. The writer chooses whether and where it enters the manuscript.

### Project-aware, not omniscient

Context is assembled from an explicit project boundary. The writer can see and remove the sources sent to an AI provider. No unrelated document or project data is included implicitly.

### Evidence over judgment

Craft feedback describes observable signals and points back to manuscript evidence. WritersBrew does not reduce prose to a universal quality percentage.

### Native Mac craft

Use familiar macOS behavior for text editing, undo, menus, windows, settings, accessibility, file exchange, and keyboard control. Visual effects belong in chrome, not across the writing surface.

### Technical philosophy

**SwiftUI-first, with AppKit/TextKit where native macOS APIs provide superior text editing, performance, accessibility, windowing, or system integration.**

The existing `NSTextView` bridge is a sound direction. It should evolve into a reliable editor boundary, not be removed for framework purity.

## 3. Experience Pillars

### 3.1 The Page

- A calm, dominant writing canvas with excellent typography and sensible measure.
- Precise caret, selection, insertion, replacement, undo, and scrolling behavior.
- Focus and keyboard-first workflows that do not hide standard Mac affordances.
- Search, import, export, versions, and recovery as core writing features.
- Typing never waits for AI, analysis, persistence, animation, or networking.

### 3.2 Ghost Writer

- Contextual AI invoked from a selection, caret, document, or explicit conversation.
- Selection- and cursor-aware requests with an inspectable target.
- Visible provider, model, cloud/local state, and capability status.
- Inspectable/removable context sources before a request is sent.
- Preview-first edits with Replace, Insert, Retry, Copy, and Dismiss.
- Undo-aware transactions; no generated prose enters the manuscript silently.
- Fully optional and completely hideable.

### 3.3 Project Memory

Project-scoped structured knowledge usable by fiction and non-fiction:

- people and characters;
- locations, settings, and world rules;
- timeline events and milestones;
- concepts, lore, research, and notes;
- stable relationships between entities;
- curated context for Ghost Writer and consistency checks.

Project Memory is not one global story universe. Entities belong to projects, relationships use stable identifiers where appropriate, and cross-project access is explicit.

### 3.4 Craft Lens

Craft Lens surfaces descriptive, evidence-based signals:

- sentence rhythm and variation;
- repetition and crutch-word frequency;
- readability measures with clear limitations;
- pacing proxies;
- consistency signals;
- relevant manuscript ranges and examples.

It must not present a universal 0–100 prose-quality score or claim that a heuristic defines good writing. Selecting a signal should eventually highlight the supporting text.

### 3.5 Voice Profile

Voice Profile is transparent and editable. It uses:

- author-written prose as primary evidence;
- accepted and rejected AI suggestions as secondary preference evidence;
- explicit writer preferences and prohibitions;
- editable observations rather than opaque conclusions;
- source examples so the writer can understand why an observation exists.

It must not imply a sophisticated personal model when only word-length heuristics and suggestion acceptance are available.

## 4. Trust Commitments

### Data Trust

- No lost prose.
- Atomic, recoverable persistence.
- Debounced autosave that never blocks typing.
- Automatic recovery after interruption or write failure.
- Schema versioning and forward migration plans.
- Automatic and manual versions.
- Recoverable destructive operations through Trash where practical.
- Portable export in durable, documented formats.
- Visible, actionable persistence failures.

### AI Transparency

- The current provider and model are visible.
- Local versus cloud processing is visible.
- There is no silent provider or model substitution.
- The exact context categories sent to AI are inspectable and removable.
- Capability labels reflect implementation: simulated chunks are not called streaming, Ollama is not called MLX, and heuristic templates are not called a local language model.
- Every generated edit requires explicit user action.

### Performance

- Keystrokes and selection changes remain on a fast local path.
- AI and network work is asynchronous and cancellable.
- Analysis is debounced, incremental where justified, and off the typing path.
- Persistence is debounced and performed away from the editor event path.
- Decorative animation respects Reduce Motion and never delays interaction.

## 5. Primary Application Shape

The main workspace evolves toward:

`Navigator | Writing Canvas | Inspector`

- **Navigator:** projects, documents, search, Trash, and Project Memory navigation.
- **Writing Canvas:** the dominant editor and contextual selection/caret UI.
- **Inspector:** one right-side surface with modes such as Ghost, Craft, and Project.

Ghost Writer and Craft Lens should not render as competing simultaneous right-side columns. Focus mode simplifies the shell without creating a separate editing model.

Per-window selection and inspector state belong to the window session. Persistent library content is shared; transient window state is not.

## 6. Appearance, Canvas Mood, and Typography

Keep three independent controls:

1. **Appearance:** System, Light, or Dark.
2. **Canvas mood:** restrained color/ambient treatment.
3. **Typography:** typeface, size, line height, paragraph spacing, and measure.

A canvas mood must not unexpectedly force dark mode or change the writer's typeface. Any bundled combination should be an explicit preset that previews all affected settings.

## 7. Provider Strategy

Quality and truth outrank breadth.

- Establish one excellent cloud path and one genuine local path before expanding breadth.
- Keep providers behind a small, testable boundary.
- Credentials live in Keychain; non-secret preferences may live in `UserDefaults`.
- A selected but unconfigured provider yields a clear configuration error.
- Offline Creative is honestly presented as deterministic heuristic assistance, not as a language model.
- True streaming is advertised only where transport-level incremental output exists.
- Provider/model availability is a runtime state, not marketing copy.

## 8. Roadmap

### Phase 1 — The Writing Instrument

- trustworthy documents and projects;
- precise native editor and editor context model;
- debounced autosave, recovery, Trash, and versions;
- keyboard workflow and command validation;
- search;
- import and portable export;
- multi-window session isolation;
- a real automated test baseline.

### Phase 2 — Contextual Intelligence

- selection- and caret-aware Ghost Writer;
- one excellent cloud provider;
- one genuine local model path;
- true streaming where supported;
- inspectable context controls;
- reversible AI edits and undo integration;
- project-scoped Project Memory in generation.

### Phase 3 — Personal Craft

- transparent Voice Profile grounded primarily in author prose;
- evidence-linked Craft Lens;
- deeper Project Memory relationships and consistency tools;
- semantic project retrieval only if measured usefulness justifies its complexity.

### Phase 4 — Ecosystem

- iCloud and Continuity with a conflict strategy;
- iPad experience designed for the platform;
- publishing and submission workflows;
- optional collaboration after local ownership and recovery are proven.

## 9. Current Product Reality (September 2026)

The repository is a substantial prototype, not yet a trustworthy writing system.

Implemented foundations include a native `NSTextView` editor bridge, document/project models, JSON-backed library, Ghost Writer UI, several network provider clients, an Ollama client, heuristic offline assistance, storyboard views, prose heuristics, a preliminary voice preference model, export, themes, and versions embedded in documents.

Important gaps are tracked in `IMPLEMENTATION-PLAN.md`. In particular: editor AI targets are not cursor-safe; Project Memory is global; persistence suppresses failures and writes synchronously; credentials are stored in `UserDefaults`; provider fallback and capability labels are misleading; analyzer and voice claims exceed their evidence; window selection is global; and the previous test file is not an XCTest suite.

## 10. Success Measures

- Writers trust that prose is saved, recoverable, portable, and never silently replaced.
- Writing and navigation feel immediate on representative long manuscripts.
- Users can predict exactly where an AI result will go before accepting it.
- Provider/model/context state is understandable without opening documentation.
- Project Memory improves relevance without leaking context between projects.
- Craft and voice feedback is useful because it is inspectable, editable, and evidence-linked.
- Writers choose WritersBrew even with all AI features disabled.

---

**Working product sentence:** WritersBrew protects the page, remembers the project, respects the writer's voice, and makes every intelligent action visible and reversible.
