class_name Player
extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 5.0

var snowball = preload("res://nodes/snowball.tscn")
var sball_inst
var mouse_motion : Vector2
var shoot_energy : float

@export var TILT_LIMIT := PI/2
@export var TURN_DAMP = 250.0
@export var POWER_GROWTH = 30.0
@export var POWER_LIMIT = 50.0

@onready var camera = $Camera3D
@onready var facing = $Camera3D/Marker3D



func _ready():
	# Captures mouse, no cursor visible.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	# Gets the vector of the mouse motion.
	# I could do this in _physics_process() if I knew how
	# to reference input events
	if event is InputEventMouseMotion:
		mouse_motion += event.relative

func _physics_process(delta):
	# Get joypad look axis. Overwrite mouse input
	var joyvect = Input.get_vector( "controller_look_left", "controller_look_right", "controller_look_up", "controller_look_down" )
	if joyvect != Vector2.ZERO:
		mouse_motion = joyvect
	# Mouse rotate player
	rotate_y( -mouse_motion.x / TURN_DAMP )
	# Mouse tilt camera
	camera.rotate_x( -mouse_motion.y / TURN_DAMP )
	# Limit camera tilt (for some reason, clampf() doesn't work as expected)
	if camera.rotation.x > TILT_LIMIT:
		camera.rotation.x = TILT_LIMIT
	if camera.rotation.x < -TILT_LIMIT:
		camera.rotation.x = -TILT_LIMIT
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	# Handle shooting
	if Input.is_action_just_released("shoot"):
		throw_snowball() # Fire using built-up energy
		shoot_energy = 0.0 # Reset shoot energy
	elif Input.is_action_pressed( "shoot" ):
		# Increase by an arbitrary amount
		shoot_energy += ( POWER_GROWTH * delta )
		if shoot_energy >= POWER_LIMIT:
			shoot_energy = POWER_LIMIT
	
	# Reset rotation
	mouse_motion = Vector2.ZERO


func throw_snowball():
	sball_inst = snowball.instantiate()
	sball_inst.position = facing.get_global_position()
	var force : Vector3 = facing.get_global_position() - global_position
	sball_inst.apply_central_impulse( force * shoot_energy )
	get_parent().add_child( sball_inst )
