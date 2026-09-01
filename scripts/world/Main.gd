extends Node2D

const PIXELS_PER_METER: float = 50.0
const PLATFORM_COUNT: int = 360
const PLATFORM_SCENE: PackedScene = preload("res://scenes/world/Platform.tscn")
const MOVING_PLATFORM_SCENE: PackedScene = preload("res://scenes/world/MovingPlatform.tscn")
const COLLAPSING_PLATFORM_SCENE: PackedScene = preload("res://scenes/world/CollapsingPlatform.tscn")
const FAKE_PLATFORM_SCENE: PackedScene = preload("res://scenes/world/FakePlatform.tscn")
const CHECKPOINT_SCENE: PackedScene = preload("res://scenes/world/Checkpoint.tscn")
const COIN_SCENE: PackedScene = preload("res://scenes/world/Coin.tscn")
const SPIKE_SCENE: PackedScene = preload("res://scenes/world/Spike.tscn")
const DEATH_MARKER_SCENE: PackedScene = preload("res://scenes/world/DeathMarker.tscn")
const PARTICLE_BURST_SCENE: PackedScene = preload("res://scenes/effects/ParticleBurst.tscn")

const VIEWPORT_WIDTH: float = 540.0
const EDGE_MARGIN: float = 90.0
const MIN_GAP: float = 90.0
const MAX_GAP: float = 220.0
const FALL_DEATH_MARGIN: float = 200.0
const CAMERA_TOP_MARGIN: float = 500.0
const CHECKPOINT_INTERVAL_M: int = 100
const COIN_CHANCE: float = 0.45
const SPIKE_CHANCE: float = 0.1
const SPIKE_SAFE_PLATFORM_COUNT: int = 5
const NEAR_MISS_METERS: float = 5.0

const FAKE_PLATFORM_CHANCE: float = 0.05
const MOVING_PLATFORM_CHANCE: float = 0.12
const SKY_MOVING_PLATFORM_CHANCE: float = 0.25
const COLLAPSING_PLATFORM_CHANCE: float = 0.12

const MEMORY_HEIGHTS: Array = [100, 300, 700, 1500]
const MEMORY_TEXTS: Dictionary = {
	100: "Someone climbed before you.",
	300: "They did not reach the top.",
	700: "The wall remembers why.",
	1500: "You are not the first to come this far.",
}

const CHECKPOINT_SHAKE_STRENGTH: float = 4.0
const CHECKPOINT_SHAKE_DURATION: float = 0.25

const MIN_MARKER_HEIGHT_M: float = 20.0
const MARKER_MERGE_DISTANCE_M: float = 8.0

# Area Progression: THE RUINS (0-100m) / THE SKY (100-500m) / THE VOID (500m+)
const ZONE_SKY_START_M: float = 100.0
const ZONE_VOID_START_M: float = 500.0
const ZONE_TRANSITION_TIME: float = 2.5

const RUINS_PLATFORM_COLOR: Color = Color(0.55, 0.56, 0.62, 1)
const SKY_PLATFORM_COLOR: Color = Color(0.65, 0.75, 0.9, 1)
const VOID_PLATFORM_COLOR: Color = Color(0.3, 0.28, 0.36, 1)

const ZONE_SKY_COLORS: Dictionary = {
	0: Color(0.13, 0.15, 0.22, 1),
	1: Color(0.55, 0.72, 0.88, 1),
	2: Color(0.03, 0.03, 0.06, 1),
}
const ZONE_MOUNTAIN_COLORS: Dictionary = {
	0: Color(0.22, 0.25, 0.35, 1),
	1: Color(0.6, 0.72, 0.85, 1),
	2: Color(0.07, 0.06, 0.11, 1),
}
const ZONE_HILL_COLORS: Dictionary = {
	0: Color(0.28, 0.32, 0.44, 1),
	1: Color(0.7, 0.8, 0.9, 1),
	2: Color(0.1, 0.09, 0.15, 1),
}
const ZONE_CLOUD_COLORS: Dictionary = {
	0: Color(0.9, 0.92, 0.96, 0.45),
	1: Color(1.0, 1.0, 1.0, 0.75),
	2: Color(0.3, 0.28, 0.4, 0.25),
}

@onready var player: CharacterBody2D = $Player
@onready var hud = $HUD
@onready var camera: Camera2D = $Player/Camera2D
@onready var death_screen = $DeathScreen
@onready var memory_overlay = $MemoryOverlay

@onready var mountains: Array = [
	$ParallaxBackground/Far/Mountain1, $ParallaxBackground/Far/Mountain2,
	$ParallaxBackground/Far/Mountain3, $ParallaxBackground/Far/Mountain4,
]
@onready var hills: Array = [$ParallaxBackground/Mid/Hill1, $ParallaxBackground/Mid/Hill2]
@onready var clouds: Array = [
	$ParallaxBackground/Near/Cloud1, $ParallaxBackground/Near/Cloud2, $ParallaxBackground/Near/Cloud3,
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
var current_sky_color: Color = Color(0.13, 0.15, 0.22, 1)
var active_markers: Array = []


func _ready() -> void:
	randomize()
	death_screen.respawn_requested.connect(_on_respawn_requested)
	death_screen.menu_requested.connect(_on_menu_requested)
	player.landed_hard.connect(_on_player_landed_hard)
	player.dashed.connect(_on_player_dashed)

	var top_y: float = _generate_platforms()
	player.global_position = spawn_position
	current_checkpoint_position = spawn_position
	current_checkpoint_height = 0.0
	start_y = spawn_position.y
	_setup_camera(top_y)
	_generate_checkpoints(top_y)
	_spawn_recorded_death_markers()

	SaveManager.start_run()


func _generate_platforms() -> float:
	var x: float = VIEWPORT_WIDTH / 2.0
	var y: float = 900.0
	spawn_position = Vector2(x, y - 60.0)
	kill_y = y + FALL_DEATH_MARGIN

	for i in range(PLATFORM_COUNT):
		var height: float = max(0.0, (spawn_position.y - y) / PIXELS_PER_METER)
		var platform: Node = _spawn_platform_variant(i, x, y, height)

		if i > 0 and (platform is StaticBody2D or platform is AnimatableBody2D):
			if randf() < COIN_CHANCE:
				_spawn_coin(Vector2(x, y - 50.0))
			if i > SPIKE_SAFE_PLATFORM_COUNT and randf() < SPIKE_CHANCE:
				_spawn_spike(Vector2(x, y))

		if i < PLATFORM_COUNT - 1:
			y -= randf_range(MIN_GAP, MAX_GAP)
			x = randf_range(EDGE_MARGIN, VIEWPORT_WIDTH - EDGE_MARGIN)

	return y


func _spawn_platform_variant(i: int, x: float, y: float, height: float) -> Node:
	var scene: PackedScene = PLATFORM_SCENE
	var is_normal: bool = true

	if i > SPIKE_SAFE_PLATFORM_COUNT:
		var moving_chance: float = MOVING_PLATFORM_CHANCE
		if height >= ZONE_SKY_START_M and height < ZONE_VOID_START_M:
			moving_chance = SKY_MOVING_PLATFORM_CHANCE

		var roll: float = randf()
		if roll < FAKE_PLATFORM_CHANCE:
			scene = FAKE_PLATFORM_SCENE
			is_normal = false
		elif roll < FAKE_PLATFORM_CHANCE + moving_chance:
			scene = MOVING_PLATFORM_SCENE
			is_normal = false
		elif roll < FAKE_PLATFORM_CHANCE + moving_chance + COLLAPSING_PLATFORM_CHANCE:
			scene = COLLAPSING_PLATFORM_SCENE
			is_normal = false

	var platform: Node = scene.instantiate()
	platform.position = Vector2(x, y)
	add_child(platform)

	if is_normal:
		_apply_zone_platform_color(platform, height)

	return platform


func _apply_zone_platform_color(platform: Node, height: float) -> void:
	var color: Color = RUINS_PLATFORM_COLOR
	if height >= ZONE_VOID_START_M:
		color = VOID_PLATFORM_COLOR
	elif height >= ZONE_SKY_START_M:
		color = SKY_PLATFORM_COLOR
	var poly: Polygon2D = platform.get_node_or_null("Polygon2D")
	if poly:
		poly.color = color


func _get_zone_for_height(height: float) -> int:
	if height >= ZONE_VOID_START_M:
		return 2
	elif height >= ZONE_SKY_START_M:
		return 1
	return 0


func _check_zone_transition(height: float) -> void:
	var zone: int = _get_zone_for_height(height)
	if zone == current_zone:
		return
	current_zone = zone

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


func _set_sky_color(color: Color) -> void:
	RenderingServer.set_default_clear_color(color)


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


func _spawn_recorded_death_markers() -> void:
	for height in SaveManager.data.death_heights:
		_add_death_marker(float(height))


func _add_death_marker(height: float) -> void:
	if height < MIN_MARKER_HEIGHT_M:
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


func _setup_camera(top_y: float) -> void:
	camera.limit_left = 0
	camera.limit_right = int(VIEWPORT_WIDTH)
	camera.limit_bottom = int(kill_y)
	camera.limit_top = int(top_y - CAMERA_TOP_MARGIN)


func _process(_delta: float) -> void:
	if is_dead:
		return

	var height: float = max(0.0, start_y - player.global_position.y) / PIXELS_PER_METER
	hud.set_height(int(height), SaveManager.data.best_height)
	hud.set_charge(player.get_charge_ratio())
	hud.set_coins(SaveManager.data.total_coins)
	SaveManager.update_best_height(height)
	_check_memories(height)
	_check_zone_transition(height)

	if not tutorial_hidden and SaveManager.data.stats.total_jumps > 0:
		hud.hide_tutorial_hint()
		tutorial_hidden = true

	if player.global_position.y > kill_y:
		_die(height)


func _check_memories(height: float) -> void:
	for threshold in MEMORY_HEIGHTS:
		if height >= float(threshold) and not SaveManager.has_seen_memory(threshold):
			SaveManager.mark_memory_seen(threshold)
			memory_overlay.show_memory(MEMORY_TEXTS[threshold])
			AudioManager.play("unlock")
			return


func _on_coin_collected() -> void:
	SaveManager.add_coins(1)
	AudioManager.play("coin")


func _on_spike_hit() -> void:
	if is_dead:
		return
	var height: float = max(0.0, start_y - player.global_position.y) / PIXELS_PER_METER
	_die(height)


func _on_player_landed_hard(land_position: Vector2) -> void:
	_spawn_particle_burst(land_position, Color(0.75, 0.73, 0.7, 0.8), 8, 100.0, 0.35)


func _on_player_dashed(dash_position: Vector2, _direction: float) -> void:
	_spawn_particle_burst(dash_position, Color(0.6, 0.85, 0.95, 0.9), 10, 160.0, 0.3)


func _on_checkpoint_activated(checkpoint: Node) -> void:
	checkpoints_this_run += 1
	current_checkpoint_position = Vector2(VIEWPORT_WIDTH / 2.0, checkpoint.global_position.y - 20.0)
	current_checkpoint_height = float(checkpoint.height_meters)
	SaveManager.record_checkpoint(checkpoints_this_run)
	AudioManager.play("checkpoint")
	hud.show_toast("Checkpoint! %dm" % checkpoint.height_meters)
	player.shake_camera(CHECKPOINT_SHAKE_STRENGTH, CHECKPOINT_SHAKE_DURATION)


func _nearest_checkpoint_distance(height: float) -> float:
	var nearest: float = INF
	for checkpoint in checkpoints:
		var dist: float = abs(height - float(checkpoint.height_meters))
		if dist < nearest:
			nearest = dist
	return nearest


func _die(height_reached: float) -> void:
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


func _on_menu_requested() -> void:
	get_tree().paused = false
	SaveManager.save_game()
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
