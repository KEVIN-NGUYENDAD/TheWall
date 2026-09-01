extends Area2D

signal hit_player(knockback: Vector2)

const DIVE_SPEED: float = 340.0
const LIFETIME: float = 4.0
const KNOCKBACK_STRENGTH: float = 500.0
const COLOR: Color = Color(0.55, 0.12, 0.14, 0.9)

var dive_velocity: Vector2 = Vector2.ZERO
var _age: float = 0.0
var _triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func aim_at(target_pos: Vector2) -> void:
	dive_velocity = (target_pos - global_position).normalized() * DIVE_SPEED
	rotation = dive_velocity.angle()


func _process(delta: float) -> void:
	_age += delta
	if _age > LIFETIME:
		queue_free()
		return
	global_position += dive_velocity * delta
	queue_redraw()


func _on_body_entered(body: Node) -> void:
	if _triggered or not body.is_in_group("player"):
		return
	_triggered = true
	var knockback: Vector2 = dive_velocity.normalized() * KNOCKBACK_STRENGTH
	knockback.y = -abs(knockback.y) - 200.0
	hit_player.emit(knockback)
	queue_free()


func _draw() -> void:
	draw_line(Vector2(-14, -6), Vector2(0, 0), COLOR, 3.0, true)
	draw_line(Vector2(14, -6), Vector2(0, 0), COLOR, 3.0, true)
	draw_line(Vector2(0, 0), Vector2(10, 5), COLOR, 3.0, true)
