extends Control
class_name ProjectLoader

signal project_file_loaded(project : GodotProjectFile)
signal project_file_unloaded()

@export_group("content")
@export var content_load : Control
@export var content_loaded : Control

@export_group("buttons")
@export var button_browse_file : Button 
@export var button_browse_dir : Button 
@export var button_clipboard : Button 
@export var button_cancel_found_project : Button 

var project : GodotProjectFile = null

func _ready():
	_unload_project()
	button_clipboard.pressed.connect(_on_button_clipboard_pressed)
	button_browse_file.pressed.connect(_on_button_browse_file_pressed)
	button_browse_dir.pressed.connect(_on_button_browse_dir_pressed)
	button_cancel_found_project.pressed.connect(_on_button_button_cancel_found_project)
	get_tree().root.files_dropped.connect(_on_files_dropped)

func _on_button_button_cancel_found_project():
	_unload_project()

func _on_button_clipboard_pressed():
	var clipboard_string := DisplayServer.clipboard_get()
	var path := FileUtils.convert_string_to_proper_path(clipboard_string)
	var project_path := FileUtils.try_get_project_path(path)
	_try_load_project(project_path)

func _on_files_dropped(files):
	if files.size() > 0:
		var filepath = files[0]
		var path := FileUtils.convert_string_to_proper_path(filepath)
		var project_file := FileUtils.try_get_project_path(path)
		_try_load_project(project_file)
		
func _on_button_browse_file_pressed():
	DisplayServer.file_dialog_show("Select project.godot file", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["project.godot"], _browse_file_callback)
			
func _on_button_browse_dir_pressed():
	DisplayServer.file_dialog_show("Scan the directory for the project.godot file", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_DIR, [], _browse_file_callback)
			
func _browse_file_callback(status : bool, selected_paths : PackedStringArray, selected_filter_index : int):
	if selected_paths.size() > 0:
		var path = selected_paths[0]
		var project_file := FileUtils.try_get_project_path(path)
		_try_load_project(project_file)

func _unload_project() -> void:
	project = null
	content_load.visible = true
	content_loaded.visible = false
	project_file_unloaded.emit()

func _try_load_project(project_path : String) -> void:
	project = GodotProjectFile.new()
	var err := project.try_load_project(project_path)
	
	var is_project_valid := project.is_project_valid()
	if not is_project_valid:
		project = null
		
	content_load.visible = not is_project_valid
	content_loaded.visible = is_project_valid
	project_file_loaded.emit(project)
