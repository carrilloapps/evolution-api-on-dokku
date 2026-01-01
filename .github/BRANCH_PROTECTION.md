# Branch Protection Rules

This document outlines the recommended branch protection rules for this repository.

## How to Apply

1. Go to **Settings** → **Branches** in your GitHub repository
2. Click **Add branch protection rule**
3. Apply the settings below for each branch

---

## Protection Rules for `master` (Main Branch)

### Branch name pattern
```
master
```

### Protect matching branches

#### Required Settings

- ✅ **Require a pull request before merging**
  - ✅ Require approvals: **1**
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  - ❌ Require review from Code Owners (optional for small teams)

- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - **Required status checks:**
    - `Markdown Link Check` (from link-check.yml)

- ✅ **Require conversation resolution before merging**
  - All PR comments must be resolved

- ✅ **Require linear history**
  - Prevents merge commits, keeps history clean

- ❌ **Require deployments to succeed before merging**
  - Not needed for this project

- ✅ **Lock branch**
  - ❌ Do not lock (allow commits)

- ✅ **Do not allow bypassing the above settings**
  - ✅ Enforce for administrators

#### Additional Settings

- ✅ **Allow force pushes**
  - ❌ Disabled (never force push to master)

- ✅ **Allow deletions**
  - ❌ Disabled (never delete master branch)

---

## Protection Rules for `develop` (Development Branch)

### Branch name pattern
```
develop
```

### Protect matching branches

#### Required Settings

- ✅ **Require a pull request before merging**
  - ✅ Require approvals: **1**
  - ❌ Dismiss stale pull request approvals (optional)
  - ❌ Require review from Code Owners (optional)

- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - **Required status checks:**
    - `Markdown Link Check`

- ✅ **Require conversation resolution before merging**
  - All PR comments must be resolved

- ❌ **Require linear history**
  - Optional for develop, allows merge commits

- ❌ **Lock branch**
  - Allow commits

- ❌ **Do not allow bypassing the above settings**
  - ✅ Allow maintainers to bypass for hotfixes

#### Additional Settings

- ✅ **Allow force pushes**
  - ❌ Disabled (avoid force pushing)

- ✅ **Allow deletions**
  - ❌ Disabled (never delete develop branch)

---

## Summary Table

| Setting | `master` | `develop` |
|---------|----------|-----------|
| Require PR | ✅ Yes | ✅ Yes |
| Required approvals | 1 | 1 |
| Status checks | ✅ Yes | ✅ Yes |
| Up to date branch | ✅ Yes | ✅ Yes |
| Resolve conversations | ✅ Yes | ✅ Yes |
| Linear history | ✅ Yes | ❌ No |
| Force push | ❌ No | ❌ No |
| Delete branch | ❌ No | ❌ No |
| Bypass for admins | ❌ No | ✅ Yes |

---

## Branch Strategy

### Recommended Workflow

```
feature/new-docs
    ↓ (PR + review)
develop
    ↓ (PR + review + tests)
master
    ↓ (tag release)
v1.0.0
```

### Branch Naming Convention

- **Feature branches**: `feature/description` or `feat/description`
- **Bug fixes**: `fix/description` or `bugfix/description`
- **Documentation**: `docs/description`
- **Hotfixes**: `hotfix/description`
- **Chores**: `chore/description`

### Workflow Steps

1. **Create feature branch from `develop`**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/new-documentation
   ```

2. **Make changes and commit**
   ```bash
   git add .
   git commit -m "docs: add installation troubleshooting section"
   ```

3. **Push and create PR to `develop`**
   ```bash
   git push origin feature/new-documentation
   # Create PR on GitHub: feature/new-documentation → develop
   ```

4. **After merge to `develop`, create PR to `master`**
   ```bash
   # Create PR on GitHub: develop → master
   ```

5. **After merge to `master`, tag release**
   ```bash
   git checkout master
   git pull origin master
   git tag -a v1.0.1 -m "Release version 1.0.1"
   git push origin v1.0.1
   ```

---

## Additional Recommendations

### For Single Maintainer

If you're the only maintainer, you can:
- Reduce required approvals to **0** (but keep PR requirement)
- Allow yourself to bypass branch protection for urgent fixes
- Still require status checks to pass

### For Team Environment

If working with a team:
- Keep required approvals at **1** minimum
- Enable Code Owners review requirement
- Do not allow bypassing for administrators
- Require all status checks to pass

### Status Check Configuration

Make sure these workflows run on PRs:

**.github/workflows/link-check.yml**
```yaml
on:
  pull_request:
    branches: [main, master, develop]
```

**.github/workflows/markdown-lint.yml**
```yaml
on:
  pull_request:
    branches: [main, master, develop]
```

---

## Testing Branch Protection

After setting up, test by:

1. **Try to push directly to master** (should fail)
   ```bash
   git checkout master
   git commit --allow-empty -m "test"
   git push origin master
   # Expected: Error - protected branch
   ```

2. **Create PR without passing checks** (should block merge)
   - Create PR with broken markdown
   - Try to merge
   - Expected: Blocked until checks pass

3. **Create PR without approval** (should block merge if configured)
   - Create valid PR
   - Try to merge without approval
   - Expected: Blocked until approved

---

## Troubleshooting

### Status checks not showing up

1. Run workflows at least once on the branch
2. Check workflow configuration includes PR triggers
3. Wait a few minutes for GitHub to register checks

### Can't merge even with passing checks

1. Ensure branch is up to date
2. Check all conversations are resolved
3. Verify you have required approvals

### Need to bypass protection for hotfix

1. Temporarily disable protection rule
2. Push urgent fix
3. Re-enable protection rule immediately
4. Create follow-up PR to document changes

---

## Further Reading

- [GitHub Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Status Checks](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/about-status-checks)
- [Git Flow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)

---

**Last Updated**: 2026-01-01
