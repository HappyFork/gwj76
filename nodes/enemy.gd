class_name Enemy
extends CharacterBody3D



enum States {WAITING, WANDERING, FLEEING, RESCUING, FROZEN}

const SPEED = 5.0
const TURNSPEED = 0.03
const BLUE : StandardMaterial3D = preload("res://assets/blue_mat.tres")
const RED : StandardMaterial3D = preload("res://assets/red_mat.tres")

@export var player : Player

var state : States = States.WAITING
var aware : Array[Node3D] = []
var rescue_target : Enemy

@onready var navagent := $NavigationAgent3D
@onready var wtimer := $WaitTimer
@onready var mesh := $CSGMesh3D



func _ready():
	#print( "Ready function running" )
	wtimer.start()

func _process(delta: float) -> void:
	#print( "Process function running" )
	$Debug.text = "State: "
	match state:
		States.WAITING:
			$Debug.text += "WAITING"
		States.WANDERING:
			$Debug.text += "WANDERING"
		States.FLEEING:
			$Debug.text += "FLEEING"
		States.RESCUING:
			$Debug.text += "RESCUING"
		States.FROZEN:
			$Debug.text += "FROZEN"

func _physics_process(delta):
	#print( "Physics process function running" )
	if state == States.RESCUING and rescue_target.state != States.FROZEN:
		rescue_target = null
		decide()
	
	# Check the bodies the enemy is aware of
	if state not in [ States.FLEEING, States.RESCUING ]:
		for b in aware:
			if b is Enemy and b.state == States.FROZEN:
				rescue_target = b
				change_state( States.RESCUING )
	
	# If the enemy is moving,
	if state in [ States.WANDERING, States.FLEEING, States.RESCUING ]:
		# First, check if it needs to turn
		var destination = navagent.get_next_path_position()
		var direction = (destination - global_position).normalized()
		var forward = -global_basis.z
		var turn_angle = forward.signed_angle_to( direction, Vector3.UP )
		if abs( turn_angle ) > 0.5:
			if state == States.FLEEING:
				turn_angle = clamp( turn_angle, -(TURNSPEED*2), TURNSPEED*2 )
			else :
				turn_angle = clamp( turn_angle, -TURNSPEED, TURNSPEED )
			rotate_y( turn_angle )
		# If not, it walks forwards
		else:
			if position != destination:
				look_at( destination )
			else:
				# If this isn't here, sometimes the enemy gets stuck
				change_state( state )
			rotation.x = 0.0
			if state == States.FLEEING:
				direction *= SPEED*2
			else:
				direction *= SPEED
			velocity = direction
			move_and_slide()



func decide():
	#print( "Decide function running" )
	if state == States.FLEEING and player in aware:
		change_state( States.FLEEING )
	
	var dec = randi_range( 0, 1 )
	match dec:
		0:
			change_state( States.WAITING )
		1:
			change_state( States.WANDERING )

func change_state( new_state: int ) -> void:
	#print( "Change state function running" )
	# First, if changing to a new state from frozen
	if state == States.FROZEN and new_state != States.FROZEN:
		mesh.set_material( RED )
	
	# Then, change the state and figure out new behavior
	state = new_state
	match state:
		States.WAITING:
			wtimer.start()
		States.WANDERING:
			choose_random_location()
		States.FLEEING:
			choose_flee_location()
		States.RESCUING:
			navagent.set_target_position( rescue_target.global_position )
		States.FROZEN:
			mesh.set_material( BLUE )

func choose_random_location():
	#print( "Choose random location function running" )
	var random_position = Vector3( randf_range(-25.0,25.0), -0.5, randf_range(-25.0,25.0) )
	while random_position.distance_to( global_position ) < 5.0:
		random_position = Vector3( randf_range(-25.0,25.0), -0.5, randf_range(-25.0,25.0) )
	navagent.set_target_position( random_position )

func choose_flee_location():
	#print( "Choose flee location function running" )
	var away_player = -(player.global_position - global_position) * 4
	away_player.y = -0.5
	navagent.set_target_position( away_player )



func _on_awareness_body_entered(body: Node3D) -> void:
	#print( "On awareness entered function running" )
	if body not in aware and body != self:
		aware.append( body )

func _on_awareness_body_exited(body: Node3D) -> void:
	#print( "On awareness exited function running" )
	while aware.has( body ):
		aware.erase( body )

func _on_touching_area_entered(area: Area3D) -> void:
	#print( "On touching function running" )
	var touched = area.get_parent()
	if touched is Enemy and touched != self and state == States.FROZEN:
		decide()

func _on_player_made_noise():
	#print( "On player noise running" )
	if player in aware and state not in [States.RESCUING, States.FROZEN]:
		change_state( States.FLEEING )
