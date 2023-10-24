extends Control

@export var line_project_name : LineEdit
@export var line_project_path : LineEdit
@export var button_select_version : Button
@export var button_custom_version : Button
@export var project_loader : ProjectLoader
@export var error_message_label : Label
@export var button_cancel : Button
@export var button_accept : Button

func _ready():
	hide_error_message()
	_unload_project()
	project_loader.project_file_loaded.connect(_on_project_loaded)
	project_loader.project_file_unloaded.connect(_on_project_unloaded)

func _on_project_unloaded():
	_unload_project()
	
func _on_project_loaded(project_godot_path : String, error : ProjectLoader.ProjectLoadingError):
	match error:
		ProjectLoader.ProjectLoadingError.OK:
			hide_error_message()
			_load_project(project_godot_path)
		ProjectLoader.ProjectLoadingError.PROJECT_NOT_FOUND:
			display_error_message("Error: Godot project not found!")
		ProjectLoader.ProjectLoadingError.INVALID_PROJECT:
			var err_msg := "Error: Invalid godot project!\nFailed to load:\n" + project_godot_path
			display_error_message(err_msg)
		
func hide_error_message():
	error_message_label.get_parent().visible = false
		
func display_error_message(error_message : String):
	error_message_label.get_parent().visible = true
	error_message_label.text = error_message

func _unload_project():
	line_project_name.text = ""
	line_project_name.editable = false
	line_project_path.text = ""

func _load_project(project_godot_path : String):
	line_project_name.editable = true
	line_project_path.text = project_godot_path
	
	var project := ConfigFile.new()
	project.load(project_godot_path)
	var project_name : String = project.get_value("application", "config/name")
	line_project_name.text = project_name
	
	
	#var project : Resource = load(project_godot_path)
	#print(project)
	#if project == null:
		#line_project_name.text = ""
		#line_project_path.text = ""
