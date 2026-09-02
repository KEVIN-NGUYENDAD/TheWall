extends CanvasLayer

@onready var rect: ColorRect = $Rect


func flash() -> void:
	rect.modulate.a = 0.55
	var tween: Tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, 0.5)
