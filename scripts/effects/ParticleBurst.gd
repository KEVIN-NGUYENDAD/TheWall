extends Node2D

var particle_color: Color = Color(0.85, 0.85, 0.9, 1)
var particle_count: int = 8
var particle_speed: float = 120.0
var lifetime: float = 0.4

var _velocities: Array = []
var _age: float = 0.0


func _ready() -> void:
	for i in range(particle_count):
		var angle: float = randf() * TAU
		var speed: float = randf_range(particle_speed * 0.5, particle_speed)
		_velocities.append(Vector2(cos(angle), sin(angle)) * speed)


func _process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t: float = _age / lifetime
	var alpha: float = 1.0 - t
	for v in _velocities:
		var pos: Vector2 = v * _age
		var c: Color = Color(particle_color.r, particle_color.g, particle_color.b, particle_color.a * alpha)
		draw_circle(pos, 3.0 * (1.0 - t) + 1.0, c, true, -1.0, true)
