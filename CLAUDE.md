# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

RogueFighter is a Godot 4.7 game project. The engine is configured with:
- **Renderer**: GL Compatibility (cross-platform, mobile-friendly)
- **Physics**: Jolt Physics (3D)
- **Window**: Canvas items stretch with expand aspect ratio

## Running the project

Open and run the project via the Godot editor:
```
godot --path /Users/samuelgray/Projects/RogueFighter
```

Or headless (no display, for CI/testing):
```
godot --path /Users/samuelgray/Projects/RogueFighter --headless
```

Export from the command line (after configuring export presets in the editor):
```
godot --path /Users/samuelgray/Projects/RogueFighter --export-release "macOS" build/RogueFighter.dmg
```

## Godot conventions

- Scenes are `.tscn` files; scripts are `.gd` (GDScript) files attached to scene nodes.
- `project.godot` is the engine config — edit via the Godot editor UI, not manually.
- `.godot/` is auto-generated cache; never commit changes inside it.
- Use `snake_case` for variables, functions, and file names; `PascalCase` for class names and node names.
- Prefer `@export` variables for designer-tunable values over hard-coded constants.
- Signal connections should be made in `_ready()` or via the editor; prefer code-side connections for dynamic nodes.
- `res://` is the project root; `user://` is the user data directory (saves, logs).

## Coding rules

- **GDScript only** — all new code must be written in GDScript (`.gd`), not C# or C++.
- **Static typing always** — every variable, parameter, and return type must have an explicit type annotation. No untyped declarations.
- **Performance and reusability** — write systems with extensibility in mind; avoid one-off solutions that can't be built upon.
- **Scoped changes** — keep edits strictly limited to the feature or fix being worked on. Do not refactor or re-analyze unrelated code in the same pass.

## Documentation

- Systems and major code additions must be documented in the `docs/` folder at the project root.
- Documentation must be written for [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) — use Markdown with Material-compatible admonitions, tabs, and code blocks where appropriate. A `mkdocs.yml` config at the project root configures the site.
- **Do not update documentation unless explicitly asked to.** Creating or editing docs is a separate, opt-in step.
