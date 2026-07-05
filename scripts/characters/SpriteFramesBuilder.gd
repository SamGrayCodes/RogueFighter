class_name SpriteFramesBuilder
extends RefCounted

## Builds a SpriteFrames from a CharacterSpriteSet at runtime: slices each clip's sheet
## (grid or gutter), normalizes every frame to a common footprint so the character's feet
## stay planted, and adds one animation per action. Returns null if the set is empty or any
## sheet is missing/unreadable/frameless, so the caller can fall back to procedural animation.

static func build(sprite_set: CharacterSpriteSet) -> SpriteFrames:
	if sprite_set == null or sprite_set.clips.is_empty():
		return null

	# First pass: slice every clip and find the largest frame footprint across the set.
	var clips: Array[SpriteClip] = []
	var frames_per_clip: Array = []
	var max_w: int = 0
	var max_h: int = 0
	for clip: SpriteClip in sprite_set.clips:
		if clip == null or clip.sheet == null:
			push_warning("SpriteFramesBuilder: clip missing sheet; falling back to procedural.")
			return null
		var image: Image = clip.sheet.get_image()
		if image == null:
			push_warning("SpriteFramesBuilder: unreadable sheet for '%s'; falling back." % clip.action)
			return null
		var rects: Array[Rect2i] = _slice(clip, image)
		if rects.is_empty():
			push_warning("SpriteFramesBuilder: no frames found for '%s'; falling back." % clip.action)
			return null
		clips.append(clip)
		frames_per_clip.append(rects)
		for r: Rect2i in rects:
			max_w = maxi(max_w, r.size.x)
			max_h = maxi(max_h, r.size.y)

	if max_w <= 0 or max_h <= 0:
		return null

	# Second pass: assemble the SpriteFrames with padded (bottom-center) atlas frames.
	var frames: SpriteFrames = SpriteFrames.new()
	if frames.has_animation(&"default"):
		frames.remove_animation(&"default")
	for i: int in clips.size():
		var clip: SpriteClip = clips[i]
		var rects: Array[Rect2i] = frames_per_clip[i]
		var anim: StringName = clip.action
		# Later clips win if two share an action name.
		if frames.has_animation(anim):
			frames.remove_animation(anim)
		frames.add_animation(anim)
		frames.set_animation_speed(anim, clip.fps)
		frames.set_animation_loop(anim, clip.loop)
		for r: Rect2i in rects:
			frames.add_frame(anim, _make_frame_texture(clip.sheet, r, max_w, max_h))
	return frames

## Dispatches to the slicing strategy the clip requests.
static func _slice(clip: SpriteClip, image: Image) -> Array[Rect2i]:
	if clip.slice_mode == SpriteClip.SliceMode.GUTTER:
		return SpriteSheetSlicer.slice_gutter(image, clip.alpha_threshold)
	return SpriteSheetSlicer.slice_grid(image, clip.frame_width)

## Wraps one frame region in an AtlasTexture, padded to (max_w, max_h) with the content
## bottom-center aligned. Uniform grids yield zero padding; variable frames get centered
## horizontally and bottom-aligned so the feet line up across differently-sized frames.
static func _make_frame_texture(sheet: Texture2D, region: Rect2i, max_w: int, max_h: int) -> AtlasTexture:
	var tex: AtlasTexture = AtlasTexture.new()
	tex.atlas = sheet
	tex.region = Rect2(region.position, region.size)
	var pad_x: int = max_w - region.size.x
	var pad_y: int = max_h - region.size.y
	tex.margin = Rect2(pad_x / 2, pad_y, pad_x, pad_y)
	return tex
