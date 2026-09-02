extends CanvasLayer

# Final Hotfix: no panel, no scale/pop animation — just small centered text
# that fades in, holds, and fades out. Never blocks the view of gameplay.
const FADE_IN_TIME: float = 0.1
const HOLD_TIME: float = 1.5
const FADE_OUT_TIME: float = 0.3

@onready var level_label: Label = $LevelLabel


func _ready() -> void:
	visible = false


func show_level_up(level: int, _at_jump_cap: bool = false) -> void:
	level_label.text = "LEVEL %d" % level
	level_label.modulate.a = 0.0
	visible = true

	var tween: Tween = create_tween()
	tween.tween_property(level_label, "modulate:a", 1.0, FADE_IN_TIME)
	tween.tween_interval(HOLD_TIME)
	tween.tween_property(level_label, "modulate:a", 0.0, FADE_OUT_TIME)
	tween.tween_callback(func(): visible = false)
