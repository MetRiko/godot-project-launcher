extends Control
class_name ProjectLoader

signal project_file_loaded(project_file_path : String, error : ProjectLoadingError)
signal project_file_unloaded()

enum ProjectLoadingError {
	OK,
	PROJECT_NOT_FOUND,
	INVALID_PROJECT
}

@export_group("content")
@export var content_load : Control
@export var content_loaded : Control

@export_group("buttons")
@export var button_browse_file : Button 
@export var button_browse_dir : Button 
@export var button_clipboard : Button 
@export var button_cancel_found_project : Button 

var project_file_path : String = ""

func _ready():
	set_project_file("")
	button_clipboard.pressed.connect(_on_button_clipboard_pressed)
	button_browse_file.pressed.connect(_on_button_browse_file_pressed)
	button_browse_dir.pressed.connect(_on_button_browse_dir_pressed)
	button_cancel_found_project.pressed.connect(_on_button_button_cancel_found_project)
	get_tree().root.files_dropped.connect(_on_files_dropped)

func _on_button_button_cancel_found_project():
	project_file_path = ""
	project_file_unloaded.emit()
	content_load.visible = true
	content_loaded.visible = false

func _on_button_clipboard_pressed():
	var clipboard := DisplayServer.clipboard_get()
	var project_path := try_get_project_path(clipboard)
	set_project_file(project_path)

func _on_files_dropped(files):
	if files.size() > 0:
		var filepath = files[0]
		var project_file := try_get_project_path(filepath)
		set_project_file(project_file)
		
func _on_button_browse_file_pressed():
	DisplayServer.file_dialog_show("Select project.godot file", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["project.godot"], _browse_file_callback)
			
func _on_button_browse_dir_pressed():
	DisplayServer.file_dialog_show("Scan the directory for the project.godot file", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_DIR, [], _browse_file_callback)
			
func _browse_file_callback(status : bool, selected_paths : PackedStringArray, selected_filter_index : int):
	if selected_paths.size() > 0:
		var path = selected_paths[0]
		var project_file := try_get_project_path(path)
		set_project_file(project_file)

func _validate_project(project_file_path : String) -> ProjectLoadingError:
	if project_file_path == "":
		return ProjectLoadingError.PROJECT_NOT_FOUND
		
	var project := ConfigFile.new()
	var err = project.load(project_file_path)
	if err != OK:
		return ProjectLoadingError.INVALID_PROJECT
	
	if not project.has_section_key("application", "config/name"):
		return ProjectLoadingError.INVALID_PROJECT
		
	return ProjectLoadingError.OK
	
func set_project_file(project_file_path : String):
	project_file_path = project_file_path.replace("\\", "/")
	var err := _validate_project(project_file_path)
	var is_project_valid := err == ProjectLoadingError.OK
	
	match err:
		ProjectLoadingError.OK:
			print("Project found: " + project_file_path)
			self.project_file_path = project_file_path
		ProjectLoadingError.PROJECT_NOT_FOUND:
			print("Project not found!")
			self.project_file_path = ""
		ProjectLoadingError.INVALID_PROJECT:
			print("Invalid project: " + project_file_path)
			self.project_file_path = ""
			
	project_file_loaded.emit(project_file_path, err)
	
	content_load.visible = not is_project_valid
	content_loaded.visible = is_project_valid

func try_get_project_path(filepath : String) -> String:
	if not filepath.is_absolute_path():
		return ""
	
	if DirAccess.dir_exists_absolute(filepath):
		var files = find_files_in_dir(filepath, "project.godot", 4)
		return files[0] if not files.is_empty() else ""
	
	if filepath.get_file() == "project.godot" and FileAccess.file_exists(filepath):
		return filepath
			
	return ""

func find_files_in_dir(path : String, filename : String, recursive_count : int = -1) -> PackedStringArray:
	var arr := PackedStringArray()
	traverse_directory(path, func(path): if path.get_file() == filename: arr.append(path))
	return arr

func traverse_directory(path: String, callback: Callable, recursive_count : int = -1) -> bool:
	var access = DirAccess.open(path)
	if access == null:
		print_debug("Cannot access \"%s\" directory" % path)
		return false
		
	if access.list_dir_begin() != OK:
		print_debug("Cannot traverse \"%s\" directory" % path)
		return false
		
	var current = access.get_next()
	var dirs_to_search : PackedStringArray = []
	while not current.is_empty():
		var full_path = "%s/%s" % [ path, current ]
		if access.current_is_dir():
			dirs_to_search.append(full_path)
		elif FileAccess.file_exists(full_path):
			callback.call(full_path)
		current = access.get_next()
		
	if recursive_count != 0:
		for dir_path in dirs_to_search:
			if not traverse_directory(dir_path, callback, recursive_count - 1):
				return false
			
	return true
