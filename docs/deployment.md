# GOKO — Web Deployment & Caching

## Vercel build

- **Build:** `bash scripts/vercel_build.sh` (downloads Flutter stable, runs `flutter build web --release`)
- **Output:** `build/web/`
- **Routing:** SPA — every path rewrites to `/index.html`

## Cache strategy

Two tiers in [`vercel.json`](../vercel.json):

| Asset                          | Cache-Control                               | Why                                      |
| ------------------------------ | ------------------------------------------- | ---------------------------------------- |
| `/`, `/index.html`             | `no-cache, no-store, must-revalidate`       | Entry HTML — must always be fresh        |
| `/manifest.json`               | `no-cache, no-store, must-revalidate`       | PWA manifest changes each release        |
| `flutter_bootstrap.js`         | `no-cache, no-store, must-revalidate`       | Loader picks the current build hash      |
| `flutter.js`                   | `no-cache, no-store, must-revalidate`       | Engine loader                            |
| `flutter_service_worker.js`    | `no-cache, no-store, must-revalidate`       | Re-checked on every load                 |
| Hashed `*.js *.wasm` and media | `public, max-age=31536000, immutable`       | Hashes change every build → safe forever |

Defense in depth: [`web/index.html`](../web/index.html) also carries `Cache-Control` / `Pragma` / `Expires` meta tags for intermediary CDNs that ignore HTTP headers.

## Stale-cache eviction shim

A one-shot script in `index.html` unregisters any pre-existing service worker and clears the Cache Storage on first load after this rollout, then sets `localStorage["goko_sw_evicted_v1"] = "1"` so it never runs again. After ~1 release cycle (or once analytics confirm no users still on old bundles), this block can be removed.

## Vercel "screenshot 403"

Vercel's deployment-thumbnail service hits the production URL with no auth. If **Project Settings → Deployment Protection** is enabled, the screenshot service gets a `401`/`403` and the dashboard tile renders blank.

Fix: in the Vercel dashboard, set **Deployment Protection** to *Standard Protection: Disabled* for the production environment (or to *Only Preview Deployments* if you want to keep previews gated). This is a project-settings change, not a code change.

If the protection setting is already off and the 403 persists, check for `vercel.json` redirects/rewrites that might intercept the screenshot bot's user-agent.

## Local verification after deploy

```bash
# index.html must be no-cache
curl -I https://<your-domain>/ | grep -i cache-control

# bootstrap loader must be no-cache
curl -I https://<your-domain>/flutter_bootstrap.js | grep -i cache-control

# A hashed asset must be immutable (replace with real filename from build/web/)
curl -I https://<your-domain>/main.dart.js | grep -i cache-control
```
