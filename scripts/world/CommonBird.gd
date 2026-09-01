extends Node2D

const SPEED: float = 80.0
const BOB_AMOUNT: float = 10.0
const LIFETIME: float = 14.0
const COLOR: Color = Color(0.1, 0.1, 0.13, 0.9)

var direction: float = 1.0

var _t: float = randf() * TAU
var _age: float = 0.0
var _start_y: float


func _ready() -> void:
	_start_y = position.y


func _process(delta: float) -> void:
	_age += delta
	if _age > LIFETIME:
		queue_free()
		return
	_t += delta * 8.0
	position.x += SPEED * direction * delta
	position.y = _start_y + sin(_t * 0.5) * BOB_AMOUNT
	scale.x = -abs(scale.x) if direction < 0.0 else abs(scale.x)
	queue_redraw()


func _draw() -> void:
	var flap: float = sin(_t)
	var lift: float = flap * 7.0

	# body: small filled teardrop with a short tail and beak for a clear front/back
	var body: PackedVector2Array = PackedVector2Array([
		Vector2(6, 0), Vector2(3, -3), Vector2(-2, -2.5), Vector2(-7, 0),
		Vector2(-2, 2.5), Vector2(3, 3),
	])
	draw_colored_polygon(body, COLOR)

	# wings: filled shapes whose tips rise and fall together (real flap motion, not a static V)
	var wing_template: PackedVector2Array = PackedVector2Array([
		Vector2(-1, -1), Vector2(-16, -3 - lift), Vector2(-10, 1), Vector2(-3, 2),
	])
	draw_colored_polygon(wing_template, COLOR)

	var wing_mirrored: PackedVector2Array = PackedVector2Array()
	for p in wing_template:
		wing_mirrored.append(Vector2(-p.x, p.y))
	draw_colored_polygon(wing_mirrored, COLOR)
