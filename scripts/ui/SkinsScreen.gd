extends Control

@onready var grid: GridContainer = $ScrollContainer/GridContainer
@onready var coins_label: Label = $CoinsLabel


func _ready() -> void:
	SaveManager.data_changed.connect(_populate)
	_populate()


func _populate() -> void:
	coins_label.text = "Coins: %d" % SaveManager.data.total_coins
	for child in grid.get_children():
		child.queue_free()

	for id in SaveManager.SKINS:
		grid.add_child(_build_skin_card(id))


func _build_skin_card(id: String) -> Control:
	var info: Dictionary = SaveManager.SKINS[id]
	var unlocked: bool = SaveManager.data.unlocked_skins.has(id)
	var selected: bool = SaveManager.data.selected_skin == id

	var card := VBoxContainer.new()
	card.custom_minimum_size = Vector2(140, 160)

	var swatch := ColorRect.new()
	swatch.custom_minimum_size = Vector2(80, 80)
	swatch.color = info.color if unlocked else info.color.darkened(0.6)
	swatch.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var name_label := Label.new()
	name_label.text = info.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var action_button := Button.new()
	if selected:
		action_button.text = "Equipped"
		action_button.disabled = true
	elif unlocked:
		action_button.text = "Equip"
		action_button.pressed.connect(func(): _on_equip_pressed(id))
	else:
		action_button.text = "Unlock (%d)" % info.cost
		action_button.pressed.connect(func(): _on_unlock_pressed(id))

	card.add_child(swatch)
	card.add_child(name_label)
	card.add_child(action_button)
	return card


func _on_equip_pressed(id: String) -> void:
	AudioManager.play("click")
	SaveManager.select_skin(id)


func _on_unlock_pressed(id: String) -> void:
	if SaveManager.unlock_skin(id):
		AudioManager.play("unlock")
	else:
		AudioManager.play("click")


func _on_back_pressed() -> void:
	AudioManager.play("click")
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
