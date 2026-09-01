extends CanvasLayer

const FADE_TIME: float = 0.7
const HOLD_TIME: float = 2.6

@onready var dim: ColorRect = $Dim
@onready var message_label: Label = $MessageLabel


func show_memory(text: String) -> void:
	message_label.text = text
	dim.modulate.a = 0.0
	message_label.modulate.a = 0.0
	visible = true
	get_tree().paused = true

	var tween: Tween = create_tween()
	tween.tween_property(dim, "modulate:a", 1.0, FADE_TIME)
	tween.parallel().tween_property(message_label, "modulate:a", 1.0, FADE_TIME)
	tween.tween_interval(HOLD_TIME)
	tween.tween_property(dim, "modulate:a", 0.0, FADE_TIME)
	tween.parallel().tween_property(message_label, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(_on_finished)


func _on_finished() -> void:
	visible = false
	get_tree().paused = false
