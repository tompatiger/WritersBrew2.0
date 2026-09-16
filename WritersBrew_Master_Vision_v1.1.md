# WritersBrew  
**Master Product Vision & Specification**  
Version 1.1 · September 2026

> Native SwiftUI · Apple HIG · Liquid Glass

---

## 1. Vision & North Star

WritersBrew is not another AI writing tool. It is a **complete creative environment** built exclusively for writers who care about the craft. It combines the calm focus of the best distraction-free editors with the intelligence of modern AI — delivered through an interface so refined that the technology disappears and only the words remain.

Our ambition is singular: to become the **most beautiful, most intelligent, and most respected writing application on the Mac** — the one writers open first and never want to leave. AI is not a feature; it is a vital creative partner that helps overcome writer’s block, expands ideas, rewrites with precision, and learns the writer’s unique voice.

### The Moat

Most AI writing tools feel like chatbots bolted onto a text box. Most classic writing apps feel frozen in time. WritersBrew occupies the rare middle ground: a native, Liquid-Glass-era macOS citizen that treats AI as a quiet, highly capable collaborator. Privacy, deep style personalization, story world tools, and aesthetic excellence form a durable competitive barrier.

---

## 2. Design Principles

**Writing First**  
Every pixel, animation, and AI suggestion exists to serve the act of writing. The blank page remains sacred.

**Quiet Intelligence**  
AI is proactive yet never intrusive. Suggestions appear when useful and vanish the moment they are not. The writer remains in complete control.

**Vital Creative Partner**  
AI is essential for overcoming blocks, expanding ideas, rewriting, and brainstorming — always available, never forced.

**Liquid Glass Excellence**  
We embrace Apple’s Liquid Glass material system fully: translucent, adaptive surfaces that create depth while keeping content king.

**Native Craft**  
SwiftUI only. System fonts, Dynamic Type, accessibility, keyboard shortcuts, multiple windows, and Continuity are first-class.

**Personal Voice**  
The app learns how *you* write. Suggestions and generation adapt to your tone, rhythm, and preferences over time.

**Delight in the Details**  
Micro-interactions, spring animations, subtle feedback, and carefully designed icons make the experience feel alive.

---

## 3. Who It Is For

**Primary:** Professional and serious amateur writers — novelists, essayists, journalists, screenwriters, technical writers, and knowledge workers who spend hours each week writing and care deeply about both the quality of their prose and the quality of their tools.

Especially powerful for fiction writers who need character, world, and timeline tools, and for anyone who regularly faces the blank page or writer’s block.

---

## 4. Core Experience Pillars

| The Editor | Ghost Writer | The Brew |
|------------|--------------|----------|
| Calm, typographically perfect writing surface with Liquid Glass chrome, Focus Mode, and zero visual noise. | Proactive suggestions + full conversational chat + real-time analysis + style voice learning. AI as vital creative partner. | Storyboard (characters, worlds, timeline), analytics, personalization, and gentle progress insights. |

---

## 5. Curated Feature Specification

Features have been rigorously prioritized. Everything here directly serves the craft of writing or removes friction from the creative process. AI is treated as a vital, always-available partner.

### 5.1 The Writing Surface

**Focus Editor**  
Distraction-free canvas with exceptional typography. Typewriter scrolling, adjustable measure, true Focus Mode that dims everything except the current paragraph. Optional subtle typewriter sound.

**Document Library**  
Projects, folders, smart collections, live previews, AI-assisted search and tagging. Multiple windows and split views for comparing drafts or consulting the Storyboard.

**Style Profiles**  
Presets (Concise, Descriptive, Formal, Conversational, Academic, Narrative) plus fully custom profiles. Profiles influence both visual presentation and the AI’s generation personality.

### 5.2 Ghost Writer — The AI Core

**Multi-Provider Architecture**  
Native support for OpenAI, Anthropic (Claude), xAI (Grok), Google (Gemini), and local models via MLX / Ollama. Bring-your-own-key or optional managed service. Privacy-first: local models work fully offline.

**Proactive Ghost Writer (Inline)**  
When enabled, the AI observes context and offers lightweight continuations, clarity rewrites, or expansions as floating Liquid Glass suggestion bubbles near the relevant text. Smart positioning with collision avoidance. Accept with one keystroke; reject and the bubble dissolves. Never inserts text without explicit approval.

**Ghost Writer Chat — Conversational Sidebar**  
A collapsible Liquid Glass sidebar (or optional floating panel) summoned by keyboard shortcut or toolbar. Full conversational interface with the same multi-provider AI. Deeply context-aware: it already knows the current document, selection, style profile, and Storyboard elements. Perfect for brainstorming, outlining, debating tone, generating alternatives, or simply talking through a stuck moment. Any response can be inserted into the document or saved as a new version. Conversation history lives with the document and can be cleared at any time. Completely hideable — the pure writing surface remains the default.

**Vital Creative Tools (Writer’s Block & Beyond)**  
AI is treated as an essential creative partner. Dedicated, one-click (or conversational) actions for:

- Overcome Writer’s Block — generate prompts, alternative directions, or “what happens next” suggestions  
- Rewrite — multiple tones, lengths, or perspectives while preserving the writer’s voice  
- Expand — develop scenes, add sensory detail, deepen emotion, or flesh out ideas  
- Continue — seamless continuation from the cursor  
- Clarify / Tighten / Elevate — targeted improvements  

All of these are available both inline and through the Chat sidebar.

**Real-time & On-demand Analyzer**  
When enabled, the Analyzer continuously (or on-demand) evaluates the current text and surfaces a clear score:

- Numeric: 0–100% quality / clarity / engagement score, **or**  
- Qualitative labels: Excellent · Good · Needs Improvement · Weak, with short explanations.

Scores and explanations appear in a subtle, non-intrusive panel or as gentle annotations. The writer can toggle real-time analysis on/off and choose the level of detail. Insights cover tone, readability, sentence variety, overused words, pacing, and consistency with the active Style Profile.

**Voice Learning — The Style Skill**  
One of the most important differentiators. The AI continuously analyzes the writer’s accepted text, preferred suggestions, and rejected ones. Over time it builds a living “Voice Skill” — a deep model of the individual’s style, rhythm, vocabulary preferences, and tone. Generation and rewriting increasingly match the writer’s natural voice rather than producing generic AI prose. The Voice Skill can be inspected, tuned, or reset at any time. This is how WritersBrew becomes truly personal and nearly impossible to replicate with generic tools.

### 5.3 Storyboard — Worlds, Characters & Timeline

A dedicated module (especially powerful for fiction, screenwriting, and long-form narrative) that lives alongside the manuscript. Accessible from the sidebar or as its own window.

**Characters**  
Rich character sheets: appearance, personality, backstory, goals, relationships, voice notes, and AI-assisted consistency checks. The Ghost Writer can reference characters automatically when generating or rewriting scenes.

**Worlds & Locations**  
Places, cultures, rules, history, and sensory details. Keep the internal logic of the story coherent. AI can pull from the world bible when expanding or checking consistency.

**Timeline**  
A flexible chronological view of events, chapters, or scenes. Drag to reorder, attach notes, and see narrative arcs at a glance. Optional AI suggestions for pacing or plot holes.

The Storyboard is optional and can be completely hidden for non-fiction or simple documents. When present, it becomes living context that the Ghost Writer understands and respects.

### 5.4 Visual & Interaction Language

**Liquid Glass Surfaces**  
Sidebars, toolbars, suggestion bubbles, chat panel, and inspector use Apple’s Liquid Glass material. They refract content beneath them, adapt to light/dark, and maintain perfect legibility. Content layer stays clean — glass is reserved for functional chrome (per HIG).

**Smart Suggestion Bubbles & Micro-delight**  
Morphing, spring-animated bubbles with collision-aware placement. Subtle highlighting previews changes. Acceptance can trigger restrained particle feedback — delightful, never distracting. Every control has purposeful hover, press, and focus states.

**Themes & Mood Modes**  
System light/dark plus curated writing moods (Deep Focus, Creative Warmth, Night Oil, Paper & Ink). Moods adjust ambient tint and accent without ever compromising readability.

### 5.5 Workflow, Export & Integration

Clean export to PDF, DOCX, Markdown, HTML, plain text. Optional AI-assisted formatting. Version history with intelligent change summaries. Templates that carry Style Profiles. Deep Apple ecosystem support: iCloud, Continuity, Shortcuts, Spotlight, system Writing Tools.

### 5.6 Accessibility & Power Features

Full VoiceOver, Dynamic Type, high-contrast, reduced-motion. Comprehensive keyboard navigation. Optional voice dictation with real-time AI cleanup. Read-aloud for proofreading by ear.

---

## 6. Technical Note: Metal or Not?

**Recommendation: Do not make Metal a core dependency for v1.**

Apple’s Liquid Glass materials, SwiftUI, and Core Animation already deliver the fluid, refractive, depth-rich visual language we need. Custom Metal shaders and compute would add significant complexity, maintenance cost, and potential performance pitfalls for relatively modest visual gains at this stage.

We can (and should) revisit Metal later if we want advanced particle systems, custom lensing effects, or highly complex animated backgrounds. For the Master vision and first releases, staying within SwiftUI + system materials keeps the app fast, reliable, accessible, and fully aligned with Apple’s current design system. The result will still look and feel stunning.

---

## 7. Intentionally Deferred

- Real-time multi-user collaborative editing (complex; later phase)
- Heavy research / citation databases as core (can integrate later)
- Aggressive social or community features
- Overly gamified streaks and public leaderboards
- Metal-based custom rendering pipeline (see section 6)

---

## 8. Technical Foundation (High Level)

- **Platform**: macOS (Tahoe / Liquid Glass era+) — SwiftUI exclusively.
- **Architecture**: Local-first documents with optional iCloud. AI calls isolated and cacheable.
- **AI Layer**: Pluggable provider protocol (cloud + local MLX/Ollama). Streaming, graceful degradation, clear offline mode.
- **Voice Skill**: On-device style analysis + learning loop that improves generation over time.
- **Performance**: Background analysis for long documents, suggestion caching, Swift concurrency.
- **Quality**: Unit & UI tests, accessibility audits, continuous HIG design review.

---

## 9. Phased Roadmap Sketch

| Phase | Focus | Key Deliverables |
|-------|-------|------------------|
| **1 — Foundation** | Core experience | Focus Editor, Liquid Glass shell, basic Ghost Writer (one provider + chat sidebar), document library, export, keyboard excellence. |
| **2 — Intelligence** | AI depth | Multi-provider, proactive bubbles, full Analyzer (scores + explanations), Voice Learning, writer’s-block tools, local models. |
| **3 — Worlds** | Story power | Storyboard (Characters, Worlds, Timeline), deeper context awareness, mood themes, advanced analytics, Continuity. |
| **4 — Expansion** | Selective growth | iPad companion, publishing integrations, optional collaboration — only after the Mac core is world-class. |

---

## 10. How We Will Know We Succeeded

- Writers choose WritersBrew as their primary daily environment and recommend it unprompted.
- The interface is described as “the most beautiful writing app I’ve used.”
- AI suggestions and generations are accepted at high rates; users say “it writes in my voice.”
- Writer’s block feels solvable inside the app rather than a reason to quit for the day.
- The Storyboard becomes indispensable for fiction writers.
- The app is praised for feeling native, fast, private, and deeply respectful of the craft.

---

> **WritersBrew exists to make the act of writing feel extraordinary again.**  
> AI is a vital partner. The page remains sacred. Beauty is non-negotiable.

— End of Master Document v1.1 —
