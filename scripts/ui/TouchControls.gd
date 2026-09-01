extends CanvasLayer

@onready var left_button: Button = $LeftButton
@onready var right_button: Button = $RightButton
@onready var jump_button: Button = $JumpButton


func _ready() -> void:
	left_button.button_down.connect(func(): Input.action_press("move_left"))
	left_button.button_up.connect(func(): Input.action_release("move_left"))
	right_button.button_down.connect(func(): Input.action_press("move_right"))
	right_button.button_up.connect(func(): Input.action_release("move_right"))
	jump_button.button_down.connect(func(): Input.action_press("charge_jump"))
	jump_button.button_up.connect(func(): Input.action_release("charge_jump"))
