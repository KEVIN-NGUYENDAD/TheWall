extends StaticBody2D

const WARN_COLOR: Color = Color(0.95, 0.55, 0.2, 1)
const FADE_TIME: float = 0.3

@onready var polygon: Polygon2D = $Polygon2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var detect_area: Area2D = $DetectArea
@onready var collapse_timer: Timer = $CollapseTimer

var triggered: bool = false


func _ready() -> void:
	detect_area.body_entered.connect(_on_body_entered)
	collapse_timer.timeout.connect(_collapse)


func _on_body_entered(body: Node) -> void:
	if triggered or not body.is_in_group("player"):
		return
	triggered = true
	polygon.color = WARN_COLOR
	collapse_timer.start()


func _collapse() -> void:
	collision.disabled = true
	var tween: Tween = create_tween()
	tween.tween_property(polygon, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(queue_free)
