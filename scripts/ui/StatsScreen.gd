extends Control

@onready var stats_container: VBoxContainer = $ScrollContainer/VBoxContainer


func _ready() -> void:
	_populate()


func _populate() -> void:
	for child in stats_container.get_children():
		child.queue_free()

	_add_header("Statistics")
	_add_row("Best Height", "%d m" % SaveManager.data.best_height)
	_add_row("Total Coins", str(SaveManager.data.total_coins))
	_add_row("Total Runs", str(SaveManager.data.stats.total_runs))
	_add_row("Total Jumps", str(SaveManager.data.stats.total_jumps))
	_add_row("Total Falls", str(SaveManager.data.stats.total_deaths))
	_add_row("Checkpoints Reached", str(SaveManager.data.stats.total_checkpoints))
	_add_row("Best Checkpoints (1 run)", str(SaveManager.data.stats.best_checkpoints_in_run))

	_add_header("Achievements")
	for id in SaveManager.ACHIEVEMENTS:
		var info: Dictionary = SaveManager.ACHIEVEMENTS[id]
		var unlocked: bool = SaveManager.data.achievements.get(id, false)
		_add_achievement_row(info.name, info.desc, unlocked)


func _add_header(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 24)
	stats_container.add_child(label)


func _add_row(label_text: String, value_text: String) -> void:
	var row := HBoxContainer.new()
	var name_label := Label.new()
	name_label.text = label_text
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var value_label := Label.new()
	value_label.text = value_text
	row.add_child(name_label)
	row.add_child(value_label)
	stats_container.add_child(row)


func _add_achievement_row(title: String, desc: String, unlocked: bool) -> void:
	var row := VBoxContainer.new()
	var name_label := Label.new()
	name_label.text = ("[x] " if unlocked else "[ ] ") + title
	name_label.modulate = Color(1, 1, 1, 1) if unlocked else Color(1, 1, 1, 0.45)
	var desc_label := Label.new()
	desc_label.text = desc
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.modulate = name_label.modulate
	row.add_child(name_label)
	row.add_child(desc_label)
	stats_container.add_child(row)


func _on_back_pressed() -> void:
	AudioManager.play("click")
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
