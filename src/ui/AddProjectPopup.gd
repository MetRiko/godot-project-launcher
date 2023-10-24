extends Control

@export var line_project_name : LineEdit
@export var line_project_path : LineEdit
@export var button_select_version : Button
@export var button_custom_version : Button
@export var project_loader : ProjectLoader
@export var error_message_label : Label
@export var button_cancel : Button
@export var button_accept : Button

var project : GodotProjectFile = null

func _ready():
	hide_error_message()
	_unload_project()
	project_loader.project_file_loaded.connect(_on_project_loaded)
	project_loader.project_file_unloaded.connect(_on_project_unloaded)

func _on_project_unloaded():
	_unload_project()
	
func _on_project_loaded(project : GodotProjectFile):
	setup_project(project)
		
func hide_error_message():
	error_message_label.get_parent().visible = false
		
func display_error_message(error_message : String):
	error_message_label.get_parent().visible = true
	error_message_label.text = error_message

func _unload_project():
	line_project_name.text = ""
	line_project_name.editable = false
	line_project_path.text = ""

func _setup_valid_project(project : GodotProjectFile) -> void:
	line_project_name.editable = true
	line_project_path.text = project.project_path
	line_project_name.text = project.get_project_name()
	hide_error_message()
	
func _setup_no_project() -> void:
	line_project_name.editable = false
	line_project_path.text = ""
	line_project_name.text = ""
	
func _setup_invalid_project(project : GodotProjectFile) -> void:
	_setup_no_project()
	match project.latest_error:
		GodotProjectFile.ProjectLoadingError.PROJECT_NOT_FOUND:
			display_error_message("Error: Godot project not found!")
		GodotProjectFile.ProjectLoadingError.INVALID_PROJECT:
			var err_msg := "Error: Invalid godot project!\nFailed to load:\n" + project.project_path
			display_error_message(err_msg)
	
func setup_project(project : GodotProjectFile):
	self.project = project 
	if project == null:
		_setup_no_project()
	elif project.is_project_valid():
		_setup_valid_project(project)
	else:
		_setup_invalid_project(project)
