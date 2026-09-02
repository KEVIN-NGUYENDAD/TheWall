extends Node2D

const PIXELS_PER_METER: float = 50.0
const PLATFORM_COUNT: int = 360
const PLATFORM_SCENE: PackedScene = preload("res://scenes/world/Platform.tscn")
const MOVING_PLATFORM_SCENE: PackedScene = preload("res://scenes/world/MovingPlatform.tscn")
const COLLAPSING_PLATFORM_SCENE: PackedScene = preload("res://scenes/world/CollapsingPlatform.tscn")
const FAKE_PLATFORM_SCENE: PackedScene = preload("res://scenes/world/FakePlatform.tscn")
const TRAP_PLATFORM_SCENE: PackedScene = preload("res://scenes/world/TrapPlatform.tscn")
const CHECKPOINT_SCENE: PackedScene = preload("res://scenes/world/Checkpoint.tscn")
const COIN_SCENE: PackedScene = preload("res://scenes/world/Coin.tscn")
const SPIKE_SCENE: PackedScene = preload("res://scenes/world/Spike.tscn")
const DEATH_MARKER_SCENE: PackedScene = preload("res://scenes/world/DeathMarker.tscn")
const PARTICLE_BURST_SCENE: PackedScene = preload("res://scenes/effects/ParticleBurst.tscn")
const FLOATING_TEXT_SCENE: PackedScene = preload("res://scenes/effects/FloatingText.tscn")
const NEST_SCENE: PackedScene = preload("res://scenes/world/Nest.tscn")
const COMMON_BIRD_SCENE: PackedScene = preload("res://scenes/world/CommonBird.tscn")
const WHITE_BIRD_SCENE: PackedScene = preload("res://scenes/world/WhiteBird.tscn")
const SHADOW_BIRD_SCENE: PackedScene = preload("res://scenes/world/ShadowBird.tscn")
const PREDATOR_BIRD_SCENE: PackedScene = preload("res://scenes/world/PredatorBird.tscn")
const FALLING_FEATHER_SCENE: PackedScene = preload("res://scenes/world/FallingFeather.tscn")
const BUTTERFLY_SCENE: PackedScene = preload("res://scenes/world/Butterfly.tscn")
const LEAF_SCENE: PackedScene = preload("res://scenes/world/Leaf.tscn")
const SNOWFLAKE_SCENE: PackedScene = preload("res://scenes/world/Snowflake.tscn")
const RAINDROP_SCENE: PackedScene = preload("res://scenes/world/RainDrop.tscn")
const FLOWER_DECOR_SCENE: PackedScene = preload("res://scenes/world/FlowerDecor.tscn")
const SEASON_BANNER_SCENE: PackedScene = preload("res://scenes/ui/SeasonBanner.tscn")
const THUNDER_FLASH_SCENE: PackedScene = preload("res://scenes/world/ThunderFlash.tscn")

const VIEWPORT_WIDTH: float = 540.0
const EDGE_MARGIN: float = 90.0
const MIN_GAP: float = 90.0
const MAX_GAP: float = 220.0
const FALL_DEATH_MARGIN: float = 200.0
const CAMERA_TOP_MARGIN: float = 500.0
const CHECKPOINT_INTERVAL_M: int = 100
const COIN_CHANCE: float = 0.45
const SPIKE_CHANCE: float = 0.1
const NEAR_MISS_METERS: float = 5.0
const EAGLE_MIN_HEIGHT_M: float = 100.0
const COMMON_BIRD_SCALE: float = 1.4
const NEST_CHANCE: float = 0.04

# Onboarding safe zone: no hazards, no death, no death markers below this height.
const SAFE_ZONE_HEIGHT_M: float = 20.0
const SPAWN_PROTECTION_TIME: float = 2.0
const SPAWN_PLATFORM_SCALE: Vector2 = Vector2(2.0, 1.0)

const FAKE_PLATFORM_CHANCE: float = 0.05

# Level system: Level N = N-th 300/100m-ish band, each a bit harder than the
# last (more moving/collapsing/trap platforms). Bands match the Season bands.
const LEVEL_HEIGHTS: Array = [0.0, 100.0, 300.0, 600.0, 900.0]
const LEVEL_MOVING_CHANCE: Array = [0.10, 0.14, 0.18, 0.22, 0.26]
const LEVEL_COLLAPSING_CHANCE: Array = [0.08, 0.11, 0.15, 0.19, 0.23]
const LEVEL_TRAP_CHANCE: Array = [0.0, 0.03, 0.05, 0.07, 0.09]

# Platform colors are fixed per TYPE (not per zone) so players can recognize
# hazards at a glance: green=normal, blue=moving, yellow=collapsing,
# purple=fake, red=trap. Season only applies a light modulate tint on top.
const SEASON_NAMES: Array = ["SPRING", "SUMMER", "AUTUMN", "WINTER", "STORM"]
const SEASON_FRICTION_MULT: Array = [1.0, 1.0, 1.0, 0.6, 0.35]
const SEASON_PLATFORM_MODULATE: Array = [
	Color(1, 1, 1), Color(1, 1, 1), Color(1, 1, 1),
	Color(0.82, 0.92, 1.0), Color(0.75, 0.8, 0.88),
]
const WEATHER_INTERVAL: Dictionary = {
	0: 1.2, 1: 0.0, 2: 1.0, 3: 0.9, 4: 0.35,
}
const THUNDER_INTERVAL_MIN: float = 6.0
const THUNDER_INTERVAL_MAX: float = 14.0
const FLOWER_CHANCE: float = 0.2

# Difficulty modes: multipliers applied on top of the base level curve.
const DIFFICULTY_TRAP_MULT: Dictionary = {"EASY": 0.4, "MEDIUM": 1.0, "HARD": 1.8}
const DIFFICULTY_HAZARD_MULT: Dictionary = {"EASY": 0.65, "MEDIUM": 1.0, "HARD": 1.4}
const DIFFICULTY_GAP_MULT: Dictionary = {"EASY": 0.85, "MEDIUM": 1.0, "HARD": 1.15}
const DIFFICULTY_BIRD_INTERVAL_MULT: Dictionary = {"EASY": 0.6, "MEDIUM": 1.0, "HARD": 1.6}
const DIFFICULTY_EAGLE_CHANCE_MULT: Dictionary = {"EASY": 0.5, "MEDIUM": 1.0, "HARD": 1.6}

# Coin-reward power-ups (Shop).
const BUFF_DURATION: float = 30.0
const JUMP_BOOST_MULT: float = 1.25

const MEMORY_HEIGHTS: Array = [100, 300, 700, 1500]
const MEMORY_TEXTS: Dictionary = {
	100: "Someone climbed before you.",
	300: "They did not reach the top.",
	700: "The wall remembers why.",
	1500: "You are not the first to come this far.",
}

const CHECKPOINT_SHAKE_STRENGTH: float = 4.0
const CHECKPOINT_SHAKE_DURATION: float = 0.25
const EAGLE_SHAKE_STRENGTH: float = 2.5
const EAGLE_SHAKE_DURATION: float = 0.2

const COIN_TEXT_COLOR: Color = Color(0.95, 0.85, 0.2, 1)
const EAGLE_TEXT_COLOR: Color = Color(0.95, 0.25, 0.2, 1)

const MARKER_MERGE_DISTANCE_M: float = 8.0

# Area Progression: THE RUINS (0-100m) / THE SKY (100-500m) / THE VOID (500m+)
const ZONE_SKY_START_M: float = 100.0
const ZONE_VOID_START_M: float = 500.0
const VOID_INTENSITY_CAP_M: float = 1500.0
const ZONE_TRANSITION_TIME: float = 2.5

const ZONE_SKY_COLORS: Dictionary = {
	0: Color(0.5, 0.8, 0.98, 1),
	1: Color(0.25, 0.6, 1.0, 1),
	2: Color(0.4, 0.35, 0.85, 1),
}
const ZONE_MOUNTAIN_COLORS: Dictionary = {
	0: Color(0.45, 0.8, 0.5, 1),
	1: Color(0.55, 0.75, 1.0, 1),
	2: Color(0.55, 0.45, 0.9, 1),
}
const ZONE_HILL_COLORS: Dictionary = {
	0: Color(0.55, 0.85, 0.5, 1),
	1: Color(0.7, 0.85, 1.0, 1),
	2: Color(0.65, 0.55, 0.95, 1),
}
const ZONE_CLOUD_COLORS: Dictionary = {
	0: Color(1.0, 1.0, 1.0, 1.0),
	1: Color(1.0, 1.0, 1.0, 1.0),
	2: Color(0.95, 0.92, 1.0, 0.85),
}
const CLOUD_DRIFT_SPEED: float = 16.0
const CLOUD_DRIFT_RANGE: float = 620.0

@onready var player: CharacterBody2D = $Player
@onready var hud = $HUD
@onready var camera: Camera2D = $Player/Camera2D
@onready var death_screen = $DeathScreen
@onready var memory_overlay = $MemoryOverlay
@onready var wind_layer: Node2D = $WindLayer
@onready var season_banner = $SeasonBanner
@onready var thunder_flash = $ThunderFlash
@onready var shop_screen = $ShopScreen

@onready var mountains: Array = [
	$ParallaxBackground/Far/Mountain1, $ParallaxBackground/Far/Mountain2,
	$ParallaxBackground/Far/Mountain3, $ParallaxBackground/Far/Mountain4,
]
@onready var hills: Array = [$ParallaxBackground/Mid/Hill1, $ParallaxBackground/Mid/Hill2]
@onready var clouds: Array = [
	$ParallaxBackground/Near/Cloud1, $ParallaxBackground/Near/Cloud2,
	$ParallaxBackground/Near/Cloud3, $ParallaxBackground/Near/Cloud4,
]

var spawn_position: Vector2
var current_checkpoint_position: Vector2
var current_checkpoint_height: float = 0.0
var start_y: float
var kill_y: float
var is_dead: bool = false
var checkpoints_this_run: int = 0
var checkpoints: Array = []
var tutorial_hidden: bool = false
var current_zone: int = 0
var current_sky_color: Color = Color(0.5, 0.8, 0.98, 1)
var active_markers: Array = []
var bonus_height_m: float = 0.0
var cloud_drift_t: float = 0.0
var spawn_protection_timer: float = 0.0
var current_level_idx: int = -1
var difficulty: String = "MEDIUM"

var ice_grip_active: bool = false
var weather_blessing_active: bool = false

var common_bird_timer: Timer
var special_bird_timer: Timer
var predator_timer: Timer
var feather_timer: Timer
var weather_timer: Timer
var thunder_timer: Timer
var jump_boost_timer: Timer
var ice_grip_timer: Timer
var weather_blessing_timer: Timer


func _ready() -> void:
	randomize()
	difficulty = SaveManager.data.difficulty
	death_screen.respawn_requested.connect(_on_respawn_requested)
	death_screen.menu_requested.connect(_on_menu_requested)
	player.landed_hard.connect(_on_player_landed_hard)
	player.dashed.connect(_on_player_dashed)
	hud.save_position_requested.connect(_on_save_position_requested)
	hud.shop_requested.connect(_on_shop_requested)
	shop_screen.item_purchased.connect(_on_item_purchased)

	var top_y: float = _generate_platforms()
	player.global_position = spawn_position
	current_checkpoint_position = spawn_position
	current_checkpoint_height = 0.0
	start_y = spawn_position.y
	_setup_camera(top_y)
	_generate_checkpoints(top_y)
	_apply_continue_checkpoint()
	_spawn_recorded_death_markers()
	_setup_ambience_timers()

	spawn_protection_timer = SPAWN_PROTECTION_TIME
	MusicManager.start()
	SaveManager.start_run()


func _generate_platforms() -> float:
	var x: float = VIEWPORT_WIDTH / 2.0
	var y: float = 900.0
	spawn_position = Vector2(x, y - 60.0)
	kill_y = y + FALL_DEATH_MARGIN

	for i in range(PLATFORM_COUNT):
		var height: float = max(0.0, (spawn_position.y - y) / PIXELS_PER_METER)
		var result: Dictionary = _spawn_platform_variant(i, x, y, height)
		var platform: Node = result.node
		var ptype: String = result.type

		if i == 0:
			platform.scale = SPAWN_PLATFORM_SCALE
		elif ptype in ["normal", "moving", "collapsing"]:
			if randf() < COIN_CHANCE:
				_spawn_coin(Vector2(x, y - 50.0))
			if height >= SAFE_ZONE_HEIGHT_M and randf() < SPIKE_CHANCE:
				_spawn_spike(Vector2(x, y))

		if i < PLATFORM_COUNT - 1:
			var gap_mult: float = DIFFICULTY_GAP_MULT.get(difficulty, 1.0)
			y -= randf_range(MIN_GAP, MAX_GAP) * gap_mult
			x = randf_range(EDGE_MARGIN, VIEWPORT_WIDTH - EDGE_MARGIN)

	return y


func _get_level_index(height: float) -> int:
	var idx: int = 0
	for i in range(LEVEL_HEIGHTS.size()):
		if height >= LEVEL_HEIGHTS[i]:
			idx = i
	return idx


func _spawn_platform_variant(i: int, x: float, y: float, height: float) -> Dictionary:
	var scene: PackedScene = PLATFORM_SCENE
	var ptype: String = "normal"

	if i > 0 and height >= SAFE_ZONE_HEIGHT_M:
		var level_idx: int = _get_level_index(height)
		var hazard_mult: float = DIFFICULTY_HAZARD_MULT.get(difficulty, 1.0)
		var trap_mult: float = DIFFICULTY_TRAP_MULT.get(difficulty, 1.0)
		var moving_chance: float = clamp(LEVEL_MOVING_CHANCE[level_idx] * hazard_mult, 0.0, 0.9)
		var collapsing_chance: float = clamp(LEVEL_COLLAPSING_CHANCE[level_idx] * hazard_mult, 0.0, 0.9)
		var trap_chance: float = clamp(LEVEL_TRAP_CHANCE[level_idx] * trap_mult, 0.0, 0.9)

		var roll: float = randf()
		if roll < FAKE_PLATFORM_CHANCE:
			scene = FAKE_PLATFORM_SCENE
			ptype = "fake"
		elif roll < FAKE_PLATFORM_CHANCE + moving_chance:
			scene = MOVING_PLATFORM_SCENE
			ptype = "moving"
		elif roll < FAKE_PLATFORM_CHANCE + moving_chance + collapsing_chance:
			scene = COLLAPSING_PLATFORM_SCENE
			ptype = "collapsing"
		elif roll < FAKE_PLATFORM_CHANCE + moving_chance + collapsing_chance + trap_chance:
			scene = TRAP_PLATFORM_SCENE
			ptype = "trap"

	var platform: Node = scene.instantiate()
	platform.position = Vector2(x, y)
	add_child(platform)
	platform.modulate = SEASON_PLATFORM_MODULATE[_get_level_index(height)]

	if ptype == "trap":
		platform.player_hit.connect(_on_trap_hit)

	if ptype == "normal":
		if i > 0 and height >= SAFE_ZONE_HEIGHT_M and randf() < NEST_CHANCE:
			_spawn_nest(Vector2(x, y - 40.0))
		if _get_level_index(height) == 0 and randf() < FLOWER_CHANCE:
			_spawn_flower(Vector2(x, y - 20.0))

	return {"node": platform, "type": ptype}


func _spawn_flower(pos: Vector2) -> void:
	var flower: Node2D = FLOWER_DECOR_SCENE.instantiate()
	flower.position = pos
	add_child(flower)


func _get_zone_for_height(height: float) -> int:
	if height >= ZONE_VOID_START_M:
		return 2
	elif height >= ZONE_SKY_START_M:
		return 1
	return 0


func _zone_progress(height: float, zone: int) -> float:
	match zone:
		0:
			return clamp(height / ZONE_SKY_START_M, 0.0, 1.0)
		1:
			return clamp((height - ZONE_SKY_START_M) / (ZONE_VOID_START_M - ZONE_SKY_START_M), 0.0, 1.0)
		_:
			return clamp((height - ZONE_VOID_START_M) / (VOID_INTENSITY_CAP_M - ZONE_VOID_START_M), 0.0, 1.0)


func _check_zone_transition(height: float) -> void:
	var zone: int = _get_zone_for_height(height)
	if zone != current_zone:
		current_zone = zone
		AudioManager.play("area_discovery")

		var target_sky: Color = ZONE_SKY_COLORS[zone]
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_method(_set_sky_color, current_sky_color, target_sky, ZONE_TRANSITION_TIME)
		current_sky_color = target_sky

		for m in mountains:
			tween.tween_property(m, "color", ZONE_MOUNTAIN_COLORS[zone], ZONE_TRANSITION_TIME)
		for h in hills:
			tween.tween_property(h, "color", ZONE_HILL_COLORS[zone], ZONE_TRANSITION_TIME)
		for c in clouds:
			tween.tween_property(c, "color", ZONE_CLOUD_COLORS[zone], ZONE_TRANSITION_TIME)


func _check_season_transition(height: float) -> void:
	var level_idx: int = _get_level_index(height)
	if level_idx == current_level_idx:
		return

	var is_first: bool = current_level_idx == -1
	current_level_idx = level_idx
	_recompute_friction()
	MusicManager.play_season(level_idx)

	var interval: float = WEATHER_INTERVAL.get(level_idx, 0.0)
	if interval > 0.0 and not weather_blessing_active:
		_restart_timer(weather_timer, interval, interval * 1.6)
	if level_idx == 4 and not weather_blessing_active:
		_restart_timer(thunder_timer, THUNDER_INTERVAL_MIN, THUNDER_INTERVAL_MAX)

	if not is_first:
		season_banner.show_season(SEASON_NAMES[level_idx])


# Combines the base season friction with any active buffs. Called whenever
# either the season or a buff's active state changes, so nothing can stomp
# on a value another system just set.
func _recompute_friction() -> void:
	if ice_grip_active or weather_blessing_active:
		player.ground_friction_mult = 1.0
	elif current_level_idx >= 0:
		player.ground_friction_mult = SEASON_FRICTION_MULT[current_level_idx]
	else:
		player.ground_friction_mult = 1.0


func _set_sky_color(color: Color) -> void:
	RenderingServer.set_default_clear_color(color)


func _update_cloud_drift(delta: float) -> void:
	cloud_drift_t += delta
	for idx in range(clouds.size()):
		var scroll: float = fmod(cloud_drift_t * CLOUD_DRIFT_SPEED + idx * 155.0, CLOUD_DRIFT_RANGE) - CLOUD_DRIFT_RANGE / 2.0
		var bob: float = sin(cloud_drift_t * 0.6 + idx * 2.1) * 16.0
		clouds[idx].position = Vector2(scroll, bob)


func _spawn_coin(pos: Vector2) -> void:
	var coin: Area2D = COIN_SCENE.instantiate()
	coin.position = pos + Vector2(randf_range(-30.0, 30.0), 0.0)
	add_child(coin)
	coin.collected.connect(_on_coin_collected)


func _spawn_spike(platform_pos: Vector2) -> void:
	var spike: Area2D = SPIKE_SCENE.instantiate()
	var edge_offset: float = 55.0 if randf() < 0.5 else -55.0
	spike.position = platform_pos + Vector2(edge_offset, -12.0)
	add_child(spike)
	spike.player_hit.connect(_on_spike_hit)


func _spawn_nest(pos: Vector2) -> void:
	var nest: Area2D = NEST_SCENE.instantiate()
	nest.position = pos
	add_child(nest)
	nest.discovered.connect(_on_nest_discovered.bind(nest))


func _on_nest_discovered(nest: Node2D) -> void:
	AudioManager.play("chirp")
	# Deferred: this runs from inside an Area2D body_entered callback (physics
	# query flush), and instancing a new collision shape synchronously there
	# throws "Can't change this state while flushing queries."
	call_deferred("_spawn_common_bird_from", nest.global_position, -1.0)
	call_deferred("_spawn_common_bird_from", nest.global_position, 1.0)


func _generate_checkpoints(top_y: float) -> void:
	var total_meters: int = int((spawn_position.y - top_y) / PIXELS_PER_METER)
	var m: int = CHECKPOINT_INTERVAL_M
	while m < total_meters:
		var checkpoint_y: float = spawn_position.y - m * PIXELS_PER_METER
		var checkpoint: Area2D = CHECKPOINT_SCENE.instantiate()
		checkpoint.position = Vector2(VIEWPORT_WIDTH / 2.0, checkpoint_y)
		checkpoint.height_meters = m
		add_child(checkpoint)
		checkpoint.activated.connect(_on_checkpoint_activated)
		checkpoints.append(checkpoint)
		m += CHECKPOINT_INTERVAL_M


func _apply_continue_checkpoint() -> void:
	if not SaveManager.pending_continue:
		return
	SaveManager.pending_continue = false

	var target_height: float = SaveManager.data.checkpoint_height
	if target_height <= 0.0:
		return

	for checkpoint in checkpoints:
		if float(checkpoint.height_meters) <= target_height:
			checkpoint.is_active = true

	var pos: Vector2 = Vector2(VIEWPORT_WIDTH / 2.0, spawn_position.y - target_height * PIXELS_PER_METER - 20.0)
	player.global_position = pos
	current_checkpoint_position = pos
	current_checkpoint_height = target_height


func _spawn_recorded_death_markers() -> void:
	for height in SaveManager.data.death_heights:
		_add_death_marker(float(height))


func _add_death_marker(height: float) -> void:
	if height < SAFE_ZONE_HEIGHT_M:
		return

	for entry in active_markers:
		if abs(entry.height - height) <= MARKER_MERGE_DISTANCE_M:
			entry.count += 1
			entry.node.set_info(int(entry.height), entry.count)
			return

	var marker: Node2D = DEATH_MARKER_SCENE.instantiate()
	marker.position = Vector2(randf_range(EDGE_MARGIN, VIEWPORT_WIDTH - EDGE_MARGIN), spawn_position.y - height * PIXELS_PER_METER)
	add_child(marker)
	marker.set_info(int(height), 1)
	active_markers.append({"height": height, "count": 1, "node": marker})


func _spawn_particle_burst(pos: Vector2, color: Color, count: int, speed: float, lifetime: float) -> void:
	var burst: Node2D = PARTICLE_BURST_SCENE.instantiate()
	burst.particle_color = color
	burst.particle_count = count
	burst.particle_speed = speed
	burst.lifetime = lifetime
	burst.position = pos
	add_child(burst)


func _spawn_floating_text(pos: Vector2, text: String, color: Color) -> void:
	var ft: Node2D = FLOATING_TEXT_SCENE.instantiate()
	ft.text = text
	ft.text_color = color
	ft.position = pos
	add_child(ft)


func _setup_camera(top_y: float) -> void:
	camera.limit_left = 0
	camera.limit_right = int(VIEWPORT_WIDTH)
	camera.limit_bottom = int(kill_y)
	camera.limit_top = int(top_y - CAMERA_TOP_MARGIN)


func _setup_ambience_timers() -> void:
	common_bird_timer = Timer.new()
	common_bird_timer.one_shot = true
	add_child(common_bird_timer)
	common_bird_timer.timeout.connect(_on_common_bird_timer)
	_restart_bird_timer(common_bird_timer, 2.5, 5.0)

	special_bird_timer = Timer.new()
	special_bird_timer.one_shot = true
	add_child(special_bird_timer)
	special_bird_timer.timeout.connect(_on_special_bird_timer)
	_restart_bird_timer(special_bird_timer, 15.0, 25.0)

	predator_timer = Timer.new()
	predator_timer.one_shot = true
	add_child(predator_timer)
	predator_timer.timeout.connect(_on_predator_timer)
	_restart_timer(predator_timer, 30.0, 45.0)

	feather_timer = Timer.new()
	feather_timer.one_shot = true
	add_child(feather_timer)
	feather_timer.timeout.connect(_on_feather_timer)
	_restart_timer(feather_timer, 4.0, 8.0)

	weather_timer = Timer.new()
	weather_timer.one_shot = true
	add_child(weather_timer)
	weather_timer.timeout.connect(_on_weather_timer)

	thunder_timer = Timer.new()
	thunder_timer.one_shot = true
	add_child(thunder_timer)
	thunder_timer.timeout.connect(_on_thunder_timer)

	jump_boost_timer = Timer.new()
	jump_boost_timer.one_shot = true
	add_child(jump_boost_timer)
	jump_boost_timer.timeout.connect(_on_jump_boost_expired)

	ice_grip_timer = Timer.new()
	ice_grip_timer.one_shot = true
	add_child(ice_grip_timer)
	ice_grip_timer.timeout.connect(_on_ice_grip_expired)

	weather_blessing_timer = Timer.new()
	weather_blessing_timer.one_shot = true
	add_child(weather_blessing_timer)
	weather_blessing_timer.timeout.connect(_on_weather_blessing_expired)


func _restart_timer(t: Timer, min_s: float, max_s: float) -> void:
	t.start(randf_range(min_s, max_s))


func _restart_bird_timer(t: Timer, min_s: float, max_s: float) -> void:
	var mult: float = DIFFICULTY_BIRD_INTERVAL_MULT.get(difficulty, 1.0)
	t.start(randf_range(min_s, max_s) * mult)


func _bird_spawn_position(from_left: bool) -> Vector2:
	var center: Vector2 = camera.get_screen_center_position()
	var x: float = center.x - VIEWPORT_WIDTH * 0.6 if from_left else center.x + VIEWPORT_WIDTH * 0.6
	var y: float = center.y + randf_range(-300.0, 200.0)
	return Vector2(x, y)


func _spawn_common_bird_from(pos: Vector2, direction: float) -> void:
	var bird: Area2D = COMMON_BIRD_SCENE.instantiate()
	bird.position = pos
	bird.direction = direction
	bird.scale = Vector2(COMMON_BIRD_SCALE, COMMON_BIRD_SCALE)
	add_child(bird)
	bird.collected.connect(_on_common_bird_collected.bind(bird))


func _on_common_bird_collected(bird: Node2D) -> void:
	SaveManager.add_coins(1)
	AudioManager.play("chirp")
	_spawn_particle_burst(bird.global_position, Color(1.0, 0.9, 0.4, 0.9), 10, 130.0, 0.4)
	_spawn_floating_text(bird.global_position, "+1 COIN", COIN_TEXT_COLOR)


func _on_common_bird_timer() -> void:
	if not is_dead:
		var from_left: bool = randf() < 0.5
		_spawn_common_bird_from(_bird_spawn_position(from_left), 1.0 if from_left else -1.0)
	_restart_bird_timer(common_bird_timer, 2.5, 5.0)


func _on_special_bird_timer() -> void:
	if not is_dead:
		var roll: float = randf()
		if current_zone == 2 and roll < 0.5:
			_spawn_shadow_bird()
		elif roll < 0.3:
			_spawn_white_bird()
	_restart_bird_timer(special_bird_timer, 15.0, 25.0)


func _spawn_white_bird() -> void:
	var from_left: bool = randf() < 0.5
	var bird: Area2D = WHITE_BIRD_SCENE.instantiate()
	bird.position = _bird_spawn_position(from_left)
	bird.direction = 1.0 if from_left else -1.0
	add_child(bird)
	bird.collected.connect(_on_white_bird_collected)


func _spawn_shadow_bird() -> void:
	var bird: Node2D = SHADOW_BIRD_SCENE.instantiate()
	bird.position = player.global_position + Vector2(120.0, -60.0)
	bird.target = player
	add_child(bird)


func _on_predator_timer() -> void:
	if not is_dead:
		var height: float = max(0.0, start_y - player.global_position.y) / PIXELS_PER_METER
		var chance: float = clamp(0.5 * DIFFICULTY_EAGLE_CHANCE_MULT.get(difficulty, 1.0), 0.0, 0.95)
		if height >= EAGLE_MIN_HEIGHT_M and randf() < chance:
			_spawn_predator_bird()
	_restart_timer(predator_timer, 30.0, 45.0)


func _spawn_predator_bird() -> void:
	var from_left: bool = randf() < 0.5
	var bird: Area2D = PREDATOR_BIRD_SCENE.instantiate()
	bird.position = _bird_spawn_position(from_left)
	add_child(bird)
	bird.hit_player.connect(_on_eagle_hit)
	bird.telegraph_started.connect(func(): AudioManager.play("eagle"))
	bird.begin_telegraph(player)


func _on_eagle_hit() -> void:
	if spawn_protection_timer > 0.0:
		return
	SaveManager.remove_coins(3)
	AudioManager.play("eagle")
	hud.show_toast("Eagle stole 3 coins!")
	_spawn_floating_text(player.global_position, "-3 COINS", EAGLE_TEXT_COLOR)
	player.shake_camera(EAGLE_SHAKE_STRENGTH, EAGLE_SHAKE_DURATION)


func _on_white_bird_collected(bonus: float) -> void:
	bonus_height_m += bonus
	AudioManager.play("white_bird")
	_spawn_particle_burst(player.global_position, Color(1.0, 1.0, 1.0, 0.9), 12, 140.0, 0.5)


func _on_feather_timer() -> void:
	if not is_dead:
		_spawn_feather()
	_restart_timer(feather_timer, 4.0, 8.0)


func _spawn_feather() -> void:
	var feather: Node2D = FALLING_FEATHER_SCENE.instantiate()
	var center: Vector2 = camera.get_screen_center_position()
	feather.position = Vector2(randf_range(center.x - 250.0, center.x + 250.0), center.y - 550.0)
	add_child(feather)


func _on_weather_timer() -> void:
	var effective_level: int = 0 if weather_blessing_active else current_level_idx
	if not is_dead:
		_spawn_weather_particle(effective_level)
	var interval: float = WEATHER_INTERVAL.get(effective_level, 0.0)
	if interval > 0.0:
		_restart_timer(weather_timer, interval, interval * 1.6)


func _spawn_weather_particle(level_idx: int) -> void:
	var center: Vector2 = camera.get_screen_center_position()
	var scene: PackedScene = null
	match level_idx:
		0:
			scene = BUTTERFLY_SCENE
		2:
			scene = LEAF_SCENE
		3:
			scene = SNOWFLAKE_SCENE
		4:
			scene = RAINDROP_SCENE
	if scene == null:
		return
	var particle: Node2D = scene.instantiate()
	var top: bool = level_idx != 0
	particle.position = Vector2(
		randf_range(center.x - 260.0, center.x + 260.0),
		center.y - 500.0 if top else center.y + randf_range(-150.0, 150.0)
	)
	if level_idx == 0:
		particle.direction = 1.0 if randf() < 0.5 else -1.0
	add_child(particle)


func _on_thunder_timer() -> void:
	if not is_dead and current_level_idx == 4 and not weather_blessing_active:
		thunder_flash.flash()
		_restart_timer(thunder_timer, THUNDER_INTERVAL_MIN, THUNDER_INTERVAL_MAX)


func _process(delta: float) -> void:
	_update_cloud_drift(delta)
	wind_layer.global_position = camera.get_screen_center_position() - Vector2(VIEWPORT_WIDTH / 2.0, 480.0)

	if is_dead:
		return

	SaveManager.add_play_time(delta)

	if spawn_protection_timer > 0.0:
		spawn_protection_timer = max(spawn_protection_timer - delta, 0.0)

	var height: float = max(0.0, start_y - player.global_position.y) / PIXELS_PER_METER + bonus_height_m
	hud.set_height(int(height), SaveManager.data.best_height)
	hud.set_charge(player.get_charge_ratio())
	hud.set_coins(SaveManager.data.total_coins)
	SaveManager.update_best_height(height)
	_check_memories(height)
	_check_zone_transition(height)
	_check_season_transition(height)

	if not tutorial_hidden and SaveManager.data.stats.total_jumps > 0:
		hud.hide_tutorial_hint()
		tutorial_hidden = true

	if player.global_position.y > kill_y:
		if height < SAFE_ZONE_HEIGHT_M:
			_soft_reset_to_spawn()
		else:
			_die(height)


func _soft_reset_to_spawn() -> void:
	player.global_position = spawn_position
	player.velocity = Vector2.ZERO
	player.reset_charge()
	spawn_protection_timer = SPAWN_PROTECTION_TIME


func _check_memories(height: float) -> void:
	for threshold in MEMORY_HEIGHTS:
		if height >= float(threshold) and not SaveManager.has_seen_memory(threshold):
			SaveManager.mark_memory_seen(threshold)
			memory_overlay.show_memory(MEMORY_TEXTS[threshold])
			AudioManager.play("memory")
			return


func _on_coin_collected() -> void:
	SaveManager.add_coins(1)
	AudioManager.play("coin")


func _on_spike_hit() -> void:
	if is_dead or spawn_protection_timer > 0.0:
		return
	var height: float = max(0.0, start_y - player.global_position.y) / PIXELS_PER_METER
	_die(height)


func _on_trap_hit() -> void:
	if is_dead or spawn_protection_timer > 0.0:
		return
	var height: float = max(0.0, start_y - player.global_position.y) / PIXELS_PER_METER
	_die(height)


func _on_player_landed_hard(land_position: Vector2) -> void:
	AudioManager.play("landing")
	_spawn_particle_burst(land_position, Color(0.75, 0.73, 0.7, 0.8), 8, 100.0, 0.35)


func _on_player_dashed(dash_position: Vector2, _direction: float) -> void:
	_spawn_particle_burst(dash_position, Color(0.6, 0.85, 0.95, 0.9), 10, 160.0, 0.3)


func _on_checkpoint_activated(checkpoint: Node) -> void:
	checkpoints_this_run += 1
	current_checkpoint_position = Vector2(VIEWPORT_WIDTH / 2.0, checkpoint.global_position.y - 20.0)
	current_checkpoint_height = float(checkpoint.height_meters)
	var level_idx: int = _get_level_index(current_checkpoint_height)
	SaveManager.record_progress(current_checkpoint_height, level_idx + 1, SEASON_NAMES[level_idx])
	SaveManager.record_checkpoint(checkpoints_this_run)
	AudioManager.play("checkpoint")
	hud.show_toast("Checkpoint! %dm" % checkpoint.height_meters)
	player.shake_camera(CHECKPOINT_SHAKE_STRENGTH, CHECKPOINT_SHAKE_DURATION)
	_spawn_particle_burst(checkpoint.global_position, Color(1.0, 0.3, 0.3, 0.95), 6, 130.0, 0.5)
	_spawn_particle_burst(checkpoint.global_position, Color(1.0, 0.85, 0.2, 0.95), 6, 150.0, 0.55)
	_spawn_particle_burst(checkpoint.global_position, Color(0.3, 0.7, 1.0, 0.95), 6, 140.0, 0.5)


func _nearest_checkpoint_distance(height: float) -> float:
	var nearest: float = INF
	for checkpoint in checkpoints:
		var dist: float = abs(height - float(checkpoint.height_meters))
		if dist < nearest:
			nearest = dist
	return nearest


func _die(height_reached: float) -> void:
	if SaveManager.use_inventory_item("extra_life"):
		hud.show_toast("Extra Life used!")
		player.global_position = current_checkpoint_position
		player.velocity = Vector2.ZERO
		player.reset_charge()
		spawn_protection_timer = SPAWN_PROTECTION_TIME
		return

	if SaveManager.use_inventory_item("safe_shield"):
		hud.show_toast("Safe Shield used!")
		player.global_position = current_checkpoint_position
		player.velocity = Vector2.ZERO
		player.reset_charge()
		spawn_protection_timer = SPAWN_PROTECTION_TIME
		return

	is_dead = true

	var lost_meters: float = max(0.0, height_reached - current_checkpoint_height)
	var is_near_miss: bool = _nearest_checkpoint_distance(height_reached) <= NEAR_MISS_METERS

	SaveManager.record_death(int(height_reached))
	_add_death_marker(height_reached)

	if is_near_miss:
		AudioManager.play("near_miss")
	else:
		AudioManager.play("death")

	get_tree().paused = true
	death_screen.show_death(int(height_reached), SaveManager.data.best_height, SaveManager.data.total_coins, int(lost_meters), is_near_miss)


func _on_respawn_requested() -> void:
	get_tree().paused = false
	is_dead = false
	player.global_position = current_checkpoint_position
	player.velocity = Vector2.ZERO
	player.reset_charge()
	spawn_protection_timer = SPAWN_PROTECTION_TIME


func _on_save_position_requested() -> void:
	if is_dead:
		return
	var height: float = max(0.0, start_y - player.global_position.y) / PIXELS_PER_METER + bonus_height_m
	var level_idx: int = _get_level_index(height)
	# Update the same in-run respawn point a checkpoint would, so an
	# immediate death this run and a future Continue both agree with
	# whatever Save Position just recorded.
	current_checkpoint_position = player.global_position
	current_checkpoint_height = height
	SaveManager.record_progress(height, level_idx + 1, SEASON_NAMES[level_idx])
	SaveManager.save_game()
	hud.show_toast("Position Saved")


func _on_shop_requested() -> void:
	shop_screen.open()


func _on_item_purchased(item_id: String) -> void:
	match item_id:
		"extra_life":
			SaveManager.add_inventory_item("extra_life", 1)
			hud.show_toast("Extra Life added!")
		"safe_shield":
			SaveManager.add_inventory_item("safe_shield", 1)
			hud.show_toast("Safe Shield added!")
		"jump_boost":
			player.jump_boost_mult = JUMP_BOOST_MULT
			_restart_timer(jump_boost_timer, BUFF_DURATION, BUFF_DURATION)
			hud.show_toast("Jump Boost active for 30s!")
		"ice_grip":
			ice_grip_active = true
			_recompute_friction()
			_restart_timer(ice_grip_timer, BUFF_DURATION, BUFF_DURATION)
			hud.show_toast("Ice Grip active for 30s!")
		"weather_blessing":
			weather_blessing_active = true
			_recompute_friction()
			_restart_timer(weather_blessing_timer, BUFF_DURATION, BUFF_DURATION)
			hud.show_toast("Weather Blessing active for 30s!")


func _on_jump_boost_expired() -> void:
	player.jump_boost_mult = 1.0


func _on_ice_grip_expired() -> void:
	ice_grip_active = false
	_recompute_friction()


func _on_weather_blessing_expired() -> void:
	weather_blessing_active = false
	_recompute_friction()


func _on_menu_requested() -> void:
	get_tree().paused = false
	MusicManager.stop_all()
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
