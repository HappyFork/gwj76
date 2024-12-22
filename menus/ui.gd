extends CanvasLayer


signal go_home
signal go_gone
var psd = false
@onready var pause_panel = $Options
@onready var power_bar = $ProgressBar
@export var player : Player


func _ready() -> void:
	power_bar.max_value = player.POWER_LIMIT


func _input(event: InputEvent) -> void:
	if event.is_action_pressed( "pause" ):
		if psd:
			$Options/TabContainer.current_tab = 0
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_tree().paused = false
			psd = false
			pause_panel.visible = false
		else:
			player.shoot_energy = 0.0 # Prevent player from saving shoot energy
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true
			psd = true
			pause_panel.visible = true
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	power_bar.value = player.shoot_energy


func _on_menu_button_pressed():
	go_home.emit()

func _on_quit_button_pressed() -> void:
	go_gone.emit()

func _on_m_sense_slide_value_changed(value: float) -> void:
	player.TURN_DAMP = ((100.0-value)*3) + 100.0

func _on_default_button_pressed() -> void:
	$ColorRect/TabContainer/General/MSenseSlide.value = 50.0
