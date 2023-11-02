extends Node
class_name FileUtilsImpl_ThreadedTraverse

class FoundDir:
	var full_path : String
	var recursion_level := 0
	func _init(_full_path : String, _recursion_level : int):
		full_path = _full_path
		recursion_level = _recursion_level

var _traversing_threads_queue : Array[SearchingStatus] = []

class SearchingStatus:
	var _traversing_threads_queue_ref : Array[SearchingStatus]
	var thread := Thread.new()
	var mutex := Mutex.new()
	var canceled := false
	var completed := false
	var stopped := false
	var called := false
	var files_found : PackedStringArray = []
	var callback : Callable = func(files : PackedStringArray) -> void: return
	func cancel_searching() -> void:
		canceled = true
	func set_completion_callback(callback : Callable) -> void:
		self.callback = callback
	func is_finished() -> bool:
		var out := canceled == true or completed == true or not thread.is_alive()
		return out
	func call_callback() -> void:
		if not called:
			called = true
			callback.call(files_found)

func cancel_all_traversing_threads() -> void:
	for status in _traversing_threads_queue:
		status.cancel_searching()
		
func _process(delta):
	for status in _traversing_threads_queue:
		if status.thread.is_alive():
			continue
		if status.completed == true and status.canceled == false:
			status.call_callback()
		_traversing_threads_queue.erase(status)

func traverse_directory_threaded(path: String, recursive_count : int = 4, filename_expr : FileUtilsImpl.SimpleMatchExpr = null, ignore_dir_expr : FileUtilsImpl.SimpleMatchExpr = null, include_hidden := false) -> SearchingStatus:
	var status := SearchingStatus.new()
	status._traversing_threads_queue_ref = _traversing_threads_queue
	_traversing_threads_queue.append(status)
	status.thread.start(_traverse_directory_threaded.bind(status, status.mutex, path, recursive_count, filename_expr, ignore_dir_expr, include_hidden))
	return status

func _traverse_directory_threaded(status : SearchingStatus, mutex : Mutex, path: String, recursive_count : int = 4, filename_expr : FileUtilsImpl.SimpleMatchExpr = null, ignore_dir_expr : FileUtilsImpl.SimpleMatchExpr = null, include_hidden := false) -> void:
	path = path.simplify_path()
	var matching_files : PackedStringArray = []
	var dir_itr := 0 
	var dirs_queue : Array[FoundDir] = [FoundDir.new(path, recursive_count)]
	var filename_match_func := func(filename : String) -> bool: return true
	if filename_expr:
		filename_match_func = filename_expr.return_matching_func()
		
	var ignore_dir_match_func := func(filename : String) -> bool: return false
	if ignore_dir_expr:
		ignore_dir_match_func = ignore_dir_expr.return_matching_func()

	while dir_itr < dirs_queue.size():
		var dir := dirs_queue[dir_itr]
		var dir_access := DirAccess.open(dir.full_path)
		if dir_access == null:
			continue
		dir_access.include_hidden = include_hidden
		dir_access.list_dir_begin()
		var current := dir_access.get_next()
		while not current.is_empty():
			if dir_access.current_is_dir():
				if dir.recursion_level != 0 and not ignore_dir_match_func.call(current):
					var full_path := dir.full_path.path_join(current)
					dirs_queue.append(FoundDir.new(full_path, dir.recursion_level - 1))
			elif filename_match_func.call(current):
				var full_path := dir.full_path.path_join(current)
				matching_files.append(full_path)
			current = dir_access.get_next()
			
			mutex.lock()
			var is_canceled := status.canceled
			mutex.unlock()
			if is_canceled: return

		dir_itr += 1
		
		mutex.lock()
		var is_canceled := status.canceled
		mutex.unlock()
		if is_canceled: return

	mutex.lock()
	status.completed = true
	status.files_found = matching_files
	mutex.unlock()
	
	#print("\n".join(matching_files))
	
func traverse_directory_test():
	#traverse_directory("F:/Projects/GodotProjectLauncher/godot-project-launcher", 0, SimpleMatchExpr.new("*"))
	#traverse_directory("F:/Projects/GodotProjectLauncher/godot-project-launcher", 1, SimpleMatchExpr.new("*"), SimpleMatchExpr.new(".*"))
	#traverse_directory("F:/Projects/GodotProjectLauncher/godot-project-launcher", 1, SimpleMatchExpr.new("*"))
	#traverse_directory("F:/Projects/GodotProjectLauncher/godot-project-launcher", -1, SimpleMatchExpr.new("*.svg"), null, true)
	#traverse_directory("F:/Projects/GodotProjectLauncher/godot-project-launcher", -1, null, SimpleMatchExpr.new(".*"), true)
	#traverse_directory("F:/Projects/GodotProjectLauncher/godot-project-launcher", -1, SimpleMatchExpr.new("project.godot"), null, true)
	
	#traverse_directory("F:/Projects/GodotProjectLauncher/godot-project-launcher", -1, SimpleMatchExpr.new("project.godot"), SimpleMatchExpr.new(".*"), true)
	#traverse_directory("F:/Dev/godot", 2, SimpleMatchExpr.new("*godot*.exe", false))
	
	var status := traverse_directory_threaded("F:/Dev/godot", -1, FileUtilsImpl.SimpleMatchExpr.new("*godot*.exe", false))
	status.set_completion_callback(_test_completion_callback)
	print("Searching started...")
	status.cancel_searching()
	print("Searching canceled...")
	var status2 := traverse_directory_threaded("F:/Dev/godot", -1, FileUtilsImpl.SimpleMatchExpr.new("*godot*.exe", false))
	status2.set_completion_callback(_test_completion_callback)
	print("Searching started...")
	
func _test_completion_callback(files : PackedStringArray) -> void:
	print("Searching ended...")
	print("Files found:\n" + "\n".join(files))
	
#func _input(event):
	#if event is InputEventKey:
		#if event.is_pressed() and event.keycode == KEY_D:
			#traverse_directory_test()

func traverse_directory(path: String, recursive_count : int = 4, filename_expr : FileUtilsImpl.SimpleMatchExpr = null, ignore_dir_expr : FileUtilsImpl.SimpleMatchExpr = null, include_hidden := false) -> void:
	path = path.simplify_path()
	var matching_files : Array[String] = []
	var dir_itr := 0 
	var dirs_queue : Array[FoundDir] = [FoundDir.new(path, recursive_count)]
	var filename_match_func := func(filename : String) -> bool: return true
	if filename_expr:
		filename_match_func = filename_expr.return_matching_func()
		
	var ignore_dir_match_func := func(filename : String) -> bool: return false
	if ignore_dir_expr:
		ignore_dir_match_func = ignore_dir_expr.return_matching_func()

	while dir_itr < dirs_queue.size():
		var dir := dirs_queue[dir_itr]
		var dir_access := DirAccess.open(dir.full_path)
		dir_access.include_hidden = include_hidden
		dir_access.list_dir_begin()
		var current := dir_access.get_next()
		while not current.is_empty():
			if dir_access.current_is_dir():
				if dir.recursion_level != 0 and not ignore_dir_match_func.call(current):
					var full_path := dir.full_path.path_join(current)
					dirs_queue.append(FoundDir.new(full_path, dir.recursion_level - 1))
			elif filename_match_func.call(current):
				var full_path := dir.full_path.path_join(current)
				matching_files.append(full_path)
			current = dir_access.get_next()
		dir_itr += 1
		
	print("\n".join(matching_files))
