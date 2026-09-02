extends CharacterBody2D

signal landed_hard(land_position: Vector2)
signal dashed(dash_position: Vector2, direction: float)

const MOVE_SPEED: float = 220.0
const GROUND_ACCEL: float = 1600.0
const AIR_ACCEL: float = 900.0

const RISE_GRAVITY: float = 1400.0
const FALL_GRAVITY: float = 2200.0
const MAX_FALL_SPEED: float = 1400.0

const MIN_JUMP_SPEED: float = 350.0
const MAX_JUMP_SPEED: float = 1100.0
const MAX_CHARGE_TIME: float = 1.2
const COYOTE_TIME: float = 0.12

const SQUASH_LERP_SPEED: float = 10.0
const JUMP_STRETCH: Vector2 = Vector2(0.7, 1.4)
const LAND_SQUASH: Vector2 = Vector2(1.35, 0.65)
const LAND_SPEED_THRESHOLD: float = 500.0

const CHARGE_COLOR: Color = Color(0.95, 0.85, 0.2)

const DASH_SPEED: float = 600.0
const DASH_DURATION: float = 0.18
const DASH_COOLDOWN: float = 0.6
const DOUBLE_TAP_WINDOW: float = 0.3
const DASH_STRETCH: Vector2 = Vector2(1.5, 0.6)

var ground_friction_mult: float = 1.0

var charge_time: float = 0.0
var is_charging: bool = false
var coyote_timer: float = 0.0
var was_on_floor: bool = false
var radius: float = 24.0

var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: float = 0.0
var last_left_tap_time: float = -10.0
var last_right_tap_time: float = -10.0

var shake_timer: float = 0.0
var shake_total_duration: float = 1.0
var shake_strength: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Node2D = $Visual
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	add_to_group("player")
	if collision_shape.shape is CircleShape2D:
		radius = collision_shape.shape.radius
	visual.radius = radius


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_dash(delta)
	_handle_movement(delta)
	_handle_charge_and_jump(delta)

	was_on_floor = is_on_floor()
	var incoming_fall_speed: float = velocity.y
	move_and_slide()

	if not was_on_floor and is_on_floor() and incoming_fall_speed > LAND_SPEED_THRESHOLD:
		visual.scale = LAND_SQUASH
		landed_hard.emit(global_position)

	_update_visual(delta)
	_update_shake(delta)


func shake_camera(strength: float, duration: float) -> void:
	shake_strength = strength
	shake_timer = duration
	shake_total_duration = duration


func _update_shake(delta: float) -> void:
	if shake_timer > 0.0:
		shake_timer = max(shake_timer - delta, 0.0)
		var decay: float = shake_timer / shake_total_duration
		camera.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_strength * decay
	else:
		camera.offset = Vector2.ZERO


func _apply_gravity(delta: float) -> void:
	var g: float = FALL_GRAVITY if velocity.y > 0.0 else RISE_GRAVITY
	velocity.y = min(velocity.y + g * delta, MAX_FALL_SPEED)


func _handle_movement(delta: float) -> void:
	if dash_timer > 0.0:
		velocity.x = dash_direction * DASH_SPEED
		return
	var move_input: float = Input.get_axis("move_left", "move_right")
	var accel: float = (GROUND_ACCEL * ground_friction_mult) if is_on_floor() else AIR_ACCEL
	velocity.x = move_toward(velocity.x, move_input * MOVE_SPEED, accel * delta)


func _handle_dash(delta: float) -> void:
	dash_cooldown_timer = max(dash_cooldown_timer - delta, 0.0)
	if dash_timer > 0.0:
		dash_timer -= delta

	var now: float = Time.get_ticks_msec() / 1000.0

	if Input.is_action_just_pressed("move_left"):
		if not is_on_floor() and dash_cooldown_timer <= 0.0 and now - last_left_tap_time <= DOUBLE_TAP_WINDOW:
			_start_dash(-1.0)
		last_left_tap_time = now

	if Input.is_action_just_pressed("move_right"):
		if not is_on_floor() and dash_cooldown_timer <= 0.0 and now - last_right_tap_time <= DOUBLE_TAP_WINDOW:
			_start_dash(1.0)
		last_right_tap_time = now


func _start_dash(direction: float) -> void:
	dash_timer = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN
	dash_direction = direction
	visual.scale = DASH_STRETCH
	AudioManager.play("dash")
	dashed.emit(global_position, direction)


func _handle_charge_and_jump(delta: float) -> void:
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	if coyote_timer > 0.0 and Input.is_action_pressed("charge_jump"):
		if not is_charging:
			is_charging = true
			charge_time = 0.0
		else:
			charge_time = min(charge_time + delta, MAX_CHARGE_TIME)

	if is_charging and Input.is_action_just_released("charge_jump"):
		_release_jump()


func _release_jump() -> void:
	var charge_ratio: float = charge_time / MAX_CHARGE_TIME
	velocity.y = -lerp(MIN_JUMP_SPEED, MAX_JUMP_SPEED, charge_ratio)
	is_charging = false
	charge_time = 0.0
	coyote_timer = 0.0
	visual.scale = JUMP_STRETCH
	AudioManager.play("jump")
	SaveManager.record_jump()


func reset_charge() -> void:
	is_charging = false
	charge_time = 0.0
	coyote_timer = 0.0


func get_charge_ratio() -> float:
	return charge_time / MAX_CHARGE_TIME


func _update_visual(delta: float) -> void:
	visual.scale = visual.scale.lerp(Vector2.ONE, delta * SQUASH_LERP_SPEED)
	visual.is_charging = is_charging
	visual.charge_ratio = get_charge_ratio()
	visual.body_color = CHARGE_COLOR if is_charging else SaveManager.get_selected_skin_color()
	visual.queue_redraw()
