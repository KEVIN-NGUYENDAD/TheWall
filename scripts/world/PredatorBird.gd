extends Area2D

# Represents the Eagle hazard: telegraphs a dive, then on contact costs the
# player coins rather than causing knockback or death.
signal hit_player
signal telegraph_started

const TELEGRAPH_TIME: float = 0.7
const DIVE_SPEED: float = 340.0
const LIFETIME: float = 4.0
const COLOR: Color = Color(0.06, 0.02, 0.02, 1.0)
const ACCENT_COLOR: Color = Color(0.2, 0.09, 0.02, 1.0)
const WARNING_COLOR: Color = Color(1.0, 0.55, 0.1, 1.0)
const EYE_COLOR: Color = Color(1.0, 0.95, 0.15, 1.0)

var dive_velocity: Vector2 = Vector2.ZERO

var _age: float = 0.0
var _telegraph_t: float = 0.0
var _diving: bool = false
var _triggered: bool = false
var _target: Node2D = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func begin_telegraph(target: Node2D) -> void:
	_target = target
	telegraph_started.emit()


func _process(delta: float) -> void:
	if not _diving:
		_telegraph_t += delta
		queue_redraw()
		if _telegraph_t >= TELEGRAPH_TIME:
			_start_dive()
		return

	_age += delta
	if _age > LIFETIME:
		queue_free()
		return
	global_position += dive_velocity * delta
	queue_redraw()


func _start_dive() -> void:
	_diving = true
	if is_instance_valid(_target):
		dive_velocity = (_target.global_position - global_position).normalized() * DIVE_SPEED
	else:
		dive_velocity = Vector2.DOWN * DIVE_SPEED
	rotation = dive_velocity.angle() + PI / 2.0


func _on_body_entered(body: Node) -> void:
	if _triggered or not _diving or not body.is_in_group("player"):
		return
	_triggered = true
	hit_player.emit()
	queue_free()


func _body_polygon() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0, -18), Vector2(6, -8), Vector2(5, 8), Vector2(0, 17),
		Vector2(-5, 8), Vector2(-6, -8),
	])


func _draw() -> void:
	if not _diving:
		var pulse: float = 0.55 + 0.45 * sin(_telegraph_t * TAU * 2.0)
		draw_circle(Vector2.ZERO, 46.0, Color(WARNING_COLOR.r, WARNING_COLOR.g, WARNING_COLOR.b, 0.4 * pulse), true, -1.0, true)
		draw_circle(Vector2.ZERO, 30.0, Color(WARNING_COLOR.r, WARNING_COLOR.g, WARNING_COLOR.b, 0.2 * pulse), true, -1.0, true)

		var flap: float = sin(_telegraph_t * TAU * 4.0)
		var spread: float = 18.0 + flap * 8.0
		var body_color: Color = Color(COLOR.r, COLOR.g, COLOR.b, pulse)

		draw_colored_polygon(_body_polygon(), body_color)
		draw_colored_polygon(PackedVector2Array([Vector2(-3, 2), Vector2(3, 2), Vector2(0, 10)]), Color(ACCENT_COLOR.r, ACCENT_COLOR.g, ACCENT_COLOR.b, pulse))
		var left_wing: PackedVector2Array = PackedVector2Array([
			Vector2(-4, -3), Vector2(-spread - 13, -3 - flap * 5), Vector2(-5, 6),
		])
		draw_colored_polygon(left_wing, body_color)
		var right_wing: PackedVector2Array = PackedVector2Array()
		for p in left_wing:
			right_wing.append(Vector2(-p.x, p.y))
		draw_colored_polygon(right_wing, body_color)
		draw_circle(Vector2(0, -12), 2.6, EYE_COLOR, true, -1.0, true)
	else:
		draw_colored_polygon(_body_polygon(), COLOR)
		draw_colored_polygon(PackedVector2Array([Vector2(-3, 2), Vector2(3, 2), Vector2(0, 10)]), ACCENT_COLOR)
		var left_wing: PackedVector2Array = PackedVector2Array([
			Vector2(-4, -5), Vector2(-28, 5), Vector2(-5, 5),
		])
		draw_colored_polygon(left_wing, COLOR)
		var right_wing: PackedVector2Array = PackedVector2Array()
		for p in left_wing:
			right_wing.append(Vector2(-p.x, p.y))
		draw_colored_polygon(right_wing, COLOR)
