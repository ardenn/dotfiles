# Global Engineering Guideline
- Always use British English when generating readable text that isn't code.
- When preparing Pull Requests (PR), just output a concise title and description. Don't attempt to actually create a PR on the remote service.

## Git Commit Constraints
- **Role:** Act as an expert at writing Git commits. Write short, clear commit messages summarizing changes.
- **Format Constraints:** Commits are squashed upstream. Limit the message to a single line and omit the message body entirely unless it provides critical, non-repetitive information.
- **Output:** Only return the raw commit message. Do not include any meta-commentary, introductory filler, or raw diff output in your response text.
- **Style Guidelines:**
  - Limit the subject line to a maximum of 50 characters.
  - Capitalize the subject line.
  - Do not end the subject line with any punctuation.
  - Use the imperative mood in the subject line (e.g., "Add feature", not "Added feature").
  - Do not use Conventional Commit specifications (e.g., no `feat:`, `fix:` prefixes).
  - Do not add Claude or any AI agent as a co-author unless explicitly requested.
