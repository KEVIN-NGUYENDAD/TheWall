extends CanvasLayer

signal upgrade_purchased(item_id: String)
signal closed

# Permanent, one-time-purchase upgrades — replaces the old cosmetic Skins
# menu and the old Shop's temporary 30s buffs. Effects are applied by
# Main.gd (some need to take hold immediately mid-run).
const ITEMS: Dictionary = {
	"coin_magnet": {"name": "Coin Magnet", "icon": "🧲", "cost": 100, "desc": "Nearby coins fly to you automatically"},
	"jump_boost": {"name": "Jump Boost", "icon": "⬆", "cost": 150, "desc": "+15% jump force, permanently"},
	"shield": {"name": "Shield", "icon": "🛡", "cost": 200, "desc": "Blocks one death automatically, then recharges"},
	"double_jump": {"name": "Double Jump", "icon": "🔁", "cost": 300, "desc": "Jump again once in mid-air"},
	"extra_heart": {"name": "Extra Heart", "icon": "❤", "cost": 400, "desc": "+1 max life, permanently"},
	"speed_boost": {"name": "Speed Boost", "icon": "💨", "cost": 250, "desc": "+20% horizontal move speed"},
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

	var outer := VBoxContainer.new()

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	outer.add_child(hbox)

	# Icon — every upgrade gets a distinct glyph so the list reads at a
	# glance instead of being a wall of identical rows with only text.
	var icon := Label.new()
	icon.text = info.icon
	icon.add_theme_font_size_override("font_size", 30)
	icon.custom_minimum_size = Vector2(44, 44)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icon)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(text_col)

	var title := Label.new()
	title.text = "%s — %d coins" % [info.name, info.cost]
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	title.add_theme_constant_override("outline_size", 4)
	text_col.add_child(title)

	var desc := Label.new()
	desc.text = info.desc
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.add_theme_font_size_override("font_size", 13)
	desc.add_theme_color_override("font_color", Color(0.9, 0.92, 0.98, 1))
	desc.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	desc.add_theme_constant_override("outline_size", 3)
	text_col.add_child(desc)

	if owned:
		# A dedicated status badge, not just a disabled button — "owned or
		# not" should be readable without looking at the button at all.
		var badge := Label.new()
		badge.text = "✓ OWNED"
		badge.add_theme_font_size_override("font_size", 15)
		badge.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5, 1))
		badge.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
		badge.add_theme_constant_override("outline_size", 3)
		text_col.add_child(badge)
	else:
		var buy_button := Button.new()
		buy_button.custom_minimum_size = Vector2(0, 44)
		buy_button.text = "Buy"
		buy_button.pressed.connect(_on_buy_pressed.bind(item_id))
		text_col.add_child(buy_button)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	outer.add_child(spacer)

	return outer


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
