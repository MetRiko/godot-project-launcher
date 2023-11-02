extends VBoxContainer
class_name FileLoaderComponent

@export_group("Path")
@export var path_label : Label
@export var path_input : LineEditForPath
@export var browse_file_button : Button
@export var browse_dir_button : Button

@export_group("States")
@export var state_panels : FileLoaderComponent_StatePanels

var allow_dropping := false

var file_browse_title : String = ""
var dir_browse_title : String = ""
var file_browse_filters : PackedStringArray = []

var searching_status : FileUtilsImpl_ThreadedTraverse.SearchingStatus = null

func set_path(path : String) -> void:
	path_input.set_path(path)
	_check_path(path_input.text)
	
func show_result(result_msg : String) -> void:
	state_panels.show_result(result_msg)

func show_error(error_msg : String) -> void:
	state_panels.show_error(error_msg)
	
func setup_browse_file_dialog(window_title : String, files_filters : PackedStringArray) -> void:
	file_browse_title = window_title
	file_browse_filters = files_filters
	browse_file_button.pressed.connect(_on_button_browse_file_pressed)

func setup_browse_dir_dialog(window_title : String) -> void:
	dir_browse_title = window_title
	browse_dir_button.pressed.connect(_on_button_browse_dir_pressed)
	
func _ready():
	path_input.path_changed.connect(_on_path_changed)
	_check_path(path_input.text)
	_update_dropping_permission()
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	_update_dropping_permission()
	if not visible and searching_status != null:
		searching_status.cancel_searching()
		searching_status = null
		
func _on_button_browse_file_pressed():
	DisplayServer.file_dialog_show(file_browse_title, "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, file_browse_filters, _browse_file_callback)
	
func _on_button_browse_dir_pressed():
	DisplayServer.file_dialog_show(dir_browse_title, "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_DIR, [], _browse_file_callback)

func _browse_file_callback(status : bool, selected_paths : PackedStringArray, selected_filter_index : int):
	if selected_paths.size() > 0:
		var path = selected_paths[0]
		if path != "":
			set_path(path)
			
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

func _on_files_dropped(files : PackedStringArray):
	if files.size() > 0:
		path_input.set_path(files[0])
		_check_path(path_input.text)

func _on_path_changed(path : String) -> void:
	_check_path(path)

func _validate_dir(dirpath : String) -> void:
	if searching_status != null:
		searching_status.cancel_searching()
	searching_status = _traverse(dirpath)
	searching_status.set_completion_callback(_validate_files)
	
func _traverse(dirpath : String) -> FileUtilsImpl_ThreadedTraverse.SearchingStatus: # @override
	return null
	
func _validate_single_file(filepath : String) -> void: # @override
	pass
	
func _validate_files(files : PackedStringArray) -> void: # @override
	pass
	
func _check_path(path : String) -> void:
	if searching_status != null:
		searching_status.cancel_searching()
		searching_status = null
		
	if path.is_empty():
		state_panels.show_drop()
	elif FileAccess.file_exists(path):
		state_panels.show_loading()
		_validate_single_file(path)
	elif DirAccess.dir_exists_absolute(path):
		state_panels.show_loading()
		_validate_dir(path)
	else:
		state_panels.show_error("[Error] Provided path doesn't exist!")

