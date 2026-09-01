extends Area2D

signal collected(bonus_height_m: float)

const SPEED: float = 100.0
const LIFETIME: float = 12.0
const HEIGHT_BONUS_M: float = 5.0
const COLOR: Color = Color(1.0, 1.0, 1.0, 0.95)
const GLOW_COLOR: Color = Color(1.0, 1.0, 0.9, 0.22)
const TRAIL_LENGTH: int = 8

var direction: float = 1.0

var _t: float = randf() * TAU
var _age: float = 0.0
var _start_y: float
var _collected: bool = false
var _trail: Array = []


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

	_trail.push_front(global_position)
	if _trail.size() > TRAIL_LENGTH:
		_trail.pop_back()

	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if _collected or not body.is_in_group("player"):
		return
	_collected = true
	collected.emit(HEIGHT_BONUS_M)
	queue_free()


func _draw() -> void:
	for i in range(_trail.size()):
		var local_pos: Vector2 = _trail[i] - global_position
		var t_frac: float = float(i) / float(TRAIL_LENGTH)
		var alpha: float = 0.45 * (1.0 - t_frac)
		var size: float = lerp(3.0, 0.5, t_frac)
		draw_circle(local_pos, size, Color(1.0, 1.0, 1.0, alpha), true, -1.0, true)

	draw_circle(Vector2.ZERO, 22.0, GLOW_COLOR, true, -1.0, true)

	var wing: float = sin(_t) * 10.0
	draw_line(Vector2(-12, 0), Vector2(0, -wing), COLOR, 3.0, true)
	draw_line(Vector2(12, 0), Vector2(0, -wing), COLOR, 3.0, true)
	draw_circle(Vector2.ZERO, 4.0, COLOR, true, -1.0, true)
