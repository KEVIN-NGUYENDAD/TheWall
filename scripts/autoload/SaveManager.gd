extends Node

signal data_changed
signal achievement_unlocked(id: String)
signal coins_changed(total: int)

const SAVE_PATH: String = "user://savegame.json"

const SKINS: Dictionary = {
	"default": {"name": "Default", "color": Color(1.0, 0.45, 0.1), "cost": 0},
	"red": {"name": "Red", "color": Color(0.9, 0.15, 0.15), "cost": 25},
	"yellow": {"name": "Yellow", "color": Color(0.95, 0.85, 0.2), "cost": 50},
	"purple": {"name": "Purple", "color": Color(0.6, 0.3, 0.9), "cost": 100},
	"neon": {"name": "Neon", "color": Color(0.2, 1.0, 0.45), "cost": 200},
}

const ACHIEVEMENTS: Dictionary = {
	"first_jump": {"name": "First Jump", "desc": "Perform your first jump."},
	"height_100": {"name": "Getting Started", "desc": "Reach 100m in a single run."},
	"height_500": {"name": "High Climber", "desc": "Reach 500m in a single run."},
	"height_1000": {"name": "Sky Walker", "desc": "Reach 1000m in a single run."},
	"coins_50": {"name": "Coin Collector", "desc": "Collect 50 coins total."},
	"coins_200": {"name": "Treasure Hunter", "desc": "Collect 200 coins total."},
	"deaths_10": {"name": "Persistent", "desc": "Fall 10 times."},
	"checkpoints_5": {"name": "Checkpoint Master", "desc": "Reach 5 checkpoints in a single run."},
}

var data: Dictionary = {}

# Session-only navigation flags (not persisted): set by MainMenu's Continue /
# Continue Last Session buttons, consumed by Main.gd on load.
var pending_continue: bool = false
var pending_auto_resume: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_game()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()


func _default_data() -> Dictionary:
	return {
		"player_name": "",
		"best_height": 0,
		"checkpoint_height": 0,
		"current_level": 1,
		"current_season": "Spring",
		"total_coins": 0,
		"total_play_time": 0.0,
		"difficulty": "MEDIUM",
		"inventory": {"extra_life": 0, "safe_shield": 0},
		"session": {
			"active": false,
			"pos_x": 0.0,
			"pos_y": 0.0,
			"height": 0.0,
			"season": "Spring",
			"level": 1,
			"jump_boost_remaining": 0.0,
			"ice_grip_remaining": 0.0,
			"weather_blessing_remaining": 0.0,
			"lives": 3,
		},
		"unlocked_skins": ["default"],
		"selected_skin": "default",
		"achievements": {},
		"death_heights": [],
		"memories_seen": [],
		"stats": {
			"total_jumps": 0,
			"total_deaths": 0,
			"total_runs": 0,
			"total_coins_collected": 0,
			"total_checkpoints": 0,
			"best_checkpoints_in_run": 0,
		},
	}


func load_game() -> void:
	data = _default_data()
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) == TYPE_DICTIONARY:
		_merge_defaults(parsed)
		data = parsed


func _merge_defaults(parsed: Dictionary) -> void:
	var defaults := _default_data()
	for key in defaults:
		if not parsed.has(key):
			parsed[key] = defaults[key]
	for key in defaults.stats:
		if not parsed.stats.has(key):
			parsed.stats[key] = defaults.stats[key]
	for key in defaults.inventory:
		if not parsed.inventory.has(key):
			parsed.inventory[key] = defaults.inventory[key]
	for key in defaults.session:
		if not parsed.session.has(key):
			parsed.session[key] = defaults.session[key]


func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data))
	file.close()


func start_run() -> void:
	data.stats.total_runs += 1
	save_game()


func record_jump() -> void:
	data.stats.total_jumps += 1
	if data.stats.total_jumps == 1:
		unlock_achievement("first_jump")


func record_death(height: int = -1) -> void:
	data.stats.total_deaths += 1
	if data.stats.total_deaths >= 10:
		unlock_achievement("deaths_10")
	if height >= 0:
		data.death_heights.append(height)
	save_game()


func record_checkpoint(checkpoints_this_run: int) -> void:
	data.stats.total_checkpoints += 1
	data.stats.best_checkpoints_in_run = max(data.stats.best_checkpoints_in_run, checkpoints_this_run)
	if checkpoints_this_run >= 5:
		unlock_achievement("checkpoints_5")
	save_game()


func update_best_height(height: float) -> void:
	var height_int: int = int(height)
	var changed: bool = false
	if height_int > data.best_height:
		data.best_height = height_int
		changed = true
	if height_int >= 100:
		unlock_achievement("height_100")
	if height_int >= 500:
		unlock_achievement("height_500")
	if height_int >= 1000:
		unlock_achievement("height_1000")
	if changed:
		save_game()
	data_changed.emit()


func add_coins(amount: int) -> void:
	data.total_coins += amount
	data.stats.total_coins_collected += amount
	if data.stats.total_coins_collected >= 50:
		unlock_achievement("coins_50")
	if data.stats.total_coins_collected >= 200:
		unlock_achievement("coins_200")
	coins_changed.emit(data.total_coins)
	data_changed.emit()


func remove_coins(amount: int) -> void:
	data.total_coins = max(0, data.total_coins - amount)
	coins_changed.emit(data.total_coins)
	data_changed.emit()


func has_player_name() -> bool:
	return data.player_name != ""


func set_player_name(new_name: String) -> void:
	data.player_name = new_name
	save_game()


# Single source of truth for "where Continue resumes" — used identically by
# automatic checkpoint activation and the explicit Save Position action, so
# the two are always consistent with each other. A direct overwrite (not a
# max/ratchet) so an explicit Save Position always means exactly what it
# says, even if it's below a checkpoint reached earlier in the run.
func record_progress(checkpoint_height: float, level: int, season: String) -> void:
	data.checkpoint_height = checkpoint_height
	data.current_level = level
	data.current_season = season


func add_play_time(delta: float) -> void:
	data.total_play_time += delta


# Continuously updated (in memory only) while a run is active, so whatever
# the OS/closing the app flushes to disk (see `_notification` above) captures
# an exact mid-run snapshot for Auto Resume — not just the last checkpoint.
func update_session_snapshot(fields: Dictionary) -> void:
	data.session.active = true
	for key in fields:
		data.session[key] = fields[key]


# Called on a deliberate Main Menu exit or a real death — in both cases
# there's no "exact mid-air spot" left to resume, so Auto Resume shouldn't
# offer one; the regular checkpoint-based Continue still works normally.
func clear_session() -> void:
	data.session.active = false


func has_active_session() -> bool:
	return data.session.active


func set_difficulty(difficulty: String) -> void:
	data.difficulty = difficulty
	save_game()


func spend_coins(amount: int) -> bool:
	if data.total_coins < amount:
		return false
	data.total_coins -= amount
	coins_changed.emit(data.total_coins)
	data_changed.emit()
	save_game()
	return true


func add_inventory_item(item: String, count: int = 1) -> void:
	data.inventory[item] = data.inventory.get(item, 0) + count
	save_game()


func use_inventory_item(item: String) -> bool:
	if data.inventory.get(item, 0) <= 0:
		return false
	data.inventory[item] -= 1
	save_game()
	return true


func unlock_skin(id: String) -> bool:
	if not SKINS.has(id):
		return false
	if data.unlocked_skins.has(id):
		return true
	var cost: int = SKINS[id].cost
	if data.total_coins < cost:
		return false
	data.total_coins -= cost
	data.unlocked_skins.append(id)
	coins_changed.emit(data.total_coins)
	data_changed.emit()
	save_game()
	return true


func select_skin(id: String) -> void:
	if data.unlocked_skins.has(id):
		data.selected_skin = id
		data_changed.emit()
		save_game()


func get_selected_skin_color() -> Color:
	var id: String = data.selected_skin
	if SKINS.has(id):
		return SKINS[id].color
	return SKINS["default"].color


func has_seen_memory(height: int) -> bool:
	return data.memories_seen.has(height)


func mark_memory_seen(height: int) -> void:
	if has_seen_memory(height):
		return
	data.memories_seen.append(height)
	save_game()


func unlock_achievement(id: String) -> void:
	if not ACHIEVEMENTS.has(id):
		return
	if data.achievements.get(id, false):
		return
	data.achievements[id] = true
	achievement_unlocked.emit(id)
	save_game()
