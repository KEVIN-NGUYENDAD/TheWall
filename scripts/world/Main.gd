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
const SNOW_PATCH_DECOR_SCENE: PackedScene = preload("res://scenes/world/SnowPatchDecor.tscn")
const SEASON_BANNER_SCENE: PackedScene = preload("res://scenes/ui/SeasonBanner.tscn")
const THUNDER_FLASH_SCENE: PackedScene = preload("res://scenes/world/ThunderFlash.tscn")
const LEVEL_UP_GLOW_SCENE: PackedScene = preload("res://scenes/effects/LevelUpGlow.tscn")
const LEVEL_UP_RING_SCENE: PackedScene = preload("res://scenes/effects/LevelUpRing.tscn")

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

# Level system: Level N = N-th band, bands match the Season bands
# (SEASON_NAMES) exactly. Balance Rework: beauty no longer implies easy or
# hard by itself — difficulty is set purely by the hazard curve below, which
# now climbs in the same order as the seasons: Winter (easiest) -> Storm
# (still easy — mostly for exploring the new weather) -> Spring (medium) ->
# Summer (harder) -> Autumn (hardest). Medium's multiplier below stays at
# 1.0 as the balanced baseline; Easy/Hard scale it down/up from there.
const LEVEL_HEIGHTS: Array = [0.0, 100.0, 250.0, 450.0, 700.0]
const LEVEL_MOVING_CHANCE: Array = [0.04, 0.06, 0.09, 0.12, 0.16]
const LEVEL_COLLAPSING_CHANCE: Array = [0.03, 0.05, 0.07, 0.10, 0.14]
const LEVEL_TRAP_CHANCE: Array = [0.0, 0.015, 0.03, 0.045, 0.065]

# Platform colors are fixed per TYPE (not per zone) so players can recognize
# hazards at a glance: green=normal, blue=moving, yellow=collapsing,
# purple=fake, red=trap. Season only applies a light modulate tint on top.
# Reordered again (Balance Rework) so players see snow AND storm weather
# right from the start: Winter -> Storm -> Spring -> Summer -> Autumn.
const SEASON_NAMES: Array = ["WINTER", "STORM", "SPRING", "SUMMER", "AUTUMN"]
const STORM_LEVEL_IDX: int = 1
# Winter ice and Storm rain both trim grip a little; Autumn's leaves are the
# slickest of all, on top of already being the hardest hazard curve.
const SEASON_FRICTION_MULT: Array = [0.7, 0.8, 1.0, 1.0, 0.6]
const SEASON_PLATFORM_MODULATE: Array = [
	Color(0.82, 0.92, 1.0), Color(0.75, 0.8, 0.88),
	Color(1.0, 0.97, 1.0), Color(1.0, 1.0, 0.9), Color(1.0, 0.85, 0.55),
]
# True 2.5D Visual Pass: sky color and a full-screen color wash both tween
# per season change, so the season reads at a glance without the HUD label
# — this replaces Zone as the sky's color owner (Zone still tints
# mountains/hills/near-clouds for depth). Purely cosmetic, no gameplay effect.
const SEASON_SKY_COLOR: Array = [
	Color(0.72, 0.85, 0.95), Color(0.42, 0.47, 0.55),
	Color(0.55, 0.82, 0.95), Color(0.25, 0.65, 1.0), Color(0.85, 0.55, 0.35),
]
const SEASON_TINT_COLOR: Array = [
	Color(0.75, 0.88, 1.0, 0.3), Color(0.35, 0.4, 0.5, 0.4),
	Color(1.0, 0.85, 0.92, 0.16), Color(1.0, 0.95, 0.55, 0.16), Color(1.0, 0.5, 0.15, 0.3),
]
# Winter snow at least 5x denser than before (0.9 -> 0.18); Storm rain also
# thickened up. Spring/Summer/Autumn intervals unchanged from prior passes.
const WEATHER_INTERVAL: Dictionary = {
	0: 0.18, 1: 0.15, 2: 4.8, 3: 0.0, 4: 1.0,
}
const THUNDER_INTERVAL_MIN: float = 5.0
const THUNDER_INTERVAL_MAX: float = 11.0
const FLOWER_CHANCE: float = 0.2
const SNOW_PATCH_CHANCE: float = 0.2
# Fog thickens with altitude; Winter also gets a flat mist boost regardless
# of height for its own "sương trắng" identity.
const FOG_HEIGHT_CAP_M: float = 900.0
const FOG_WINTER_BOOST: float = 0.35

# Difficulty modes: multipliers applied on top of the base level curve.
# Balance Rework: rebuilt from scratch against Medium as the balanced 1.0
# baseline (previous passes tied Medium/Hard to older, softer tiers — this
# pass replaces that relationship with an explicit, clearly-felt spread).
# Easy: -70% traps/eagles, gentler hazards overall, shorter gaps, wider
# platforms, more frequent bonus birds. Hard: noticeably more traps/eagles,
# farther gaps, narrower platforms.
const DIFFICULTY_TRAP_MULT: Dictionary = {"EASY": 0.3, "MEDIUM": 1.0, "HARD": 1.6}
const DIFFICULTY_HAZARD_MULT: Dictionary = {"EASY": 0.4, "MEDIUM": 1.0, "HARD": 1.5}
# Easy Mode Rebalance: vertical gap cut a further 30% on top of its existing
# 0.6 (0.6 * 0.7 = 0.42) — Medium/Hard untouched.
const DIFFICULTY_GAP_MULT: Dictionary = {"EASY": 0.42, "MEDIUM": 0.85, "HARD": 1.2}
const DIFFICULTY_BIRD_INTERVAL_MULT: Dictionary = {"EASY": 0.6, "MEDIUM": 1.0, "HARD": 1.6}
const DIFFICULTY_EAGLE_CHANCE_MULT: Dictionary = {"EASY": 0.3, "MEDIUM": 1.0, "HARD": 1.6}
const DIFFICULTY_PLATFORM_SCALE: Dictionary = {"EASY": 1.3, "MEDIUM": 1.0, "HARD": 0.75}
const EAGLE_BASE_CHANCE: float = 0.25

# Easy Mode Rebalance: horizontal reach between consecutive platforms is
# constrained (Medium/Hard keep the old fully-free full-width placement —
# only Easy gets this). MAX_HORIZONTAL_SHIFT is the full baseline budget
# (VIEWPORT_WIDTH - 2*EDGE_MARGIN); Easy uses half of it. Platform density
# is boosted 50% and Fake platforms are mostly removed so a beginner is
# never stuck behind an unreachable or deceptive gap.
const MAX_HORIZONTAL_SHIFT: float = 360.0
const EASY_HORIZONTAL_SHIFT_MULT: float = 0.5
const DIFFICULTY_PLATFORM_COUNT_MULT: Dictionary = {"EASY": 1.5, "MEDIUM": 1.0, "HARD": 1.0}
const DIFFICULTY_FAKE_MULT: Dictionary = {"EASY": 0.2, "MEDIUM": 1.0, "HARD": 1.0}

# Lives: 3 per run. Hitting 0 shows Game Over (Continue refills to 3 and
# resumes at the checkpoint; Play Again refills to 3 and resets to height 0).
const MAX_LIVES: int = 3

# Player Level: a uniform, height-only progression, separate from Season —
# +1 level every 100m climbed, uncapped, recomputed live from current
# height (so it can dip if the player falls, then grows back on re-climb).
# Each level adds a flat 3% to jump force via Player.level_jump_mult.
const LEVEL_METERS: float = 100.0
const JUMP_LEVEL_BONUS: float = 0.03
const LEVEL_UP_INVULN_TIME: float = 1.0
const LEVEL_UP_SHAKE_STRENGTH: float = 3.0
const LEVEL_UP_SHAKE_DURATION: float = 0.2

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

const LEVEL_UP_PAUSE_TIME: float = 1.2

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
@onready var fog_layer = $ParallaxBackground/FogLayer
@onready var season_tint = $SeasonTint
@onready var shop_screen = $ShopScreen
@onready var rest_area_screen = $RestAreaScreen
@onready var game_over_screen = $GameOverScreen
@onready var level_up_popup = $LevelUpPopup

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
var lives_remaining: int = MAX_LIVES
var player_level: int = 1
var max_level_reached: int = 1

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
	rest_area_screen.save_requested.connect(_on_save_position_requested)
	rest_area_screen.shop_requested.connect(_on_shop_requested)
	rest_area_screen.continue_requested.connect(_on_rest_area_continue)
	game_over_screen.continue_requested.connect(_on_game_over_continue_requested)
	game_over_screen.play_again_requested.connect(_on_game_over_play_again_requested)
	game_over_screen.menu_requested.connect(_on_menu_requested)

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
	_apply_auto_resume()
	hud.set_lives(lives_remaining, MAX_LIVES)

	var initial_height: float = max(0.0, start_y - player.global_position.y) / PIXELS_PER_METER
	max_level_reached = _get_player_level(initial_height)
	player_level = max_level_reached
	player.level_jump_mult = 1.0 + (player_level - 1) * JUMP_LEVEL_BONUS
	level_up_popup.bonus_text = "Jump +%d%%" % int(round(JUMP_LEVEL_BONUS * 100.0))

	spawn_protection_timer = SPAWN_PROTECTION_TIME
	MusicManager.start()
	SaveManager.start_run()


func _generate_platforms() -> float:
	var x: float = VIEWPORT_WIDTH / 2.0
	var y: float = 900.0
	spawn_position = Vector2(x, y - 60.0)
	kill_y = y + FALL_DEATH_MARGIN

	var platform_count: int = int(PLATFORM_COUNT * DIFFICULTY_PLATFORM_COUNT_MULT.get(difficulty, 1.0))

	for i in range(platform_count):
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

		if i < platform_count - 1:
			var gap_mult: float = DIFFICULTY_GAP_MULT.get(difficulty, 1.0)
			y -= randf_range(MIN_GAP, MAX_GAP) * gap_mult
			if difficulty == "EASY":
				# Constrain horizontal reach relative to the previous platform
				# (Medium/Hard keep the old fully-free full-width placement).
				var max_shift: float = MAX_HORIZONTAL_SHIFT * EASY_HORIZONTAL_SHIFT_MULT
				x = clamp(x + randf_range(-max_shift, max_shift), EDGE_MARGIN, VIEWPORT_WIDTH - EDGE_MARGIN)
			else:
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
		# Fake platforms are the one hazard a beginner can't yet read by
		# color — mostly removed on Easy so a reachable path is guaranteed.
		var fake_chance: float = FAKE_PLATFORM_CHANCE * DIFFICULTY_FAKE_MULT.get(difficulty, 1.0)
		var moving_chance: float = clamp(LEVEL_MOVING_CHANCE[level_idx] * hazard_mult, 0.0, 0.9)
		var collapsing_chance: float = clamp(LEVEL_COLLAPSING_CHANCE[level_idx] * hazard_mult, 0.0, 0.9)
		var trap_chance: float = clamp(LEVEL_TRAP_CHANCE[level_idx] * trap_mult, 0.0, 0.9)

		var roll: float = randf()
		if roll < fake_chance:
			scene = FAKE_PLATFORM_SCENE
			ptype = "fake"
		elif roll < fake_chance + moving_chance:
			scene = MOVING_PLATFORM_SCENE
			ptype = "moving"
		elif roll < fake_chance + moving_chance + collapsing_chance:
			scene = COLLAPSING_PLATFORM_SCENE
			ptype = "collapsing"
		elif roll < fake_chance + moving_chance + collapsing_chance + trap_chance:
			scene = TRAP_PLATFORM_SCENE
			ptype = "trap"

	var platform: Node = scene.instantiate()
	platform.position = Vector2(x, y)
	if i > 0:
		platform.scale.x *= DIFFICULTY_PLATFORM_SCALE.get(difficulty, 1.0)
	add_child(platform)
	platform.modulate = SEASON_PLATFORM_MODULATE[_get_level_index(height)]

	if ptype == "trap":
		platform.player_hit.connect(_on_trap_hit)

	if ptype == "normal":
		if i > 0 and height >= SAFE_ZONE_HEIGHT_M and randf() < NEST_CHANCE:
			_spawn_nest(Vector2(x, y - 40.0))
		var deco_level: int = _get_level_index(height)
		if deco_level == 0 and randf() < SNOW_PATCH_CHANCE:
			_spawn_snow_patch(Vector2(x, y - 18.0))
		elif deco_level == 2 and randf() < FLOWER_CHANCE:
			_spawn_flower(Vector2(x, y - 20.0))

	return {"node": platform, "type": ptype}


func _spawn_flower(pos: Vector2) -> void:
	var flower: Node2D = FLOWER_DECOR_SCENE.instantiate()
	flower.position = pos
	add_child(flower)


func _spawn_snow_patch(pos: Vector2) -> void:
	var patch: Node2D = SNOW_PATCH_DECOR_SCENE.instantiate()
	patch.position = pos
	add_child(patch)


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


func _get_player_level(height: float) -> int:
	return int(max(height, 0.0) / LEVEL_METERS) + 1


# Player Level tracks CURRENT height live (dips if the player falls, grows
# back on re-climb) so jump force always matches the formula in the spec.
# max_level_reached is a separate run-scoped ratchet used only to gate the
# celebration so it fires once per new peak, not every time a threshold is
# re-crossed while bouncing near a boundary.
func _update_player_level(height: float) -> void:
	var level: int = _get_player_level(height)
	if level > max_level_reached:
		max_level_reached = level
		_on_player_level_up(level)
	player_level = level
	player.level_jump_mult = 1.0 + (player_level - 1) * JUMP_LEVEL_BONUS
	hud.set_level_progress(player_level, fmod(max(height, 0.0), LEVEL_METERS) / LEVEL_METERS)


func _on_player_level_up(level: int) -> void:
	level_up_popup.show_level_up(level)
	AudioManager.play("level_up")
	_spawn_level_up_glow(player.global_position)
	_spawn_level_up_ring(player.global_position)
	player.shake_camera(LEVEL_UP_SHAKE_STRENGTH, LEVEL_UP_SHAKE_DURATION)
	spawn_protection_timer = max(spawn_protection_timer, LEVEL_UP_INVULN_TIME)


func _spawn_level_up_glow(pos: Vector2) -> void:
	var glow: Node2D = LEVEL_UP_GLOW_SCENE.instantiate()
	glow.position = pos
	add_child(glow)


func _spawn_level_up_ring(pos: Vector2) -> void:
	var ring: Node2D = LEVEL_UP_RING_SCENE.instantiate()
	ring.position = pos
	add_child(ring)


func _check_zone_transition(height: float) -> void:
	var zone: int = _get_zone_for_height(height)
	if zone != current_zone:
		current_zone = zone
		AudioManager.play("area_discovery")

		# Sky color is Season-owned (see _check_season_transition) so the sky
		# always reads as "which season" rather than "which zone third" —
		# Zone still tints mountains/hills/near-clouds for depth variety.
		var tween: Tween = create_tween()
		tween.set_parallel(true)
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
	var leveled_up: bool = not is_first and level_idx > current_level_idx
	current_level_idx = level_idx
	hud.set_season(SEASON_NAMES[level_idx])
	_recompute_friction()
	MusicManager.play_season(level_idx)

	var tint_tween: Tween = create_tween()
	tint_tween.tween_method(season_tint.set_tint, season_tint.color, SEASON_TINT_COLOR[level_idx], ZONE_TRANSITION_TIME)

	var sky_tween: Tween = create_tween()
	sky_tween.tween_method(_set_sky_color, current_sky_color, SEASON_SKY_COLOR[level_idx], ZONE_TRANSITION_TIME)
	current_sky_color = SEASON_SKY_COLOR[level_idx]

	var interval: float = WEATHER_INTERVAL.get(level_idx, 0.0)
	if interval > 0.0 and not weather_blessing_active:
		_restart_timer(weather_timer, interval, interval * 1.6)
	if level_idx == STORM_LEVEL_IDX and not weather_blessing_active:
		_restart_timer(thunder_timer, THUNDER_INTERVAL_MIN, THUNDER_INTERVAL_MAX)

	if leveled_up:
		_celebrate_level_up(height, level_idx)
	elif not is_first:
		season_banner.show_season(SEASON_NAMES[level_idx])


# Reaching a new level (100/300/600/900m) should feel like completing a
# chapter: banner + sound, a brief pause so it actually registers, then a
# Rest Area to save/shop/breathe before continuing.
func _celebrate_level_up(height: float, level_idx: int) -> void:
	season_banner.show_season(SEASON_NAMES[level_idx])
	AudioManager.play("unlock")
	get_tree().paused = true
	get_tree().create_timer(LEVEL_UP_PAUSE_TIME).timeout.connect(_on_level_up_pause_ended.bind(int(height)))


func _on_level_up_pause_ended(height: int) -> void:
	rest_area_screen.open(height)


func _on_rest_area_continue() -> void:
	shop_screen.visible = false
	get_tree().paused = false


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


func _update_fog(height: float) -> void:
	var value: float = clamp(height / FOG_HEIGHT_CAP_M, 0.0, 1.0)
	if current_level_idx == 0:
		value = clamp(value + FOG_WINTER_BOOST, 0.0, 1.0)
	fog_layer.set_intensity(value)


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


func _apply_auto_resume() -> void:
	if not SaveManager.pending_auto_resume:
		return
	SaveManager.pending_auto_resume = false
	if not SaveManager.data.session.active:
		return

	var session: Dictionary = SaveManager.data.session
	var pos: Vector2 = Vector2(session.pos_x, session.pos_y)
	player.global_position = pos
	current_checkpoint_position = pos
	current_checkpoint_height = session.height
	lives_remaining = int(session.get("lives", MAX_LIVES))
	if lives_remaining <= 0:
		lives_remaining = MAX_LIVES

	if session.jump_boost_remaining > 0.0:
		player.jump_boost_mult = JUMP_BOOST_MULT
		_restart_timer(jump_boost_timer, session.jump_boost_remaining, session.jump_boost_remaining)
	if session.ice_grip_remaining > 0.0:
		ice_grip_active = true
		_restart_timer(ice_grip_timer, session.ice_grip_remaining, session.ice_grip_remaining)
	if session.weather_blessing_remaining > 0.0:
		weather_blessing_active = true
		_restart_timer(weather_blessing_timer, session.weather_blessing_remaining, session.weather_blessing_remaining)
	_recompute_friction()


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
	_restart_bird_timer(common_bird_timer, 10.0, 20.0)

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
	_restart_bird_timer(common_bird_timer, 10.0, 20.0)


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
		var chance: float = clamp(EAGLE_BASE_CHANCE * DIFFICULTY_EAGLE_CHANCE_MULT.get(difficulty, 1.0), 0.0, 0.95)
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
	if level_idx == 0:
		# Layered snow: a far (small/slow/dim) and a near (big/fast/bright)
		# flake spawned together for a true parallax-depth snowfall.
		_spawn_snowflake(center, randf_range(0.5, 0.8))
		_spawn_snowflake(center, randf_range(1.1, 1.6))
		return

	var scene: PackedScene = null
	match level_idx:
		1:
			scene = RAINDROP_SCENE
		2:
			scene = BUTTERFLY_SCENE
		4:
			scene = LEAF_SCENE
	if scene == null:
		return
	var particle: Node2D = scene.instantiate()
	var top: bool = level_idx != 2
	particle.position = Vector2(
		randf_range(center.x - 260.0, center.x + 260.0),
		center.y - 500.0 if top else center.y + randf_range(-150.0, 150.0)
	)
	if level_idx == 2:
		particle.direction = 1.0 if randf() < 0.5 else -1.0
	add_child(particle)


func _spawn_snowflake(center: Vector2, depth_mult: float) -> void:
	var flake: Node2D = SNOWFLAKE_SCENE.instantiate()
	flake.depth_mult = depth_mult
	flake.position = Vector2(randf_range(center.x - 260.0, center.x + 260.0), center.y - 500.0)
	add_child(flake)


func _on_thunder_timer() -> void:
	if not is_dead and current_level_idx == STORM_LEVEL_IDX and not weather_blessing_active:
		thunder_flash.flash()
		_restart_timer(thunder_timer, THUNDER_INTERVAL_MIN, THUNDER_INTERVAL_MAX)


func _process(delta: float) -> void:
	_update_cloud_drift(delta)
	wind_layer.global_position = camera.get_screen_center_position() - Vector2(VIEWPORT_WIDTH / 2.0, 480.0)
	season_tint.global_position = camera.get_screen_center_position()

	if is_dead:
		return

	SaveManager.add_play_time(delta)

	if spawn_protection_timer > 0.0:
		spawn_protection_timer = max(spawn_protection_timer - delta, 0.0)

	var height: float = max(0.0, start_y - player.global_position.y) / PIXELS_PER_METER + bonus_height_m
	hud.set_height(int(height), SaveManager.data.best_height)
	hud.set_charge(player.get_charge_ratio())
	hud.set_coins(SaveManager.data.total_coins)
	hud.set_lives(lives_remaining, MAX_LIVES)
	_update_player_level(height)
	SaveManager.update_best_height(height)
	_check_memories(height)
	_check_zone_transition(height)
	_check_season_transition(height)
	_update_session_snapshot(height)
	_update_fog(height)

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


func _update_session_snapshot(height: float) -> void:
	var level_idx: int = max(current_level_idx, 0)
	SaveManager.update_session_snapshot({
		"pos_x": player.global_position.x,
		"pos_y": player.global_position.y,
		"height": height,
		"season": SEASON_NAMES[level_idx],
		"level": level_idx + 1,
		"jump_boost_remaining": jump_boost_timer.time_left,
		"ice_grip_remaining": ice_grip_timer.time_left,
		"weather_blessing_remaining": weather_blessing_timer.time_left,
		"lives": lives_remaining,
	})


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
	SaveManager.clear_session()

	var lost_meters: float = max(0.0, height_reached - current_checkpoint_height)
	var is_near_miss: bool = _nearest_checkpoint_distance(height_reached) <= NEAR_MISS_METERS

	SaveManager.record_death(int(height_reached))
	_add_death_marker(height_reached)

	if is_near_miss:
		AudioManager.play("near_miss")
	else:
		AudioManager.play("death")

	lives_remaining = max(lives_remaining - 1, 0)
	hud.set_lives(lives_remaining, MAX_LIVES)
	get_tree().paused = true

	if lives_remaining > 0:
		death_screen.show_death(int(height_reached), SaveManager.data.best_height, SaveManager.data.total_coins, int(lost_meters), is_near_miss, lives_remaining)
	else:
		game_over_screen.show_game_over(int(height_reached), SaveManager.data.best_height, SaveManager.data.total_coins)


func _on_respawn_requested() -> void:
	get_tree().paused = false
	is_dead = false
	player.global_position = current_checkpoint_position
	player.velocity = Vector2.ZERO
	player.reset_charge()
	spawn_protection_timer = SPAWN_PROTECTION_TIME


# Game Over (0 lives): Continue refills lives and resumes at the last
# checkpoint; Play Again refills lives and restarts the climb from 0m.
func _on_game_over_continue_requested() -> void:
	lives_remaining = MAX_LIVES
	hud.set_lives(lives_remaining, MAX_LIVES)
	_on_respawn_requested()


func _on_game_over_play_again_requested() -> void:
	lives_remaining = MAX_LIVES
	hud.set_lives(lives_remaining, MAX_LIVES)
	current_checkpoint_position = spawn_position
	current_checkpoint_height = 0.0
	_on_respawn_requested()


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
	SaveManager.clear_session()
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
