# WritersBrew Core UX Specification

This specification describes intended behavior. Items not yet implemented are roadmap requirements, not claims about the current build.

## 1. Workspace

The default workspace is `Navigator | Writing Canvas | Inspector`. The canvas receives the majority of width. The Inspector has one active mode—Ghost, Craft, or Project—and can be hidden. Focus mode hides supporting chrome while preserving standard editing and escape routes.

## 2. Writing Flow

1. Open a project in the Navigator.
2. Open a document/chapter.
3. The editor restores the document and places focus predictably.
4. Write using normal macOS text behavior, undo, spelling, substitutions, selection, and navigation.
5. Changes mark the document dirty immediately in memory.
6. Debounced autosave runs silently off the typing path.
7. A save failure produces a persistent, actionable status without blocking continued writing; recovery data remains available.

The application never treats a corrupt or unreadable library as an empty first launch and overwrites it with samples.

## 3. Selection AI

1. Select manuscript text.
2. A compact contextual palette appears near the selection without obscuring it.
3. Choose Rewrite, Tighten, Expand, or Ask Ghost.
4. The operation captures document identity, revision, exact selection range/text, provider/model, and selected context chips.
5. Ghost shows progress and can be cancelled. Typing remains responsive.
6. The result appears as a preview with Replace, Insert, Retry, Copy, and Dismiss.
7. Replace/Insert validates that the target is still current. If the document changed incompatibly, WritersBrew asks the writer to reselect or offers Copy; it never guesses.
8. Applying the edit creates one native undo transaction.

Ask Ghost opens the Ghost Inspector with the selection retained as a visible, removable `Selection` context chip and optionally seeds the composer. Dismissing the floating palette must not discard the captured context.

## 4. Cursor AI

1. Place the caret at the intended insertion point.
2. Invoke Continue/Ask Ghost from the command, context menu, or Inspector.
3. Ghost receives bounded text before and after the caret plus the current document/project identity.
4. Generated text is previewed.
5. Insert applies exactly at the captured caret after validating the document revision, as one undoable transaction.

“Continue from Cursor” never means append to the document end unless the caret is at the end.

## 5. Ghost Inspector

The header always shows provider, model, and `Local` or `Cloud`. If configuration is missing or the provider is unfinished, the composer is disabled with a direct Settings action.

Context appears as removable chips, for example:

- Selection;
- Current chapter;
- Character;
- Location;
- Project;
- Voice Profile.

Selecting a chip reveals what it contributes. Before sending, the writer can remove sources. No hidden cross-project context is added. Responses offer insert/replace only when a valid editor target exists; Copy is always available.

Offline Creative is labeled as heuristic offline assistance. Ollama is labeled as Ollama. Full-response providers show generation progress, not a false streaming claim.

## 6. Craft Lens

Craft Lens contains evidence-based sections such as Rhythm, Repetition, Readability, Pacing, and Consistency. It does not show a universal quality score or “Excellent/Weak” verdict.

Each signal includes:

- the observation;
- how it was measured;
- why it may matter, phrased as an option rather than a rule;
- manuscript examples/ranges.

Clicking an example should select or highlight the relevant text. Analysis runs on demand or after a debounce, never synchronously on every keystroke for long documents.

## 7. Project Memory

Project mode shows only entities belonging to the active project. People/characters, locations, events, concepts, lore, and notes can be inspected without leaving the manuscript. Entity relationships are selected from stable records rather than retyped names. Non-fiction projects can rename/present these categories appropriately.

When no project is active, Project Memory clearly indicates that a standalone document has no project context and offers an explicit association flow.

## 8. Voice Profile

The profile separates:

- explicit preferences written by the author;
- observations inferred from author prose;
- preference evidence from accepted/rejected AI suggestions;
- source examples.

The writer can edit, disable, or remove any observation. Reset is confirmable and recoverable where practical. The UI avoids claiming the profile has “learned the author's voice” without sufficient primary evidence.

## 9. Versions and Recovery

- Autosave protects current work.
- Automatic versions are created at meaningful intervals/events.
- The writer can create a named manual version.
- Version history shows timestamp, reason, summary, and word-count delta.
- Compare opens a readable diff.
- Restore first snapshots the current manuscript, then restores as one undoable/recoverable action.
- Copy from Version never changes current prose.
- After abnormal termination, a recovery surface explains what was recovered and from when.

## 10. Destructive Actions

Document, project, and Project Memory deletion uses Trash where practical. The user can restore or permanently delete later. Permanent deletion and irreversible resets require confirmation that names the target and consequence. Deleting a project never silently deletes unassociated data or credentials.

## 11. Appearance

Appearance (System/Light/Dark), Canvas Mood, and Typography are independent settings. A mood preview states any settings it changes. Content surfaces prioritize legibility; material/glass effects remain restrained in chrome and respect Reduce Transparency.

## 12. Canonical Keyboard Behavior

Only implemented shortcuts should be displayed in tooltips or menus. Intended canonical set:

| Action | Shortcut | Status requirement |
|---|---:|---|
| New document/chapter | Command-N | Menu and action must agree on scope |
| Settings | Command-, | Use native Settings command |
| Find in document | Command-F | Native editor find behavior |
| Save manual version | Command-Shift-S | Do not replace standard Command-S semantics |
| Toggle Inspector | Command-Option-I | One Inspector, current mode retained |
| Ghost at selection/caret | Command-J | Captures exact editor context |
| Focus mode | Command-Shift-F | Menu command and tooltip wired |
| Escape/dismiss preview | Escape | Never discards manuscript changes |
| Undo/redo | Command-Z / Command-Shift-Z | AI application is one transaction |

Before shipping a displayed shortcut, validate that the command exists, works with editor focus, and is accessible through a menu.

## 13. Accessibility and Motion

- All controls have meaningful labels and keyboard focus.
- Context chips and analysis evidence are navigable with VoiceOver.
- Text contrast follows system accessibility settings.
- Reduce Motion replaces spring/scale transitions with restrained fades or no animation.
- Reduce Transparency uses opaque, legible surfaces.
- Focus mode does not make non-focused text unreadable to accessibility technologies.
