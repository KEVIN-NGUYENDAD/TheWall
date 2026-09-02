extends CanvasLayer

const SLIDE_TIME: float = 0.5
const HOLD_TIME: float = 2.0

@onready var panel: Control = $Panel
@onready var name_label: Label = $Panel/VBox/NameLabel
@onready var title_label: Label = $Panel/VBox/TitleLabel

var _base_top: float
var _base_bottom: float


func _ready() -> void:
	_base_top = panel.offset_top
	_base_bottom = panel.offset_bottom
	panel.offset_top = _base_top - 200.0
	panel.offset_bottom = _base_bottom - 200.0
	panel.modulate.a = 0.0


func show_season(season_name: String) -> void:
	name_label.text = season_name
	panel.offset_top = _base_top - 200.0
	panel.offset_bottom = _base_bottom - 200.0
	panel.modulate.a = 0.0

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "offset_top", _base_top, SLIDE_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "offset_bottom", _base_bottom, SLIDE_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate:a", 1.0, SLIDE_TIME * 0.6)
	tween.chain().tween_interval(HOLD_TIME)
	tween.chain().tween_property(panel, "modulate:a", 0.0, SLIDE_TIME)
