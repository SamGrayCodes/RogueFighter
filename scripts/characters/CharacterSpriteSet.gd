class_name CharacterSpriteSet
extends Resource

## The full set of per-action sprite sheets for one character. Assign to
## CharacterBase.sprite_set to render that character from sprites instead of the
## procedural polygon. Authoring convention: PNG strips under
## resources/sprites/<name>/*.png, this resource at
## resources/characters/<name>_sprites.tres.

@export var clips: Array[SpriteClip] = []
