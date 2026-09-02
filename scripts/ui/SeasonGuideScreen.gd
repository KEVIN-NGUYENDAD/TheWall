extends Control

const SEASONS: Array = [
	{"name": "🌸 SPRING (0-100m)", "points": ["Beautiful", "Easiest"]},
	{"name": "☀ SUMMER (100-250m)", "points": ["Sunny", "More challenging"]},
	{"name": "❄ WINTER (250-450m)", "points": ["Snow", "Slippery — but beautiful"]},
	{"name": "🍂 AUTUMN (450-700m)", "points": ["Golden leaves", "Balanced challenge"]},
	{"name": "🌧 STORM (700m+)", "points": ["Rain", "Wind", "Hardest"]},
]

@onready var list: VBoxContainer = $ScrollContainer/VBoxContainer


func _ready() -> void:
	for season in SEASONS:
		list.add_child(_build_entry(season.name, season.points))


func _build_entry(season_name: String, points: Array) -> Control:
	var box := VBoxContainer.new()

	var title := Label.new()
	title.text = season_name
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	title.add_theme_constant_override("outline_size", 4)
	box.add_child(title)

	for point in points:
		var line := Label.new()
		line.text = "- %s" % point
		line.add_theme_font_size_override("font_size", 15)
		line.add_theme_color_override("font_color", Color(0.9, 0.92, 0.98, 1))
		line.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
		line.add_theme_constant_override("outline_size", 3)
		box.add_child(line)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 12)
	box.add_child(spacer)

	return box


func _on_back_pressed() -> void:
	AudioManager.play("click")
	get_tree().change_scene_to_file("res://scenes/ui/SettingsScreen.tscn")
