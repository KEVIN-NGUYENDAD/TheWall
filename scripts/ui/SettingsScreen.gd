extends Control

@onready var name_label: Label = $CenterContainer/VBoxContainer/NameLabel
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	name_label.text = "Player: %s" % SaveManager.data.player_name
	if OS.has_feature("mobile"):
		quit_button.hide()


func _on_change_name_pressed() -> void:
	AudioManager.play("click")
	SaveManager.data.player_name = ""
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")


func _on_skins_pressed() -> void:
	AudioManager.play("click")
	get_tree().change_scene_to_file("res://scenes/ui/SkinsScreen.tscn")


func _on_stats_pressed() -> void:
	AudioManager.play("click")
	get_tree().change_scene_to_file("res://scenes/ui/StatsScreen.tscn")


func _on_quit_pressed() -> void:
	AudioManager.play("click")
	SaveManager.save_game()
	get_tree().quit()


func _on_back_pressed() -> void:
	AudioManager.play("click")
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
