extends Control

const SEASONS: Array = [
	{"name": "🌸 SPRING", "points": ["Beautiful weather", "No slipping"]},
	{"name": "☀ SUMMER", "points": ["Bright", "Clear visibility"]},
	{"name": "🍂 AUTUMN", "points": ["Moderate challenge"]},
	{"name": "❄ WINTER", "points": ["Snow", "Slippery platforms"]},
	{"name": "🌧 STORM", "points": ["Rain", "Wind", "Heavy slipping", "Highest difficulty"]},
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
