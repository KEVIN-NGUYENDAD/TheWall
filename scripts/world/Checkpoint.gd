extends Area2D

signal activated(checkpoint: Node)

const BURST_COLORS: Array = [
	Color(1.0, 0.85, 0.3), Color(0.4, 0.9, 1.0), Color(1.0, 0.5, 0.75), Color(0.6, 1.0, 0.5),
]
const BURST_COUNT: int = 14

var height_meters: int = 0
var is_active: bool = false

@onready var flag_polygon: Polygon2D = $FlagPolygon
@onready var glow: Polygon2D = $Glow


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if is_active:
		return
	if not body.is_in_group("player"):
		return
	is_active = true
	flag_polygon.color = Color(0.35, 0.95, 0.45)
	_celebrate()
	activated.emit(self)


func _celebrate() -> void:
	var flag_tween: Tween = create_tween()
	flag_tween.tween_property(flag_polygon, "scale", Vector2(1.9, 1.9), 0.1)
	flag_tween.tween_property(flag_polygon, "scale", Vector2(1.0, 1.0), 0.3)

	glow.visible = true
	glow.scale = Vector2(0.3, 0.3)
	glow.modulate.a = 1.0
	var glow_tween: Tween = create_tween()
	glow_tween.tween_property(glow, "scale", Vector2(8.0, 8.0), 0.5)
	glow_tween.parallel().tween_property(glow, "modulate:a", 0.0, 0.5)
	glow_tween.tween_callback(func(): glow.visible = false)

	_spawn_burst()


func _spawn_burst() -> void:
	for i in range(BURST_COUNT):
		var chip := Polygon2D.new()
		var size: float = randf_range(3.0, 6.0)
		chip.polygon = PackedVector2Array([
			Vector2(-size, -size), Vector2(size, -size), Vector2(size, size), Vector2(-size, size),
		])
		chip.color = BURST_COLORS[i % BURST_COLORS.size()]
		add_child(chip)

		var angle: float = randf() * TAU
		var dist: float = randf_range(40.0, 90.0)
		var target: Vector2 = Vector2(cos(angle), sin(angle) - 0.6) * dist
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(chip, "position", target, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(chip, "rotation", randf_range(-6.0, 6.0), 0.55)
		tween.tween_property(chip, "modulate:a", 0.0, 0.55).set_delay(0.15)
		tween.chain().tween_callback(chip.queue_free)
