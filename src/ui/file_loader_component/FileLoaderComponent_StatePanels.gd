extends Node
class_name FileLoaderComponent_StatePanels

@export_group("Drop")
@export var drop_area : Control
@export var drop_space_inactive : Control
@export var drop_space_active : Control
@export var drop_label : Label

@export_group("Loading")
@export var loading_panel : Control
@export var loading_label : Label
@export var loading_icon : Control

@export_group("Error")
@export var error_panel : Control
@export var error_label : Label

@export_group("Result")
@export var result_panel : Control
@export var result_label : Label

enum States {
	Drop, Loading, Error, Result
}

var current_state := States.Drop

func _switch_state(next_state : States) -> void:
	current_state = next_state
	drop_area.visible = next_state == States.Drop
	loading_panel.visible = next_state == States.Loading
	error_panel.visible = next_state == States.Error
	result_panel.visible = next_state == States.Result
	
func show_drop():
	_switch_state(States.Drop)
	
func show_loading():
	_switch_state(States.Loading)
	
func show_result(result_text : String):
	_switch_state(States.Result)
	result_label.text = result_text
	
func show_error(error_msg : String):
	_switch_state(States.Error)
	error_label.text = error_msg
