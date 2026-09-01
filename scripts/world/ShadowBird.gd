extends Node2D

const FOLLOW_LIFETIME: float = 5.0
const FOLLOW_SPEED: float = 1.5
const OFFSET: Vector2 = Vector2(90, -40)
const FADE_TIME: float = 1.1
const COLOR: Color = Color(0.05, 0.05, 0.08, 0.55)

var target: Node2D = null

var _age: float = 0.0
var _t: float = randf() * TAU
var _fading: bool = false


func _ready() -> void:
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_TIME)


func _process(delta: float) -> void:
	_age += delta
	_t += delta * 3.0

	if _age > FOLLOW_LIFETIME and not _fading:
		_fading = true
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
		tween.tween_callback(queue_free)

	if not _fading and is_instance_valid(target):
		var desired: Vector2 = target.global_position + OFFSET
		global_position = global_position.lerp(desired, FOLLOW_SPEED * delta)

	position.y += sin(_t) * 0.3
	queue_redraw()


func _draw() -> void:
	var wing: float = sin(_t) * 9.0
	draw_line(Vector2(-13, 0), Vector2(0, -wing), COLOR, 3.0, true)
	draw_line(Vector2(13, 0), Vector2(0, -wing), COLOR, 3.0, true)
