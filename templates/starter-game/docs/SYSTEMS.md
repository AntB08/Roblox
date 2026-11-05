# Systems: <Game Name>

## Data schema (src/server/Data/Schema.luau)
| Version | Change | Migration |
|---|---|---|
| 1 | (example) `Cash`, `Settings.Music` boolean | — |
| 2 | `Coins`, `Settings.MusicVolume` 0..1, Daily, RedeemedCodes, PurchaseIdCache, Onboarding | `MIGRATIONS[1]` |

Store: `PlayerData_v1`, key `Player_<UserId>`. Code global uses: `CodeGlobalUses_v1`, key `<CODE>`.

## Remotes (src/shared/Net/Remotes.luau)
| Name | Kind | Direction | Args | Rate |
|---|---|---|---|---|
| Collect | Event | ToServer | BasePart in Workspace | 3/s, burst 5 |
| CollectResult | Event | ToClient | CollectResult | — |
| Notify | Event | ToClient | text, kind | — |
| GetDailyStatus | Function | ToServer | — | 1/s, burst 5 |
| ClaimDaily | Function | ToServer | — | 0.5/s, burst 3 |
| RedeemCode | Function | ToServer | string ≤ 40 | 0.2/s, burst 4 |
| SetSetting | Event | ToServer | settings key, number 0..1 | 5/s, burst 10 |
| ClientError | Event | ToServer | message ≤ 500, stack? ≤ 2000, platform ≤ 20 | 0.2/s, burst 5 |

## Player attributes (server → client UI)
`Coins`, `Setting_<Key>`, `Policy_<Feature>`, `Pass_<Name>`.

## Services (Priority)
Analytics 200 · ErrorReporter 190 · LiveConfig 180 · PlayerLifecycle 160 · Policy 150 · DataService 100 · LeaderstatsService 90 · others 0.

## LiveConfig keys
`collect_reward` (number), `coin_multiplier` (number), `codes` (JSON), `motd` (string key).
