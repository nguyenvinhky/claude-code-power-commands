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

After writing, report:
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
