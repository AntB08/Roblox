# Third-party code

Vendored so the project builds without Wally. Each folder keeps its upstream LICENSE file
(Rojo ignores files it doesn't recognize, so licenses don't become instances).

| Library | Version | Upstream | License | Location |
|---|---|---|---|---|
| ProfileStore | 1.0.3 (`lm-loleris/profilestore`) | https://github.com/MadStudioRoblox/ProfileStore | Apache-2.0 | `src/server/Packages/ProfileStore/` |
| Trove | 1.8.0 (`sleitnick/trove`) | https://github.com/Sleitnick/RbxUtil | MIT | `src/shared/Packages/Trove/` |
| Signal | 2.0.3 (`sleitnick/signal`) | https://github.com/Sleitnick/RbxUtil | MIT | `src/shared/Packages/Signal/` |

Copied unmodified from the local knowledge-base mirror (`~/Roblox/reference/libraries`), except
for a 2-line provenance comment at the top of each module. Dev-only (via Wally, not vendored):
Jest / JestGlobals 3.20.0 (`roblox/jest`, MIT).
