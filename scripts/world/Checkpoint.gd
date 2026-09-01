extends Area2D

signal activated(checkpoint: Node)

var height_meters: int = 0
var is_active: bool = false

@onready var flag_polygon: Polygon2D = $FlagPolygon


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if is_active:
		return
	if not body.is_in_group("player"):
		return
	is_active = true
	flag_polygon.color = Color(0.3, 0.9, 0.4)
	activated.emit(self)
