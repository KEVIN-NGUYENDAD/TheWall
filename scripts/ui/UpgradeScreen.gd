extends CanvasLayer

signal upgrade_purchased(item_id: String)
signal closed

# Permanent, one-time-purchase upgrades — replaces the old cosmetic Skins
# menu and the old Shop's temporary 30s buffs. Effects are applied by
# Main.gd (some need to take hold immediately mid-run).
const ITEMS: Dictionary = {
	"coin_magnet": {"name": "Coin Magnet", "cost": 100, "desc": "Nearby coins fly to you automatically"},
	"jump_boost": {"name": "Jump Boost", "cost": 150, "desc": "+15% jump force, permanently"},
	"shield": {"name": "Shield", "cost": 200, "desc": "Blocks one death automatically, then recharges"},
	"double_jump": {"name": "Double Jump", "cost": 300, "desc": "Jump again once in mid-air"},
	"extra_heart": {"name": "Extra Heart", "cost": 400, "desc": "+1 max life, permanently"},
	"speed_boost": {"name": "Speed Boost", "cost": 250, "desc": "+20% horizontal move speed"},
}

@onready var coins_label: Label = $Panel/VBox/CoinsLabel
@onready var list: VBoxContainer = $Panel/VBox/ScrollContainer/List


func _ready() -> void:
	if get_tree().current_scene == self:
		# Standalone (opened from Settings, not inside an active run).
		visible = true
		_populate()
	else:
		# Embedded overlay inside Main.tscn — hidden until open() is called.
		visible = false


func open() -> void:
	visible = true
	_populate()


func _populate() -> void:
	coins_label.text = "Coins: %d" % SaveManager.data.total_coins
	for child in list.get_children():
		child.queue_free()
	for item_id in ITEMS:
		list.add_child(_build_row(item_id))


func _build_row(item_id: String) -> Control:
	var info: Dictionary = ITEMS[item_id]
	var owned: bool = SaveManager.has_upgrade(item_id)
	var row := VBoxContainer.new()

	var title := Label.new()
	title.text = ("%s — OWNED" % info.name) if owned else ("%s — %d coins" % [info.name, info.cost])
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5, 1) if owned else Color(1, 1, 1, 1))
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	title.add_theme_constant_override("outline_size", 4)
	row.add_child(title)

	var desc := Label.new()
	desc.text = info.desc
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.add_theme_font_size_override("font_size", 13)
	desc.add_theme_color_override("font_color", Color(0.9, 0.92, 0.98, 1))
	desc.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	desc.add_theme_constant_override("outline_size", 3)
	row.add_child(desc)

	var buy_button := Button.new()
	buy_button.custom_minimum_size = Vector2(0, 44)
	if owned:
		buy_button.text = "Owned"
		buy_button.disabled = true
	else:
		buy_button.text = "Buy"
		buy_button.pressed.connect(_on_buy_pressed.bind(item_id))
	row.add_child(buy_button)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	row.add_child(spacer)

	return row


func _on_buy_pressed(item_id: String) -> void:
	var cost: int = ITEMS[item_id].cost
	if SaveManager.purchase_upgrade(item_id, cost):
		AudioManager.play("unlock")
		upgrade_purchased.emit(item_id)
		_populate()
	else:
		AudioManager.play("click")


func _on_close_pressed() -> void:
	AudioManager.play("click")
	if get_tree().current_scene == self:
		get_tree().change_scene_to_file("res://scenes/ui/SettingsScreen.tscn")
	else:
		visible = false
		closed.emit()
