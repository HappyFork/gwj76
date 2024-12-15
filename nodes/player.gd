extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const TURN_DAMP = 250.0
var mouse_motion : Vector2
var shoot_energy : float
@onready var camera = $Camera3D
var snowball = preload("res://nodes/snowball.tscn")


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
	# Limit camera tilt
	if camera.rotation.x > 1.0:
		camera.rotation.x = 1.0
	if camera.rotation.x < -1.0:
		camera.rotation.x = -1.0
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
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
		# Fire using built-up energy
		var shootforce = -transform.basis.z # Calculate facing angle
		shootforce.rotated( Vector3.RIGHT, camera.rotation.x ) # Add camera angle
		shootforce = shootforce.normalized() # Normalize
		shootforce *= shoot_energy # Multiply by energy
		# TODO: make sure this angle is figured correctly
		throw_snowball( shootforce )
		shoot_energy = 0.0 # Reset shoot energy
	elif Input.is_action_pressed( "shoot" ):
		# Increase by an arbitrary amount. I'll tweak this
		# before making it a constant
		shoot_energy += ( 100.0 * delta )
	
	# Reset rotation
	mouse_motion = Vector2.ZERO


func throw_snowball( initf: Vector3 ):
	var s : RigidBody3D = snowball.instantiate()
	s.apply_central_impulse( initf )
	add_child( s )
