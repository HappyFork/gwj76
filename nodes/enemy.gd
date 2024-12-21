class_name Enemy
extends CharacterBody3D



enum States {WAITING, WANDERING, FLEEING, RESCUING, FROZEN}

const SPEED = 5.0
const TURNSPEED = 0.03
const GOOD_ENOUGH_ANGLE = 1.0
const MAP_X = 35
const MAP_Y = 2
const MAP_Z = 15

@export var player : Player

var state : States = States.WAITING
var aware : Array[Node3D] = []
var rescue_target : Enemy

@onready var navagent := $NavigationAgent3D
@onready var wtimer := $WaitTimer
@onready var frozen_mesh = $"penguin frozen"
@onready var main_mesh = $"penguin running"
@onready var walk_anim = $"penguin running/AnimationPlayer"



func _ready():
	#print( "Ready function running" )
	player.made_noise.connect( _on_player_made_noise )
	walk_anim.set_current_animation( "walk" )
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
		if abs( turn_angle ) > GOOD_ENOUGH_ANGLE:
			walk_anim.pause()
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
				walk_anim.set_speed_scale(2.0)
				direction *= SPEED*2
			else:
				walk_anim.set_speed_scale( 1.0 )
				direction *= SPEED
			if !walk_anim.is_playing():
				walk_anim.play()
			velocity = direction
			move_and_slide()
	else:
		walk_anim.stop()



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
		frozen_mesh.visible = false
		main_mesh.visible = true
	
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
			main_mesh.visible = false
			frozen_mesh.visible = true

func choose_random_location():
	#print( "Choose random location function running" )
	var random_position = Vector3( randf_range(-MAP_X,MAP_X), MAP_Y, randf_range(-MAP_Z,MAP_Z) )
	while random_position.distance_to( global_position ) < 5.0:
		random_position = Vector3( randf_range(-MAP_X,MAP_X), MAP_Y, randf_range(-MAP_Z,MAP_Z) )
	navagent.set_target_position( random_position )

func choose_flee_location():
	#print( "Choose flee location function running" )
	var away_player = -(player.global_position - global_position) * 4
	away_player.y = MAP_Y
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
