extends CanvasLayer


@onready var pause_panel = $ColorRect
@onready var power_bar = $ProgressBar
@export var player : Player


func _ready() -> void:
	power_bar.max_value = player.POWER_LIMIT


func _input(event: InputEvent) -> void:
	if event.is_action_pressed( "pause" ):
		player.shoot_energy = 0.0 # Prevent player from saving shoot energy
		
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().paused = !get_tree().paused
		pause_panel.visible = !pause_panel.visible
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	power_bar.value = player.shoot_energy


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_m_sense_slide_value_changed(value: float) -> void:
	player.TURN_DAMP = ((100.0-value)*3) + 100.0

func _on_default_button_pressed() -> void:
	$ColorRect/TabContainer/General/MSenseSlide.value = 50.0
