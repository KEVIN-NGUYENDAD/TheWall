extends AnimatableBody2D

# Real Gameplay Pass: distance/speed randomized per instance (was a single
# fixed 60px/1.2 for every moving platform) so timing actually varies and
# players have to watch each one rather than memorize one universal rhythm.
# Kept within the existing reachability safety margins, which already have
# enough headroom to absorb this range without risking an unreachable jump.
const MOVE_DISTANCE_RANGE: Vector2 = Vector2(40.0, 80.0)
const MOVE_SPEED_RANGE: Vector2 = Vector2(0.9, 1.7)

var move_distance: float
var move_speed: float
var start_pos: Vector2
var t: float = 0.0


func _ready() -> void:
	start_pos = position
	t = randf() * TAU
	move_distance = randf_range(MOVE_DISTANCE_RANGE.x, MOVE_DISTANCE_RANGE.y)
	move_speed = randf_range(MOVE_SPEED_RANGE.x, MOVE_SPEED_RANGE.y)


func _physics_process(delta: float) -> void:
	t += delta * move_speed
	position.x = start_pos.x + sin(t) * move_distance
