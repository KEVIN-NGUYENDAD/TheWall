extends CanvasLayer

signal save_position_requested
signal shop_requested

const CHARGE_LOW_COLOR: Color = Color(0.3, 0.85, 0.4)
const CHARGE_MID_COLOR: Color = Color(0.95, 0.85, 0.2)
const CHARGE_HIGH_COLOR: Color = Color(0.95, 0.3, 0.25)

const SEASON_DISPLAY: Dictionary = {
	"SPRING": "🌸 SPRING",
	"SUMMER": "☀ SUMMER",
	"AUTUMN": "🍂 AUTUMN",
	"WINTER": "❄ WINTER",
	"STORM": "🌧 STORM",
}

@onready var height_label: Label = $HeightLabel
@onready var best_label: Label = $BestLabel
@onready var coin_label: Label = $CoinLabel
@onready var season_label: Label = $SeasonLabel
@onready var lives_label: Label = $LivesLabel
@onready var level_label: Label = $LevelLabel
@onready var level_progress_fill: ColorRect = $LevelProgressBG/LevelProgressFill
@onready var level_progress_label: Label = $LevelProgressBG/LevelProgressLabel
@onready var charge_label: Label = $ChargeLabel
@onready var charge_bar_fill: ColorRect = $ChargeBarBG/ChargeBarFill
@onready var toast: Panel = $Toast
@onready var toast_label: Label = $Toast/ToastLabel
@onready var toast_timer: Timer = $ToastTimer
@onready var pause_overlay: Control = $PauseOverlay


func _ready() -> void:
	SaveManager.achievement_unlocked.connect(_on_achievement_unlocked)
	charge_label.visible = SaveManager.data.stats.total_jumps == 0


func hide_tutorial_hint() -> void:
	charge_label.visible = false


func set_height(current: int, best: int) -> void:
	height_label.text = "Height: %d m" % current
	best_label.text = "Best: %d m" % best


func set_level_progress(level: int, ratio: float) -> void:
	level_label.text = "Level %d" % level
	var clamped: float = clamp(ratio, 0.0, 1.0)
	level_progress_fill.anchor_right = clamped
	level_progress_label.text = "%d%%" % int(round(clamped * 100.0))


func set_coins(total: int) -> void:
	coin_label.text = "%d" % total


func set_season(season_name: String) -> void:
	season_label.text = SEASON_DISPLAY.get(season_name, season_name)


func set_lives(current: int, max_lives: int) -> void:
	lives_label.text = "❤".repeat(max(current, 0)) + "🖤".repeat(max(max_lives - current, 0))


func set_charge(ratio: float) -> void:
	var clamped: float = clamp(ratio, 0.0, 1.0)
	charge_bar_fill.anchor_right = clamped
	if clamped < 0.4:
		charge_bar_fill.color = CHARGE_LOW_COLOR
	elif clamped < 0.8:
		charge_bar_fill.color = CHARGE_MID_COLOR
	else:
		charge_bar_fill.color = CHARGE_HIGH_COLOR


func show_toast(text: String, duration: float = 2.0, accent_color: Color = Color(1, 1, 1, 1)) -> void:
	toast_label.text = text
	toast_label.add_theme_color_override("font_color", accent_color)
	toast.visible = true
	toast_timer.start(duration)


func _on_toast_timeout() -> void:
	toast.visible = false


func _on_achievement_unlocked(id: String) -> void:
	var info: Dictionary = SaveManager.ACHIEVEMENTS.get(id, {})
	show_toast("Achievement: %s" % info.get("name", id))
	AudioManager.play("unlock")


func _on_pause_pressed() -> void:
	AudioManager.play("click")
	get_tree().paused = true
	pause_overlay.visible = true


func _on_resume_pressed() -> void:
	AudioManager.play("click")
	get_tree().paused = false
	pause_overlay.visible = false


func _on_save_position_pressed() -> void:
	AudioManager.play("click")
	save_position_requested.emit()


func _on_shop_pressed() -> void:
	AudioManager.play("click")
	shop_requested.emit()


func _on_menu_pressed() -> void:
	AudioManager.play("click")
	get_tree().paused = false
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
