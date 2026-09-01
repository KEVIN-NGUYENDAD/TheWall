extends Area2D

signal collected(bonus_height_m: float)

const SPEED: float = 100.0
const LIFETIME: float = 12.0
const HEIGHT_BONUS_M: float = 5.0
const COLOR: Color = Color(1.0, 1.0, 1.0, 0.95)

var direction: float = 1.0

var _t: float = randf() * TAU
var _age: float = 0.0
var _start_y: float
var _collected: bool = false


func _ready() -> void:
	_start_y = position.y
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_age += delta
	if _age > LIFETIME:
		queue_free()
		return
	_t += delta * 5.0
	position.x += SPEED * direction * delta
	position.y = _start_y + sin(_t) * 14.0
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if _collected or not body.is_in_group("player"):
		return
	_collected = true
	collected.emit(HEIGHT_BONUS_M)
	queue_free()


func _draw() -> void:
	var wing: float = sin(_t) * 10.0
	draw_line(Vector2(-12, 0), Vector2(0, -wing), COLOR, 3.0, true)
	draw_line(Vector2(12, 0), Vector2(0, -wing), COLOR, 3.0, true)
	draw_circle(Vector2.ZERO, 4.0, COLOR, true, -1.0, true)
