class_name SpriteSheetSlicer
extends RefCounted

## Locates individual animation frames within a horizontal sprite strip. Two strategies:
## slice_grid for uniform fixed-size cells, slice_gutter for variable-width frames
## separated by fully-transparent columns. Both return per-frame regions in pixel space.

## Splits a strip into equal-width, full-height cells laid out left to right.
## frame_width <= 0 means square cells (use the image height). Returns one Rect2i per cell;
## a trailing partial cell (width not an exact multiple) is ignored.
static func slice_grid(image: Image, frame_width: int) -> Array[Rect2i]:
	var frames: Array[Rect2i] = []
	if image == null:
		return frames
	var height: int = image.get_height()
	var width: int = image.get_width()
	var fw: int = frame_width if frame_width > 0 else height
	if fw <= 0 or height <= 0:
		return frames
	var count: int = width / fw
	for i: int in count:
		frames.append(Rect2i(i * fw, 0, fw, height))
	return frames

## Detects frames by scanning columns left to right. A column is a "gutter" when every
## pixel in it has alpha <= alpha_threshold. Each maximal run of non-gutter columns is one
## frame, trimmed to its tight vertical bounds. Handles variable-width/height frames.
static func slice_gutter(image: Image, alpha_threshold: float) -> Array[Rect2i]:
	var frames: Array[Rect2i] = []
	if image == null:
		return frames
	var width: int = image.get_width()
	var height: int = image.get_height()
	if width <= 0 or height <= 0:
		return frames

	var run_start: int = -1
	for x: int in width:
		var occupied: bool = _column_has_opaque(image, x, alpha_threshold)
		if occupied and run_start == -1:
			run_start = x
		elif not occupied and run_start != -1:
			frames.append(_trim_vertical(image, run_start, x - 1, alpha_threshold))
			run_start = -1
	if run_start != -1:
		frames.append(_trim_vertical(image, run_start, width - 1, alpha_threshold))
	return frames

## True when any pixel in column x exceeds the alpha cutoff.
static func _column_has_opaque(image: Image, x: int, alpha_threshold: float) -> bool:
	for y: int in image.get_height():
		if image.get_pixel(x, y).a > alpha_threshold:
			return true
	return false

## Shrinks the [x_start, x_end] column span to the tightest rect containing all opaque
## pixels, so a frame's height matches its content rather than the full sheet height.
static func _trim_vertical(image: Image, x_start: int, x_end: int, alpha_threshold: float) -> Rect2i:
	var height: int = image.get_height()
	var top: int = height
	var bottom: int = -1
	for y: int in height:
		for x: int in range(x_start, x_end + 1):
			if image.get_pixel(x, y).a > alpha_threshold:
				top = mini(top, y)
				bottom = maxi(bottom, y)
				break
	if bottom < top:
		# Fully transparent span (shouldn't happen for a detected run); keep full height.
		return Rect2i(x_start, 0, x_end - x_start + 1, height)
	return Rect2i(x_start, top, x_end - x_start + 1, bottom - top + 1)
