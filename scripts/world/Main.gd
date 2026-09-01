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

@onready var player: CharacterBody2D = $Player
@onready var hud = $HUD
@onready var camera: Camera2D = $Player/Camera2D
@onready var death_screen = $DeathScreen
@onready var memory_overlay = $MemoryOverlay

var spawn_position: Vector2
var current_checkpoint_position: Vector2
var current_checkpoint_height: float = 0.0
var start_y: float
var kill_y: float
var is_dead: bool = false
var checkpoints_this_run: int = 0
var checkpoints: Array = []


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

	for i in range(PLATFORM_COUNT):
		var platform: Node = _spawn_platform_variant(i, x, y)

		if i == 0:
			spawn_position = Vector2(x, y - 60.0)
			kill_y = y + FALL_DEATH_MARGIN
		elif platform is StaticBody2D or platform is AnimatableBody2D:
			if randf() < COIN_CHANCE:
				_spawn_coin(Vector2(x, y - 50.0))
			if i > SPIKE_SAFE_PLATFORM_COUNT and randf() < SPIKE_CHANCE:
				_spawn_spike(Vector2(x, y))

		if i < PLATFORM_COUNT - 1:
			y -= randf_range(MIN_GAP, MAX_GAP)
			x = randf_range(EDGE_MARGIN, VIEWPORT_WIDTH - EDGE_MARGIN)

	return y


func _spawn_platform_variant(i: int, x: float, y: float) -> Node:
	var scene: PackedScene = PLATFORM_SCENE

	if i > SPIKE_SAFE_PLATFORM_COUNT:
		var roll: float = randf()
		if roll < FAKE_PLATFORM_CHANCE:
			scene = FAKE_PLATFORM_SCENE
		elif roll < FAKE_PLATFORM_CHANCE + MOVING_PLATFORM_CHANCE:
			scene = MOVING_PLATFORM_SCENE
		elif roll < FAKE_PLATFORM_CHANCE + MOVING_PLATFORM_CHANCE + COLLAPSING_PLATFORM_CHANCE:
			scene = COLLAPSING_PLATFORM_SCENE

	var platform: Node = scene.instantiate()
	platform.position = Vector2(x, y)
	add_child(platform)
	return platform


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
		_spawn_death_marker(float(height))


func _spawn_death_marker(height: float) -> void:
	var marker: Node2D = DEATH_MARKER_SCENE.instantiate()
	marker.position = Vector2(randf_range(EDGE_MARGIN, VIEWPORT_WIDTH - EDGE_MARGIN), spawn_position.y - height * PIXELS_PER_METER)
	add_child(marker)
	marker.set_height(int(height))


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


func _on_player_landed_hard(pos: Vector2) -> void:
	_spawn_particle_burst(pos, Color(0.75, 0.73, 0.7, 0.8), 8, 100.0, 0.35)


func _on_player_dashed(pos: Vector2, _direction: float) -> void:
	_spawn_particle_burst(pos, Color(0.6, 0.85, 0.95, 0.9), 10, 160.0, 0.3)


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
	_spawn_death_marker(height_reached)

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
