extends CanvasLayer

const FADE_IN_TIME: float = 0.15
const HOLD_TIME: float = 0.5
const FADE_OUT_TIME: float = 0.35

@onready var panel: Panel = $Panel
@onready var level_label: Label = $Panel/VBox/LevelLabel
@onready var bonus_label: Label = $Panel/VBox/BonusLabel

var bonus_text: String = "Jump +3%"
var max_bonus_text: String = "Jump MAXED"


func _ready() -> void:
	visible = false


func show_level_up(level: int, at_jump_cap: bool = false) -> void:
	level_label.text = "Level %d" % level
	bonus_label.text = max_bonus_text if at_jump_cap else bonus_text
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.7, 0.7)
	visible = true

	var tween: Tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, FADE_IN_TIME)
	tween.parallel().tween_property(panel, "scale", Vector2(1.0, 1.0), FADE_IN_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(HOLD_TIME)
	tween.tween_property(panel, "modulate:a", 0.0, FADE_OUT_TIME)
	tween.tween_callback(func(): visible = false)
