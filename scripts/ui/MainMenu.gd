extends Control

@onready var welcome_label: Label = $CenterContainer/VBoxContainer/WelcomeLabel
@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var menu_box: VBoxContainer = $CenterContainer/VBoxContainer
@onready var name_prompt: Control = $NamePrompt
@onready var name_edit: LineEdit = $NamePrompt/Panel/VBox/NameEdit


func _ready() -> void:
	MusicManager.play_menu()

	if SaveManager.has_player_name():
		welcome_label.text = "Welcome Back %s" % SaveManager.data.player_name
		name_prompt.hide()
		menu_box.show()
	else:
		name_prompt.show()
		menu_box.hide()
		name_edit.grab_focus()

	continue_button.visible = SaveManager.data.checkpoint_height > 0.0


func _on_confirm_name_pressed() -> void:
	_confirm_name(name_edit.text)


func _on_name_submitted(text: String) -> void:
	_confirm_name(text)


func _confirm_name(entered_text: String) -> void:
	var entered: String = entered_text.strip_edges()
	if entered == "":
		entered = "Climber"
	SaveManager.set_player_name(entered)
	welcome_label.text = "Welcome Back %s" % entered
	name_prompt.hide()
	menu_box.show()


func _on_play_pressed() -> void:
	AudioManager.play("click")
	SaveManager.pending_continue = false
	get_tree().change_scene_to_file("res://scenes/world/Main.tscn")


func _on_continue_pressed() -> void:
	AudioManager.play("click")
	SaveManager.pending_continue = true
	get_tree().change_scene_to_file("res://scenes/world/Main.tscn")


func _on_settings_pressed() -> void:
	AudioManager.play("click")
	get_tree().change_scene_to_file("res://scenes/ui/SettingsScreen.tscn")
