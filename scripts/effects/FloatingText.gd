extends Node2D

const RISE_DISTANCE: float = 46.0
const LIFETIME: float = 0.9

var text: String = ""
var text_color: Color = Color(1, 1, 1, 1)

@onready var label: Label = $Label

var _age: float = 0.0
var _start_y: float


func _ready() -> void:
	_start_y = position.y
	label.text = text
	label.add_theme_color_override("font_color", text_color)


func _process(delta: float) -> void:
	_age += delta
	if _age >= LIFETIME:
		queue_free()
		return
	var t: float = _age / LIFETIME
	position.y = _start_y - RISE_DISTANCE * t
	modulate.a = 1.0 - t
