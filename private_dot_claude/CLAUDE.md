# Global Engineering Guideline
- Always use British English when generating readable text that isn't code.
- Wrap hand-written prose — markdown docs, `CLAUDE.md` files, code comments/docstrings — at up to 120 characters per line, matching the editor's configured wrap guide, rather than hard-wrapping well short of it (e.g. ~75 chars). Applies across all projects, not just wherever the editor setting happens to be visible.
- Use as few tokens as needed to accomplish a task. For bulk/mechanical work (reformatting many lines, batch edits, running the same transform over many files), prefer a local tool or script that performs the change directly on disk over generating the new content yourself — cheaper, more reliable, and doesn't fill the conversation with large diffs or regenerated file contents. Reach for this whenever a task is mechanical enough that a script could produce the same output deterministically.

## Git Branches
- Name branches `ardenn/<short-kebab-description>` (e.g. `ardenn/ask-digitax-plan`). Create the branch before
  committing whenever you're on the default branch.

## Git Commit Constraints
- Commits are squashed upstream: limit the message to a single line and omit the body entirely unless it provides critical, non-repetitive information.
- Only return the raw commit message — no meta-commentary, introductory filler, or raw diff output in the response text.
- Limit the subject line to a maximum of 50 characters.
- Capitalize the subject line.
- Do not end the subject line with any punctuation.
- Use the imperative mood in the subject line (e.g., "Add feature", not "Added feature").
- Do not use Conventional Commit specifications (e.g., no `feat:`, `fix:` prefixes).
- Never add Claude as a co-author on commits. Do not append a `Co-Authored-By: Claude ...` trailer to commit messages,
  and do not add a "Generated with Claude Code" line to commits.
- Do not automatically commit or push changes unless explicitly asked to.

## Writing code comments
- Never write comments that capture a point from our discussion: why we chose this approach over one we talked about, a
  constraint I raised mid-task, or a reaction to my feedback. Examples: "it changes the customer rather than the rule, so
  it still works once rules are frozen", "it is used by nothing else", "removing a label the user doesn't have is not an
  error". Someone reading the code later has no context for the conversation, so these read as noise.
- A comment earns its place only if it would make sense, and help, to someone reading the code cold. If the reasoning
  matters to reviewers, put it in the PR description instead.

## Writing PR descriptions
- Keep it to a couple of lines: what changed and why. Reviewers find long descriptions a chore, and most of the detail
  is already in the diff.
- Write in my voice and give my view of the change: the trade-off we made, what we're unsure about, or where we'd like
  the reviewer to look. Don't just describe the change neutrally.
- Use "we", not "I".
- Write from my perspective, not the PR's: imperative mood ("Add foo"), not third person ("Adds foo").
- Don't name the service, package or files when the diff makes it obvious which ones changed.
- Leave out implementation detail, test coverage summaries and restated ticket background unless a reviewer would miss
  something important without it.
- Never add a "🤖 Generated with Claude Code" line (or any other Claude attribution) to PR descriptions.
- These rules override any PR skill's guidance on length (e.g. "one or two short paragraphs"), except where a
  project's own config (its `CLAUDE.md` or project skills) explicitly asks for more, such as an evidence section.
