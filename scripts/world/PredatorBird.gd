extends Area2D

signal hit_player(knockback: Vector2)

const TELEGRAPH_TIME: float = 0.7
const DIVE_SPEED: float = 340.0
const LIFETIME: float = 4.0
const KNOCKBACK_STRENGTH: float = 500.0
const COLOR: Color = Color(0.6, 0.15, 0.18, 0.95)
const WARNING_COLOR: Color = Color(0.95, 0.35, 0.1, 1.0)

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
	rotation = dive_velocity.angle()


func _on_body_entered(body: Node) -> void:
	if _triggered or not _diving or not body.is_in_group("player"):
		return
	_triggered = true
	var knockback: Vector2 = dive_velocity.normalized() * KNOCKBACK_STRENGTH
	knockback.y = -abs(knockback.y) - 200.0
	hit_player.emit(knockback)
	queue_free()


func _draw() -> void:
	if not _diving:
		var pulse: float = 0.6 + 0.4 * sin(_telegraph_t * TAU * 3.0)
		draw_circle(Vector2.ZERO, 26.0, Color(WARNING_COLOR.r, WARNING_COLOR.g, WARNING_COLOR.b, 0.25 * pulse), true, -1.0, true)
		var c: Color = Color(WARNING_COLOR.r, WARNING_COLOR.g, WARNING_COLOR.b, pulse)
		draw_line(Vector2(-20, -9), Vector2(0, 0), c, 4.5, true)
		draw_line(Vector2(20, -9), Vector2(0, 0), c, 4.5, true)
		draw_line(Vector2(0, 0), Vector2(15, 8), c, 4.5, true)
	else:
		draw_line(Vector2(-20, -9), Vector2(0, 0), COLOR, 4.5, true)
		draw_line(Vector2(20, -9), Vector2(0, 0), COLOR, 4.5, true)
		draw_line(Vector2(0, 0), Vector2(15, 8), COLOR, 4.5, true)
