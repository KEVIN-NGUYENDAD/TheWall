extends CanvasLayer

signal item_purchased(item_id: String)
signal closed

const ITEMS: Dictionary = {
	"extra_life": {"name": "Extra Life", "cost": 20, "desc": "Respawn at your checkpoint instead of dying (once)"},
	"jump_boost": {"name": "Jump Boost", "cost": 10, "desc": "Stronger jumps for 30 seconds"},
	"ice_grip": {"name": "Ice Grip", "cost": 20, "desc": "No Winter/Storm slip for 30 seconds"},
	"weather_blessing": {"name": "Weather Blessing", "cost": 30, "desc": "Turns Winter/Storm pleasant for 30 seconds"},
	"safe_shield": {"name": "Safe Shield", "cost": 50, "desc": "Respawn exactly where you fell, no progress lost (once)"},
}

@onready var coins_label: Label = $Panel/VBox/CoinsLabel
@onready var list: VBoxContainer = $Panel/VBox/ScrollContainer/List


func _ready() -> void:
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
	var row := VBoxContainer.new()

	var title := Label.new()
	title.text = "%s — %d coins" % [info.name, info.cost]
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(1, 1, 1, 1))
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
	buy_button.text = "Buy"
	buy_button.custom_minimum_size = Vector2(0, 44)
	buy_button.pressed.connect(_on_buy_pressed.bind(item_id))
	row.add_child(buy_button)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	row.add_child(spacer)

	return row


func _on_buy_pressed(item_id: String) -> void:
	var cost: int = ITEMS[item_id].cost
	if SaveManager.spend_coins(cost):
		AudioManager.play("unlock")
		item_purchased.emit(item_id)
		_populate()
	else:
		AudioManager.play("click")


func _on_close_pressed() -> void:
	AudioManager.play("click")
	visible = false
	closed.emit()
