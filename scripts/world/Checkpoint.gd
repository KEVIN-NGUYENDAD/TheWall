extends Area2D

signal activated(checkpoint: Node)

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
	flag_polygon.color = Color(0.3, 0.9, 0.4)
	_celebrate()
	activated.emit(self)


func _celebrate() -> void:
	var flag_tween: Tween = create_tween()
	flag_tween.tween_property(flag_polygon, "scale", Vector2(1.6, 1.6), 0.12)
	flag_tween.tween_property(flag_polygon, "scale", Vector2(1.0, 1.0), 0.25)

	glow.visible = true
	glow.scale = Vector2(0.3, 0.3)
	glow.modulate.a = 1.0
	var glow_tween: Tween = create_tween()
	glow_tween.tween_property(glow, "scale", Vector2(5.0, 5.0), 0.45)
	glow_tween.parallel().tween_property(glow, "modulate:a", 0.0, 0.45)
	glow_tween.tween_callback(func(): glow.visible = false)
