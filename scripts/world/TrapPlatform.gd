extends StaticBody2D

signal player_hit

const PULSE_COLOR: Color = Color(1.0, 0.55, 0.2, 1.0)

@onready var detect_area: Area2D = $DetectArea
@onready var polygon: Polygon2D = $Polygon2D

var _triggered: bool = false
var _t: float = randf() * TAU


func _ready() -> void:
	detect_area.body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_t += delta * 3.0
	# Warning throb — stronger, more obvious danger than a flat fill.
	var pulse: float = 0.5 + 0.5 * sin(_t)
	polygon.modulate = Color(1, 1, 1, 1).lerp(PULSE_COLOR, pulse * 0.35)


func _on_body_entered(body: Node) -> void:
	if _triggered or not body.is_in_group("player"):
		return
	_triggered = true
	player_hit.emit()
