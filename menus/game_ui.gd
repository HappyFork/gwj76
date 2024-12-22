extends CanvasLayer


const general = preload("res://menus/menu_general.tscn")
const controls = preload("res://menus/menu_controls.tscn")
const audio = preload("res://menus/menu_audio.tscn")
var psd = false
@onready var pause_panel = $ColorRect
@onready var tab_container = $ColorRect/TabContainer
@onready var power_bar = $ProgressBar
@export var player : Player


func _ready() -> void:
	power_bar.max_value = player.POWER_LIMIT
	tab_container.add_child( general.instantiate() )
	tab_container.add_child( controls.instantiate() )
	tab_container.add_child( audio.instantiate() )

func _input(event: InputEvent) -> void:
	if event.is_action_pressed( "pause" ):
		if psd:
			tab_container.current_tab = 0
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
