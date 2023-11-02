extends FileLoaderComponent

var loaded_projects : Array[GodotProjectFile] = []

func _ready():
	super._ready()
	setup_browse_file_dialog("Select project.godot file", ["project.godot"])
	setup_browse_dir_dialog("Scan the directory for the project.godot file(s)")

func _traverse(dirpath : String) -> FileUtilsImpl_ThreadedTraverse.SearchingStatus:
	return FileUtils.Traversing.traverse_directory_threaded(dirpath, -1, null, null, true)
	
func _validate_single_file(filepath : String) -> void:
	loaded_projects.clear()
	var project := GodotProjectFile.new()
	var error := project.try_load_project(filepath)
	if project.is_project_valid():
		show_result("Godot project loaded.")
		loaded_projects.append(project)
	else:
		show_error("[Error] Invalid file. Expecting 'godot.project' file.")
	
func _validate_files(files : PackedStringArray) -> void:
	loaded_projects.clear()
	for file in files:
		var project := GodotProjectFile.new()
		var error := project.try_load_project(file)
		if project.is_project_valid():
			loaded_projects.append(project)

	if loaded_projects.is_empty():
		show_error("[Error] No godot projects found in this directory.")
	elif loaded_projects.size() == 1:
		show_result("One Godot project found at:\n" + loaded_projects[0].get_project_path())
	else:
		var projects_paths := loaded_projects.map(func(project): return "- " + project.get_project_path())
		show_result("Multiple Godot projects found:\n" + ",\n".join(projects_paths))
