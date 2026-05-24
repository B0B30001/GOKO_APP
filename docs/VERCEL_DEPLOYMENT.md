# Vercel — why two URLs show different versions

You may notice that these two URLs sometimes display *different* builds of the app:

- `https://goko-app.vercel.app/`
- `https://goko-app-b0b30001s-projects.vercel.app/`

**This is normal Vercel behaviour, not a bug.** Each URL serves a different "view" of your project.

## What each URL means

### `goko-app.vercel.app` — the **production alias**

This is the public, marketing-friendly URL Vercel assigns to your project. It only updates when a deployment is **promoted to production**. By default, that happens automatically when a commit is pushed to the *Production Branch* configured in the dashboard (usually `main`).

If you push a commit to a non-production branch (e.g. a feature branch or a PR branch), this URL does **not** change. It keeps showing the last main-branch build.

### `goko-app-b0b30001s-projects.vercel.app` — the **scope deployment URL**

`b0b30001s-projects` is your Vercel team / scope slug. Vercel uses this URL pattern for the most recent deployment in the scope — including preview deployments from feature branches.

So if you triggered a preview build (push to a non-main branch, or open a PR), this URL flips to show that preview. Meanwhile the production alias stays on the last main commit. Hence: two URLs, two different versions.

## How to make them show the same version

You don't have to "fix" anything — these URLs are doing exactly what Vercel designed them to do. But if you want both to always reflect the latest main-branch build, do this:

1. **Vercel Dashboard → Project → Settings → Git**
   Confirm "Production Branch" is set to `main`. If it's stuck on a stale branch (`master`, an old feature branch), change it back to `main`.

2. **Vercel Dashboard → Project → Domains**
   Make sure `goko-app.vercel.app` is listed as the production domain. Add it if it's missing.

3. **Delete or merge stale preview branches** so the scope URL has nothing newer than `main` to point at. Old, orphaned branches keep generating preview deployments that the scope URL prefers over production.

4. **Force a fresh production deploy**:
   - From CLI: `vercel --prod`
   - Or push any commit to `main` and Vercel will auto-promote it.

After step 4, hard-refresh both URLs (Ctrl + Shift + R) and they should display the same commit hash. If you want a quick visual check, the home screen's footer (or a debug toast) can show `kReleaseMode ? 'prod' : 'dev'` plus a short commit SHA injected at build time.

## Why caching makes this worse

The previous `vercel.json` had its catch-all `Cache-Control: max-age=31536000, immutable` rule listed **after** the specific no-cache rules for `flutter_service_worker.js` and `flutter_bootstrap.js`. Vercel evaluates header rules **last-match-wins**, so the wildcard overrode the specific rules and permanently cached the bootstrap files. Users then saw a stale entrypoint indefinitely.

That was fixed in commit `49637e6` (the immutable wildcard now comes first; the no-cache overrides come later so they win). If you ever see clients stuck on an old build after a deploy:

- Verify the order of `headers[]` in `vercel.json` — most-specific rules must come *after* the wildcard catch-all.
- Hard-refresh once (Ctrl + Shift + R) after a deploy to bypass any local cache from the broken-window period.

## Sanity check

```bash
# What commit is each URL serving?
curl -sI https://goko-app.vercel.app/index.html | grep -i x-vercel-cache
curl -sI https://goko-app-b0b30001s-projects.vercel.app/index.html | grep -i x-vercel-cache
```

If the two responses come back with different `etag` values, they're different builds. Bring them in sync by following the steps above.
