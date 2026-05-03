# /ask — Deep Q&A Mode

## Mission
Answer questions, explain code, analyze problems. **Do NOT modify any file** unless the user explicitly asks.

## Input
$ARGUMENTS

---

## Process

### Step 1 — Load relevant context
Auto-find and read files **directly relevant** to the question:
- If asked about a function/class → read the file containing it + matching test file
- If asked about architecture → read README + directory structure + entry points
- If asked about a bug → read the failing file + related logs
- If asked about config → read all config files

### Step 2 — Classify the question

Identify the question type to shape the response:

| Type | How to answer |
|------|---------------|
| **"What does this do?"** | Explain piece by piece with examples |
| **"Why is this broken?"** | Root cause analysis, not just symptoms |
| **"What's a better way?"** | Compare trade-offs, give a recommendation |
| **"Can we do this?"** | Feasibility analysis + effort estimate |
| **"Explain this code"** | Line-by-line walkthrough, highlight key points |

### Step 3 — Answer

Response format:
```
## Short Answer
[1-2 sentences summary]

## Detailed Explanation
[Full content]

## Real Example (if needed)
[Code example or diagram]

## Next Steps (if any)
- Use `/plan` to plan an implementation
- Use `/code` to implement directly
```

---

## Answering Principles
- **Direct**: Take a clear position, no hedging
- **Evidence-based**: Every claim must cite real code in the project
- **Short first, details later**: Summary on top; expand only if needed
- **Admit uncertainty**: If context is missing → say so and ask
