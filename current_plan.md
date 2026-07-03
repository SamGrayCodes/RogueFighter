# RogueFighter — Full Game Architecture Plan

## Context
Starting from a clean Godot 4.7 project. The goal is a 2D competitive multiplayer combat game — a hybrid of platform fighter (Smash Bros-style knockback, platforms) and action brawler (HP bars, free-form arenas). Up to 4 players, local and online. Rogue-like upgrade selection between rounds. Multiple game modes, custom rules (save/load), character roster, and multiple stages.

All code: GDScript with static typing. Online layer uses Godot's built-in ENet, behind a NetworkTransport abstraction so the transport can be swapped later.

---

## Folder Structure

```
res://
├── autoloads/
│   ├── GameState.gd          # Match state, round tracking, player roster
│   ├── NetworkManager.gd     # Network transport facade
│   ├── UpgradeRegistry.gd    # All upgrade definitions + blacklist
│   └── AudioManager.gd       # Music/SFX
├── scenes/
│   ├── game/
│   │   ├── GameWorld.tscn    # Root match scene (MultiplayerSpawner lives here)
│   │   └── HUD.tscn          # In-match UI (HP bars, round timer, round counter)
│   ├── characters/
│   │   ├── CharacterBase.tscn
│   │   └── [CharacterName].tscn   # Inherits CharacterBase
│   ├── stages/
│   │   ├── StageBase.tscn
│   │   └── [StageName].tscn       # Inherits StageBase
│   ├── ui/
│   │   ├── MainMenu.tscn
│   │   ├── LobbyScreen.tscn
│   │   ├── CharacterSelect.tscn
│   │   ├── StageSelect.tscn
│   │   ├── UpgradeScreen.tscn     # Post-round upgrade picker ✅
│   │   ├── RulesEditor.tscn       # Custom game rules builder
│   │   └── ResultsScreen.tscn
│   └── components/
│       ├── HitboxComponent.tscn
│       └── HurtboxComponent.tscn
├── scripts/
│   ├── characters/
│   │   ├── CharacterBase.gd
│   │   ├── CharacterStats.gd
│   │   ├── CharacterStateMachine.gd
│   │   └── states/
│   │       ├── CharacterState.gd
│   │       ├── IdleState.gd
│   │       ├── RunState.gd
│   │       ├── JumpState.gd
│   │       ├── AirState.gd
│   │       ├── AttackState.gd
│   │       ├── AirAttackState.gd
│   │       ├── StunState.gd
│   │       └── KnockbackState.gd
│   ├── combat/
│   │   ├── AttackData.gd
│   │   ├── HitboxComponent.gd
│   │   ├── HurtboxComponent.gd
│   │   └── CombatResolver.gd
│   ├── upgrades/
│   │   ├── UpgradeData.gd
│   │   ├── UpgradeEffect.gd
│   │   ├── UpgradeManager.gd
│   │   └── effects/
│   │       ├── SpeedBoostEffect.gd ✅
│   │       ├── HighJumpEffect.gd ✅
│   │       ├── ExtraJumpEffect.gd ✅
│   │       ├── AttackPowerEffect.gd ✅
│   │       ├── IronFistsEffect.gd ✅
│   │       ├── IronSkinEffect.gd ✅
│   │       ├── HeavyweightEffect.gd ✅
│   │       ├── SecondWindEffect.gd ✅
│   │       ├── AdrenalineEffect.gd ✅
│   │       └── LightfootEffect.gd ✅
│   ├── modes/
│   │   ├── GameMode.gd
│   │   └── concrete/
│   │       ├── StandardMode.gd
│   │       └── [OtherMode].gd
│   ├── network/
│   │   ├── NetworkTransport.gd
│   │   ├── ENetTransport.gd
│   │   └── LocalTransport.gd
│   ├── stages/
│   │   ├── StageBase.gd
│   │   └── Platform.gd
│   ├── rules/
│   │   ├── GameRules.gd
│   │   └── RulesSerializer.gd
│   └── ui/
│       └── UpgradeScreen.gd ✅
└── resources/
    ├── characters/
    └── upgrades/
```

---

## Implementation Phases

### ✅ Phase 1 — Foundation
- `CharacterStats` resource + `CharacterBase` with full state machine (Idle/Run/Jump/Air/Attack/AirAttack/Stun/Knockback)
- `StageBase` + `Platform` + Stage01 ("Platform Zero")
- Local 2–4 player input via `InputMap` (p1_* through p4_*)
- `HitboxComponent` + `HurtboxComponent` + `CombatResolver`
- `GameState` autoload (local-only)
- Round loop: start → combat → round end → loop
- Sam character with placeholder polygon visual + programmatic animations

### ✅ Phase 2 — Rogue-like Layer
- `UpgradeData`, `UpgradeEffect`, `UpgradeManager` (per-character node)
- `UpgradeRegistry` autoload — scans `res://resources/upgrades/` at startup, persists blacklist to `user://blacklist.cfg`
- `UpgradeScreen` — shown after each non-final round; each player picks one of 3 offers; upgrades apply immediately via `UpgradeManager`
- 10 starter upgrade effects: Speed Boost, High Jump, Extra Jump, Sharp Edge, Iron Fists, Iron Skin, Heavyweight, Second Wind, Adrenaline, Lightfoot
- Characters now duplicate their `CharacterStats` resource on ready so upgrades don't bleed between instances
- Characters reset (HP, velocity, state, position) at the start of each round

### Phase 3 — Game Modes + Rules
- `GameMode` base + `StandardMode` (already stubbed)
- `GameRules` resource + `RulesSerializer` (already stubbed)
- `RulesEditor.tscn` UI — build, save, and load custom rule sets
- 1–2 additional concrete game modes (e.g. no upgrades, time attack, sudden death)

### Phase 4 — Networking
- `NetworkTransport` abstraction + `ENetTransport` + `LocalTransport` (already stubbed)
- `NetworkManager` autoload (already stubbed)
- Input RPC pipeline — clients send `InputData` each frame; server is authoritative
- `MultiplayerSynchronizer` on characters (position, velocity, state)
- `MultiplayerSpawner` in `GameWorld`
- `LobbyScreen.tscn` — host or join by IP

### Phase 5 — Content
- Additional characters (new `CharacterStats` resources + scene variants)
- Additional stages
- Additional upgrades and game modes
- HUD (HP bars, round timer, round counter)
- Main menu, character select, stage select, results screen

---

## Key System Designs

### Character System
`CharacterBase` (CharacterBody2D) owns a `CharacterStateMachine` and references `CharacterStats` (duplicated per-instance). States are `RefCounted` objects registered by `StringName` key. `MultiplayerSynchronizer` (Phase 4) will sync position, velocity, and current state.

### Combat System
`HitboxComponent` (Area2D) activates per-attack-frame with an `AttackData` reference. `HurtboxComponent` (Area2D) emits `hit_received`. `CombatResolver` (server-only Node in GameWorld) validates hits, applies damage, and launches the target into `KnockbackState`. Knockback scales with missing HP (rage mechanic).

### Upgrade System
`UpgradeData` resources define each upgrade (id, name, description, `effect_script: GDScript`). `UpgradeEffect` subclasses implement `apply(character)` / `remove(character)`. `UpgradeManager` (child Node on each character) tracks and applies upgrades. `UpgradeRegistry` autoload scans the upgrades folder at startup and manages the blacklist.

### Game Mode System
`GameMode` (RefCounted) exposes lifecycle hooks: `on_match_start`, `on_round_start`, `on_player_eliminated`, `get_round_winner`, `on_round_end`, `get_match_winner`, `should_offer_upgrades`. Concrete modes override these to implement rule variations.

### Game Rules System
`GameRules` (Resource) holds all match settings: round count, time limit, starting HP, damage scaling, upgrade offers per round, starting upgrades, blacklist, allowed stages/characters, and game mode ID. `RulesSerializer` saves/loads `.tres` files to `user://rules/`.

### Network Layer
`NetworkTransport` (abstract Node) defines the interface. `ENetTransport` wraps `ENetMultiplayerPeer`. `LocalTransport` is a no-op for offline play. `NetworkManager` autoload holds the active transport and bridges to Godot's `multiplayer` singleton.

### Stage System
`StageBase` (Node2D) defines spawn points (Array[NodePath] to Marker2D nodes), blast zone Area2D nodes (named BlastZone*), and camera bounds (Rect2). `Platform` (StaticBody2D) supports optional one-way collision. Camera follows average player position, clamped to stage bounds.

### Game Flow
```
MainMenu
  ├── Online → LobbyScreen → CharacterSelect → StageSelect → GameWorld
  └── Local  → CharacterSelect → StageSelect → GameWorld

GameWorld round loop:
  RoundStart → reset characters → Combat
  → RoundEnd → award round win
  → [non-final round] UpgradeScreen → RoundStart
  → [match winner found] ResultsScreen → MainMenu
```
