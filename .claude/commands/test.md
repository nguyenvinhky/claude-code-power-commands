# /test — Test Writing & Running Mode

## Mission
Write high-quality tests. Don't write tests just to chase coverage numbers.

## Input
$ARGUMENTS
(File/function to test, or leave empty to test the latest code)

---

## Process

### Step 1 — Survey the testing setup
- Identify the testing framework in use (Jest, Vitest, pytest, Go test, etc.)
- Read the test config (`jest.config.ts`, `vitest.config.ts`, etc.)
- Look at existing tests to learn conventions
- Check available helpers/fixtures

### Step 2 — Analyze the code under test
Read carefully to identify:
- **Happy paths**: normal case
- **Edge cases**: null, empty, 0, negative, very large
- **Error paths**: when it throws / returns failure
- **Side effects**: DB calls, API calls, file I/O, events

### Step 3 — Design test cases

Before coding, list cases in this format:
```
Function: createUser(data)
├── ✅ Happy: create user with valid data → returns new user
├── ✅ Happy: user is persisted to database
├── ❌ Edge: email already exists → throws DuplicateEmailError
├── ❌ Edge: invalid email → throws ValidationError
├── ❌ Edge: data = null → throws ValidationError
└── ⚡ Side effect: sends welcome email after create
```

### Step 4 — Write the tests

Rules:
- **AAA Pattern**: Arrange → Act → Assert (clearly separated)
- **One main assertion per test** (secondary assertions allowed)
- **Self-describing test names**: `"should throw ValidationError when email is invalid"`
- **Mock dependencies**: mock DB, API calls, external services
- **Test behavior, not implementation**: don't test internals

```typescript
// ✅ Good
it('should return 404 when user does not exist', async () => {
  // Arrange
  mockUserRepo.findById.mockResolvedValue(null)

  // Act
  const response = await getUser(req, res)

  // Assert
  expect(res.status).toHaveBeenCalledWith(404)
})

// ❌ Avoid
it('test1', () => {
  expect(fn(1)).toBe(2) // unclear name, no context
})
```

### Step 5 — Run tests and report

**Detect runner from project**:
- `package.json` → `scripts.test` exists → use `npm test` (or `pnpm`/`yarn`/`bun` based on lockfile)
- `pyproject.toml` / `setup.cfg` → `pytest` if installed, else `python -m unittest`
- `go.mod` → `go test ./...` (or specific path if scoped)
- `Cargo.toml` → `cargo test`
- `Gemfile` → `bundle exec rspec`
- Other → ask user for the command instead of guessing

**Run only the affected scope** if possible — don't run full suite for a 3-line test addition:
- Jest/Vitest: `npm test -- <test-file-path>`
- pytest: `pytest <path>::<test_name>`
- Go: `go test ./pkg/foo -run TestNewFeature`

**For large suites** → delegate to `test-runner` subagent (isolated context, doesn't pollute main conversation).

**If tests fail** → don't claim "done". Either fix the test (if it's wrong) or fix the code (if it's wrong). If unclear which is correct, ask user before changing either.

**After running, report**:
```
## 🧪 Tests written

### [Test file name]
- ✅ [Test case 1]
- ✅ [Test case 2]
- ✅ [Test case 3]

## 📊 Coverage estimate
- Branches covered: X/Y
- Uncovered cases (intentionally skipped): [reason]

## 🔜 Suggestions
[Integration tests or e2e tests if needed]
```

---

## Notes
- **Don't mock what you don't need to** (over-mocking makes tests meaningless)
- **Avoid testing private methods directly**
- **Tests must run independently** (no order dependency)
- If code is hard to test → that's a signal it needs refactoring
