extends CanvasLayer

signal save_requested
signal upgrade_requested
signal continue_requested

@onready var height_label: Label = $Panel/VBox/HeightLabel
@onready var stats_label: Label = $Panel/VBox/StatsLabel


func _ready() -> void:
	visible = false


func open(height: int) -> void:
	height_label.text = "You reached %dm!" % height
	stats_label.text = "Best: %dm   Coins: %d   Difficulty: %s" % [
		SaveManager.data.best_height, SaveManager.data.total_coins, SaveManager.data.difficulty,
	]
	visible = true


func _on_save_pressed() -> void:
	AudioManager.play("click")
	save_requested.emit()


func _on_upgrade_pressed() -> void:
	AudioManager.play("click")
	upgrade_requested.emit()


func _on_continue_pressed() -> void:
	AudioManager.play("click")
	visible = false
	continue_requested.emit()
