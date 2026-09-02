extends Area2D

signal collected

const SPEED: float = 85.0
const BOB_AMOUNT: float = 12.0
const LIFETIME: float = 14.0
const BODY_COLOR: Color = Color(1.0, 0.42, 0.0, 1.0)
const BELLY_COLOR: Color = Color(1.0, 0.98, 0.7, 1.0)

var direction: float = 1.0

var _t: float = randf() * TAU
var _age: float = 0.0
var _start_y: float
var _collected: bool = false


func _ready() -> void:
	_start_y = position.y
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _collected or not body.is_in_group("player"):
		return
	_collected = true
	collected.emit()
	queue_free()


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
	var tip_flap: float = sin(_t - 0.5)
	var lift: float = flap * 9.0
	var tip_lift: float = tip_flap * 15.0

	rotation = clamp(flap * 0.1, -0.1, 0.1)

	# body: bright rounded teardrop with a warm belly patch and a clear beak/tail for orientation
	var body: PackedVector2Array = PackedVector2Array([
		Vector2(10, 0), Vector2(5, -5), Vector2(-3, -4), Vector2(-11, 0),
		Vector2(-3, 4), Vector2(5, 5),
	])
	draw_colored_polygon(body, BODY_COLOR)
	draw_circle(Vector2(-1, 1.5), 4.5, BELLY_COLOR, true, -1.0, true)
	draw_colored_polygon(PackedVector2Array([Vector2(9, -1), Vector2(14, 0), Vector2(9, 1)]), Color(1.0, 0.6, 0.15, 1.0))

	# wings: two hinged triangles (each always simple/non-self-intersecting) — an
	# inner wing segment plus a tip segment that lags in phase, so the wingtip
	# whips past the main stroke the way real flight feathers trail the beat.
	var shoulder: Vector2 = Vector2(-1, -1)
	var mid: Vector2 = Vector2(-15, -3 - lift)
	var inner_wing: PackedVector2Array = PackedVector2Array([shoulder, mid, Vector2(-4, 3)])
	draw_colored_polygon(inner_wing, BODY_COLOR)

	var tip_wing: PackedVector2Array = PackedVector2Array([mid, Vector2(-25, -4 - tip_lift), Vector2(-11, 1)])
	draw_colored_polygon(tip_wing, BODY_COLOR)

	for wing in [inner_wing, tip_wing]:
		var mirrored: PackedVector2Array = PackedVector2Array()
		for p in wing:
			mirrored.append(Vector2(-p.x, p.y))
		draw_colored_polygon(mirrored, BODY_COLOR)
