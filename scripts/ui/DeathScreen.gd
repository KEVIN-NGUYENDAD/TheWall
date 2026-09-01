extends CanvasLayer

signal respawn_requested
signal menu_requested

const NORMAL_TITLE_COLOR: Color = Color(0.95, 0.3, 0.25, 1)
const NEAR_MISS_TITLE_COLOR: Color = Color(0.95, 0.8, 0.2, 1)
const FLASH_COLOR: Color = Color(0.95, 0.8, 0.2, 0.55)

@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var height_label: Label = $Panel/VBoxContainer/HeightLabel
@onready var best_label: Label = $Panel/VBoxContainer/BestLabel
@onready var coins_label: Label = $Panel/VBoxContainer/CoinsLabel
@onready var lost_label: Label = $Panel/VBoxContainer/LostLabel
@onready var near_miss_label: Label = $Panel/VBoxContainer/NearMissLabel
@onready var near_miss_flash: ColorRect = $NearMissFlash


func show_death(height_reached: int, best_height: int, total_coins: int, lost_meters: int, is_near_miss: bool) -> void:
	height_label.text = "You reached %d m" % height_reached
	best_label.text = "Best: %d m" % best_height
	coins_label.text = "Coins: %d" % total_coins
	lost_label.text = "Lost: %d m" % lost_meters
	near_miss_label.visible = is_near_miss

	if is_near_miss:
		title_label.text = "SO CLOSE!"
		title_label.add_theme_color_override("font_color", NEAR_MISS_TITLE_COLOR)
		_play_near_miss_flash()
	else:
		title_label.text = "You Fell!"
		title_label.add_theme_color_override("font_color", NORMAL_TITLE_COLOR)

	visible = true


func _play_near_miss_flash() -> void:
	near_miss_flash.color = FLASH_COLOR
	near_miss_flash.visible = true
	var tween: Tween = create_tween()
	tween.tween_property(near_miss_flash, "color:a", 0.0, 0.5)
	tween.tween_callback(func(): near_miss_flash.visible = false)


func _on_respawn_pressed() -> void:
	AudioManager.play("click")
	visible = false
	respawn_requested.emit()


func _on_menu_pressed() -> void:
	AudioManager.play("click")
	visible = false
	menu_requested.emit()
