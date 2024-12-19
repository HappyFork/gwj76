class_name Enemy
extends CharacterBody3D


const SPEED = 5.0
const BLUE : StandardMaterial3D = preload("res://assets/blue_mat.tres")
const RED : StandardMaterial3D = preload("res://assets/red_mat.tres")
enum States {WAITING, WANDERING, FLEEING, RESCUING, FROZEN}
@onready var navagent := $NavigationAgent3D
@onready var wtimer := $WaitTimer
@onready var mesh := $CSGMesh3D
var state : States = States.WAITING
var aware : Array[Node3D] = []
var rescue_target : Enemy


func _ready():
	wtimer.start()


func _process(delta: float) -> void:
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
	if state == States.RESCUING and rescue_target.state != States.FROZEN:
		rescue_target = null
		decide()
	
	# Check the bodies the enemy is aware of
	if state not in [ States.FLEEING, States.RESCUING ]:
		for b in aware:
			if b is Enemy and b.state == States.FROZEN:
				rescue_target = b
				change_state( States.RESCUING )
	
	# If the enemy can move, it does
	if state in [ States.WANDERING, States.FLEEING, States.RESCUING ]:
		var destination = navagent.get_next_path_position()
		var direction = (destination - global_position).normalized()
		velocity = direction*SPEED
		move_and_slide()


func decide():
	var dec = randi_range( 0, 1 )
	match dec:
		0:
			change_state( States.WAITING )
		1:
			change_state( States.WANDERING )


func change_state( new_state: int ) -> void:
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
		States.FROZEN:
			mesh.set_material( BLUE )


func choose_random_location():
	var random_position = Vector3( randf_range(-29.0,29.0), -0.5, randf_range(-29.0,29.0) )
	navagent.set_target_position( random_position )


func _on_awareness_body_entered(body: Node3D) -> void:
	if body not in aware and body != self:
		aware.append( body )


func _on_awareness_body_exited(body: Node3D) -> void:
	while aware.has( body ):
		aware.erase( body )


func _on_touching_area_entered(area: Area3D) -> void:
	if area.get_parent() is Enemy and state == States.FROZEN:
		decide()
