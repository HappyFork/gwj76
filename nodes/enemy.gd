extends CharacterBody3D


const SPEED = 5.0
@onready var navagent := $NavigationAgent3D
@onready var wtimer = $WaitTimer
enum States {WAITING, WANDERING, FLEEING, RESCUING, FROZEN}
var state : States = States.WAITING


func _ready():
	wtimer.timeout.connect( decide )
	navagent.navigation_finished.connect( decide )
	wtimer.start()


func _physics_process(delta):
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
	state = new_state
	match state:
		States.WAITING:
			wtimer.start()
		States.WANDERING:
			choose_random_location()


func choose_random_location():
	var random_position = Vector3( randf_range(-29.0,29.0), -0.5, randf_range(-29.0,29.0) )
	navagent.set_target_position( random_position )
