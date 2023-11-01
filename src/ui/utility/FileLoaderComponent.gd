extends VBoxContainer
class_name FileLoaderComponent

@export_group("Path")
@export var path_label : Label
@export var path_input : LineEditForPath
@export var browse_file_button : Button
@export var browse_dir_button : Button

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

var allow_dropping := false
var current_state := States.Drop

func _ready():
	path_input.path_changed.connect(_on_path_changed)
	_check_path(path_input.text)
	_update_dropping_permission()
	
func _update_dropping_permission():
	var is_visible := is_visible_in_tree()
	if allow_dropping == is_visible:
		return
	allow_dropping = is_visible
		
	var is_connected := get_tree().root.files_dropped.is_connected(_on_files_dropped)
	if allow_dropping == is_connected:
		return
	if is_connected:
		get_tree().root.files_dropped.disconnect(_on_files_dropped)
	else:
		get_tree().root.files_dropped.connect(_on_files_dropped)

func set_path(path : String) -> void:
	path_input.set_path(path)
	_check_path(path_input.text)

func _on_files_dropped(files : PackedStringArray):
	if files.size() > 0:
		path_input.set_path(files[0])
		_check_path(path_input.text)
	print(files)

func _switch_state(next_state : States) -> void:
	current_state = next_state
	drop_area.visible = next_state == States.Drop
	loading_panel.visible = next_state == States.Loading
	error_panel.visible = next_state == States.Error
	result_panel.visible = next_state == States.Result
	
func _show_drop():
	_switch_state(States.Drop)
	
func _show_loading():
	_switch_state(States.Loading)
	
func _show_result(result_text : String):
	_switch_state(States.Result)
	result_label.text = result_text
	
func _show_error(error_msg : String):
	_switch_state(States.Error)
	error_label.text = error_msg

func _on_path_changed(path : String) -> void:
	_check_path(path)

func _check_path(path : String) -> void: # <- override
	if path.is_empty():
		_show_drop()
	elif FileAccess.file_exists(path):
		_show_result("File found: " + path.get_file())
	elif DirAccess.dir_exists_absolute(path):
		_show_result("Dir found: " + path)
	else:
		_show_error("[Error] Provided path doesn't exist!")
	
