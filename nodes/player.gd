class_name Player
extends CharacterBody3D



signal made_noise

const SPEED = 10.0
const JUMP_VELOCITY = 5.0
const JUMP_NOISE = preload("res://assets/Sound/SFX/GWJ 2.1_BearJump.mp3")
const THROW_NOISE = preload("res://assets/Sound/SFX/GWJ 2.1_SnowBallThrow.mp3")
const STEP_NOISES = [preload("res://assets/Sound/SFX/GWJ 2.1_BearStep1.mp3"),
		preload("res://assets/Sound/SFX/GWJ 2.1_BearStep2.mp3")]


@export var TILT_LIMIT := PI/2
@export var TURN_DAMP = 250.0
@export var POWER_GROWTH = 30.0
@export var POWER_LIMIT = 50.0

var snowball_scene
var snowball_instance
var mouse_motion : Vector2
var shoot_energy : float

@onready var camera = $Camera3D
@onready var facing = $Camera3D/Marker3D
@onready var step_sfx = $Step
@onready var other_sfx = $ThrowJump



func _ready():
	# Capture mouse, no cursor visible
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	# Gets the vector of the mouse motion
	if event is InputEventMouseMotion:
		mouse_motion += event.relative

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
