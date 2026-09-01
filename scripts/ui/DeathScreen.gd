extends CanvasLayer

signal respawn_requested
signal menu_requested

@onready var height_label: Label = $Panel/VBoxContainer/HeightLabel
@onready var best_label: Label = $Panel/VBoxContainer/BestLabel
@onready var coins_label: Label = $Panel/VBoxContainer/CoinsLabel


func show_death(height_reached: int, best_height: int, total_coins: int) -> void:
	height_label.text = "You reached %d m" % height_reached
	best_label.text = "Best: %d m" % best_height
	coins_label.text = "Coins: %d" % total_coins
	visible = true


func _on_respawn_pressed() -> void:
	AudioManager.play("click")
	visible = false
	respawn_requested.emit()


func _on_menu_pressed() -> void:
	AudioManager.play("click")
	visible = false
	menu_requested.emit()
