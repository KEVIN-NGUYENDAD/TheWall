extends Node2D

const SPEED: float = 85.0
const BOB_AMOUNT: float = 12.0
const LIFETIME: float = 14.0
const BODY_COLOR: Color = Color(0.25, 0.55, 0.95, 1.0)
const BELLY_COLOR: Color = Color(1.0, 0.7, 0.25, 1.0)

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
	var lift: float = flap * 11.0

	# body: bright rounded teardrop with a warm belly patch and a clear beak/tail for orientation
	var body: PackedVector2Array = PackedVector2Array([
		Vector2(10, 0), Vector2(5, -5), Vector2(-3, -4), Vector2(-11, 0),
		Vector2(-3, 4), Vector2(5, 5),
	])
	draw_colored_polygon(body, BODY_COLOR)
	draw_circle(Vector2(-1, 1.5), 4.5, BELLY_COLOR, true, -1.0, true)
	draw_colored_polygon(PackedVector2Array([Vector2(9, -1), Vector2(14, 0), Vector2(9, 1)]), Color(1.0, 0.6, 0.15, 1.0))

	# wings: triangles (always a simple, non-self-intersecting polygon at any flap angle)
	# whose tip rises and falls with the flap cycle for real wing motion.
	var wing_template: PackedVector2Array = PackedVector2Array([
		Vector2(-1, -1), Vector2(-24, -4 - lift), Vector2(-4, 3),
	])
	draw_colored_polygon(wing_template, BODY_COLOR)

	var wing_mirrored: PackedVector2Array = PackedVector2Array()
	for p in wing_template:
		wing_mirrored.append(Vector2(-p.x, p.y))
	draw_colored_polygon(wing_mirrored, BODY_COLOR)
