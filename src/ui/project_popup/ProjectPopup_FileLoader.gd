extends FileLoaderComponent

var loaded_projects : Array[GodotProjectFile] = []
var searching_status : FileUtilsImpl_ThreadedTraverse.SearchingStatus = null

func _ready():
	super._ready()
	visibility_changed.connect(_on_visibility_changed)
	browse_file_button.pressed.connect(_on_button_browse_file_pressed)
	browse_dir_button.pressed.connect(_on_button_browse_dir_pressed)
	
func _on_button_browse_file_pressed():
	DisplayServer.file_dialog_show("Select project.godot file", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["project.godot"], _browse_file_callback)
			
func _on_button_browse_dir_pressed():
	DisplayServer.file_dialog_show("Scan the directory for the project.godot file(s)", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_DIR, [], _browse_file_callback)
		
func _browse_file_callback(status : bool, selected_paths : PackedStringArray, selected_filter_index : int):
	if selected_paths.size() > 0:
		var path = selected_paths[0]
		if path != "":
			set_path(path)
		
func _on_visibility_changed() -> void:
	if not visible and searching_status != null:
		searching_status.cancel_searching()
		searching_status = null

func _validate_single_file(filepath : String) -> void:
	loaded_projects.clear()
	var project := GodotProjectFile.new()
	var error := project.try_load_project(filepath)
	if project.is_project_valid():
		_show_result("Godot project loaded.")
		loaded_projects.append(project)
	else:
		_show_error("[Error] Invalid file. Expecting 'godot.project' file.")
		
func _validate_dir(dirpath : String) -> void:
	loaded_projects.clear()
	if searching_status != null:
		searching_status.cancel_searching()
	searching_status = FileUtils.Traversing.traverse_directory_threaded(dirpath, -1, null, null, true)
	searching_status.set_completion_callback(_validate_files)
	
func _validate_files(files : PackedStringArray) -> void:
	loaded_projects.clear()
	for file in files:
		var project := GodotProjectFile.new()
		var error := project.try_load_project(file)
		if project.is_project_valid():
			loaded_projects.append(project)

	if loaded_projects.is_empty():
		_show_error("[Error] No godot projects found in this directory.")
	elif loaded_projects.size() == 1:
		_show_result("One Godot project found at:\n" + loaded_projects[0].get_project_path())
	else:
		var projects_paths := loaded_projects.map(func(project): return "- " + project.get_project_path())
		_show_result("Multiple Godot projects found:\n" + ",\n".join(projects_paths))

func _check_path(path : String) -> void:
	if searching_status != null:
		searching_status.cancel_searching()
		searching_status = null
		
	if path.is_empty():
		_show_drop()
	elif FileAccess.file_exists(path):
		_show_loading()
		_validate_single_file(path)
	elif DirAccess.dir_exists_absolute(path):
		_show_loading()
		_validate_dir(path)
	else:
		_show_error("[Error] Provided path doesn't exist!")
