---
name: deep-research
description: "Conduct a methodical multi-source web investigation on a topic. Decompose into sub-questions, search multiple angles, read the actual sources, cross-check, and synthesize a cited answer with explicit confidence levels. Use when the user asks to research / investigate / 'dig into' a topic — NOT for a single quick fact (just web_search that directly)."
version: 1.0.0
author: Chad El Kurdi
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [Research, DeepResearch, WebSearch, Investigation, Synthesis, Citations]
    related_skills: [blogwatcher]
---

# Deep Research

Turn a topic into a real investigation, not a single Google lookup. The output
is a synthesized, **source-backed** answer where every claim is traceable and
uncertainty is flagged.

Answer in the user's language.

## When to use
- "deep research X", "investigate X", "dig into X", "creuse X",
  "compare X and Y in depth", "give me a full picture of X".
## When NOT to use
- A single quick fact ("what's the capital of X") → just call `web_search`.

## Tools
- `web_search(query)` — find sources (returns titles + URLs + snippets).
- `web_extract(urls=[...])` — read the actual page content (don't rely on snippets for anything load-bearing).
- `delegate` (if available) — run sub-questions as parallel sub-agents for speed. If not available, do the sub-questions sequentially.

## The loop

**1. Scope.** Restate the topic as a precise goal in one line. If it's genuinely
ambiguous (missing scope/timeframe/angle that changes the answer), ask ONE
clarifying question. Otherwise proceed.

**2. Decompose.** Break the goal into 3-6 specific sub-questions, each with a
clear objective. Vague sub-questions = duplicated, shallow work. Scale to the
topic: simple → 2-3 sub-questions; complex → 5-6 (use `delegate` to parallelize).

**3. Search (multiple angles).** For each sub-question, run `web_search` with
2-3 different phrasings. Prefer primary/authoritative sources (official docs,
papers, the org itself) over SEO content farms. Dedupe URLs.

**4. Read.** `web_extract` the best 2-4 sources per sub-question. Pull the
specific facts/numbers/quotes, each tied to its URL. Snippets are leads, not
evidence.

**5. Cross-check & iterate.**
- A claim is **confirmed** when 2+ independent sources agree → stop searching that sub-question.
- If sources **contradict**, keep both and flag the conflict (don't silently pick one).
- If a sub-question is still weak, reformulate and search again. Stop a sub-question after ~2 reformulations or when new pages add no new facts (novelty exhausted).
- Budget: ~3-8 searches per sub-question; if you're way over, the question is too broad — narrow it.

**6. Synthesize.** Write the answer:
- Lead with the direct answer / key takeaways.
- Then the supporting detail, organized by sub-question/theme.
- **Every load-bearing claim cites its source inline** (URL or source name).
- Distinguish **high-confidence** (multiple independent sources) from
  **uncertain** (single source / conflicting / inferred).
- End with a `Sources:` list of the URLs actually used.

## Guardrails (non-negotiable)
- **Never fabricate a source or URL.** If you didn't read it, don't cite it. A
  confident wrong answer is worse than "I couldn't verify this." Most research
  failures are invented citations.
- **Flag what you couldn't confirm.** Say "unverified" rather than guessing.
- **No hallucinated synthesis.** Don't state a claim no source supports. If the
  web didn't answer a sub-question, say so explicitly.
- **Hard budget: ~12 searches total, max.** When you reach it, STOP and synthesize with what you have. Never keep searching past the budget.
- **Stop on a dead engine.** If `web_search` returns empty/errors ~2 times in a row, the provider is likely rate-limited — STOP immediately, say so plainly ("⚠️ the search engine is not responding, here is what I could gather"), and answer with what you already have. NEVER loop-retry a dead engine (that's what causes timeouts).
- **Bound broad topics.** If the topic is large/open-ended, pick the 3-4 highest-value sub-questions up front instead of trying to cover everything.
- Keep a sense of cost: stop when the answer is solid, not when the web is
  exhausted.

## Shape of a good output
```
🎯 Short answer: <1-3 sentences>

<Detail by theme, every fact with its source>
- Fact A (confirmed by [src1], [src2])
- Fact B (⚠️ single source, to confirm: [src3])
- Conflicting point: [src4] says X, [src5] says Y

Sources:
- https://...
- https://...
```
