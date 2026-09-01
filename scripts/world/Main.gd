extends Node2D

const PIXELS_PER_METER: float = 50.0
const PLATFORM_COUNT: int = 360
const PLATFORM_SCENE: PackedScene = preload("res://scenes/world/Platform.tscn")
const CHECKPOINT_SCENE: PackedScene = preload("res://scenes/world/Checkpoint.tscn")
const COIN_SCENE: PackedScene = preload("res://scenes/world/Coin.tscn")

const VIEWPORT_WIDTH: float = 540.0
const EDGE_MARGIN: float = 90.0
const MIN_GAP: float = 90.0
const MAX_GAP: float = 220.0
const FALL_DEATH_MARGIN: float = 200.0
const CAMERA_TOP_MARGIN: float = 500.0
const CHECKPOINT_INTERVAL_M: int = 100
const COIN_CHANCE: float = 0.45

@onready var player: CharacterBody2D = $Player
@onready var hud = $HUD
@onready var camera: Camera2D = $Player/Camera2D
@onready var death_screen = $DeathScreen

var spawn_position: Vector2
var current_checkpoint_position: Vector2
var start_y: float
var kill_y: float
var is_dead: bool = false
var checkpoints_this_run: int = 0


func _ready() -> void:
	randomize()
	death_screen.respawn_requested.connect(_on_respawn_requested)
	death_screen.menu_requested.connect(_on_menu_requested)

	var top_y: float = _generate_platforms()
	player.global_position = spawn_position
	current_checkpoint_position = spawn_position
	start_y = spawn_position.y
	_setup_camera(top_y)
	_generate_checkpoints(top_y)

	SaveManager.start_run()


func _generate_platforms() -> float:
	var x: float = VIEWPORT_WIDTH / 2.0
	var y: float = 900.0

	for i in range(PLATFORM_COUNT):
		var platform: StaticBody2D = PLATFORM_SCENE.instantiate()
		platform.position = Vector2(x, y)
		add_child(platform)

		if i == 0:
			spawn_position = Vector2(x, y - 60.0)
			kill_y = y + FALL_DEATH_MARGIN
		elif randf() < COIN_CHANCE:
			_spawn_coin(Vector2(x, y - 50.0))

		if i < PLATFORM_COUNT - 1:
			y -= randf_range(MIN_GAP, MAX_GAP)
			x = randf_range(EDGE_MARGIN, VIEWPORT_WIDTH - EDGE_MARGIN)

	return y


func _spawn_coin(pos: Vector2) -> void:
	var coin: Area2D = COIN_SCENE.instantiate()
	coin.position = pos + Vector2(randf_range(-30.0, 30.0), 0.0)
	add_child(coin)
	coin.collected.connect(_on_coin_collected)


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
		m += CHECKPOINT_INTERVAL_M


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

	if player.global_position.y > kill_y:
		_die(height)


func _on_coin_collected() -> void:
	SaveManager.add_coins(1)
	AudioManager.play("coin")


func _on_checkpoint_activated(checkpoint: Node) -> void:
	checkpoints_this_run += 1
	current_checkpoint_position = Vector2(VIEWPORT_WIDTH / 2.0, checkpoint.global_position.y - 20.0)
	SaveManager.record_checkpoint(checkpoints_this_run)
	AudioManager.play("checkpoint")
	hud.show_toast("Checkpoint! %dm" % checkpoint.height_meters)


func _die(height_reached: float) -> void:
	is_dead = true
	SaveManager.record_death()
	AudioManager.play("death")
	get_tree().paused = true
	death_screen.show_death(int(height_reached), SaveManager.data.best_height, SaveManager.data.total_coins)


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
