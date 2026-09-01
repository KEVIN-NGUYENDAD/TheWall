extends Area2D

signal collected

const RADIUS: float = 10.0

var is_collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	rotation += 3.0 * delta
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if is_collected or not body.is_in_group("player"):
		return
	is_collected = true
	collected.emit()
	queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color(0.95, 0.8, 0.2))
	draw_circle(Vector2.ZERO, RADIUS * 0.55, Color(0.8, 0.6, 0.1))
