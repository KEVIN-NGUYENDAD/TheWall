extends AnimatableBody2D

const MOVE_DISTANCE: float = 60.0
const MOVE_SPEED: float = 1.2

var start_pos: Vector2
var t: float = 0.0


func _ready() -> void:
	start_pos = position
	t = randf() * TAU


func _physics_process(delta: float) -> void:
	t += delta * MOVE_SPEED
	position.x = start_pos.x + sin(t) * MOVE_DISTANCE
