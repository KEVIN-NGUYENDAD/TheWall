extends StaticBody2D

signal player_hit

@onready var detect_area: Area2D = $DetectArea

var _triggered: bool = false


func _ready() -> void:
	detect_area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _triggered or not body.is_in_group("player"):
		return
	_triggered = true
	player_hit.emit()
