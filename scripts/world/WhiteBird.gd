extends Area2D

signal collected(bonus_height_m: float)

const SPEED: float = 100.0
const LIFETIME: float = 12.0
const HEIGHT_BONUS_M: float = 5.0
const COLOR: Color = Color(1.0, 1.0, 0.98, 1.0)
const GLOW_COLOR: Color = Color(1.0, 0.98, 0.85, 0.25)
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
	_t += delta * 6.0
	position.x += SPEED * direction * delta
	position.y = _start_y + sin(_t * 0.5) * 14.0
	scale.x = -abs(scale.x) if direction < 0.0 else abs(scale.x)

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
		var local_pos: Vector2 = (_trail[i] - global_position) * Vector2(sign(scale.x), 1.0)
		var t_frac: float = float(i) / float(TRAIL_LENGTH)
		var alpha: float = 0.5 * (1.0 - t_frac)
		var size: float = lerp(3.5, 0.5, t_frac)
		draw_circle(local_pos, size, Color(1.0, 1.0, 1.0, alpha), true, -1.0, true)

	draw_circle(Vector2.ZERO, 26.0, GLOW_COLOR, true, -1.0, true)

	var flap: float = sin(_t)
	var lift: float = flap * 8.0

	var body: PackedVector2Array = PackedVector2Array([
		Vector2(8, 0), Vector2(4, -4), Vector2(-3, -3), Vector2(-9, 0),
		Vector2(-3, 3), Vector2(4, 4),
	])
	draw_colored_polygon(body, COLOR)

	var wing_template: PackedVector2Array = PackedVector2Array([
		Vector2(-1, -1), Vector2(-19, -4 - lift), Vector2(-12, 1), Vector2(-4, 2.5),
	])
	draw_colored_polygon(wing_template, COLOR)

	var wing_mirrored: PackedVector2Array = PackedVector2Array()
	for p in wing_template:
		wing_mirrored.append(Vector2(-p.x, p.y))
	draw_colored_polygon(wing_mirrored, COLOR)
