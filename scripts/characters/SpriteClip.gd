class_name SpriteClip
extends Resource

## One action's animation, sourced from a single horizontal PNG sheet. Frames are
## either uniform grid cells (GRID) or detected by transparent gutter columns (GUTTER).
## Collected into a CharacterSpriteSet and turned into SpriteFrames by SpriteFramesBuilder.

enum SliceMode {
	## Fixed-size cells laid out left to right. Reliable for uniform sheets.
	GRID,
	## Variable-width frames separated by fully-transparent columns.
	GUTTER,
}

## Animation name the state machine plays, e.g. one of:
## idle, run, jump, fall, attack, air_attack, stun, knockback.
@export var action: StringName = &""

## Horizontal sprite strip for this action.
@export var sheet: Texture2D

## How frames are located within the sheet.
@export var slice_mode: SliceMode = SliceMode.GRID

## GRID only: width of each cell in pixels. 0 means square cells (use the sheet height).
@export var frame_width: int = 0

## Playback rate in frames per second.
@export var fps: float = 10.0

## Whether the clip loops. Attack clips (attack, air_attack) and jump must be false so
## the attack states can detect completion via CharacterBase.is_action_playing().
@export var loop: bool = true

## GUTTER only: a pixel counts as opaque when its alpha exceeds this cutoff. Columns with
## no opaque pixels are treated as gutters between frames.
@export var alpha_threshold: float = 0.0
