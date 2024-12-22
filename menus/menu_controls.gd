extends Panel


const INPUT_LINE = preload("res://menus/input_mapper_line.tscn")
var is_remapping = false
var action_to_remap = null
var remapping_button = null
var action_map = {
	"move_forward": "Forward",
	"move_backward": "Backward",
	"move_left": "Left",
	"move_right": "Right",
	"jump": "Jump",
	"shoot": "Throw Snowball"
}
@onready var input_list = $MarginContainer/ScrollContainer/VBoxContainer


func _ready():
	create_input_list()

func _input(event):
	if event.is_action_pressed( "shoot" ):
		print( "Remappy" )
	if is_remapping:
		if event is InputEventKey or (event is InputEventMouseButton and event.pressed ):
			if event is InputEventMouseButton and event.double_click:
				event.double_click = false
			
			InputMap.action_erase_events( action_to_remap )
			InputMap.action_add_event( action_to_remap, event )
			print( "Remapped?" )
			remapping_button.find_child("InputButton").text = event.as_text().trim_suffix( " (Physical)" )
			
			is_remapping = false
			action_to_remap = false
			remapping_button = null
			
			accept_event()


func create_input_list():
	InputMap.load_from_project_settings()
	for action in action_map:
		var line = INPUT_LINE.instantiate()
		var action_label : Label = line.find_child("Label")
		var input_label : Button = line.find_child("InputButton")
		
		action_label.text = action_map[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix( " (Physical)" )
		else:
			input_label.text = ""
		
		input_label.pressed.connect( _on_input_button_pressed.bind( line , action ) )
		input_list.add_child( line )


func _on_input_button_pressed( hbox, act ):
	if !is_remapping:
		is_remapping = true
		action_to_remap = act
		remapping_button = hbox
		hbox.find_child( "InputButton" ).text = "Press Key to bind..."

func _on_input_default_pressed():
	for item in input_list.get_children():
		item.queue_free()
	create_input_list()
