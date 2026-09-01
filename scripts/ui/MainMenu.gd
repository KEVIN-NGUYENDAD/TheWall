extends Control

@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	if OS.has_feature("mobile"):
		quit_button.hide()


func _on_play_pressed() -> void:
	AudioManager.play("click")
	get_tree().change_scene_to_file("res://scenes/world/Main.tscn")


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
