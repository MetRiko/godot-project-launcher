extends Node
class_name FileUtilsImpl

@export var Traversing : FileUtilsImpl_ThreadedTraverse

class SimpleMatchExpr:
	var expr : String
	var case_sensitive : bool
	func _init(_expr : String, _case_sensitive : bool = true):
		expr = _expr
		case_sensitive = _case_sensitive
		
	func return_matching_func() -> Callable:
		if expr.is_empty() or expr == "*":
			return func(filename : String) -> bool: return true
		elif case_sensitive:
			return func(filename : String) -> bool: return filename.match(expr)
		else:
			return func(filename : String) -> bool: return filename.matchn(expr)

static func convert_string_to_proper_path(path : String) -> String:
	if path == "":
		return ""
	if path.begins_with("\"") and path.ends_with("\""):
		path = path.substr(1, path.length() - 2)
	elif path.begins_with("'") and path.ends_with("'"):
		path = path.substr(1, path.length() - 2)
		
	return path.replace("\\", "/")
	
static func try_get_project_path(filepath : String) -> String:
	if not filepath.is_absolute_path():
		return ""
	
	if DirAccess.dir_exists_absolute(filepath):
		var files = find_files_in_dir(filepath, "project.godot", 4)
		return files[0] if not files.is_empty() else ""
	
	if filepath.get_file() == "project.godot" and FileAccess.file_exists(filepath):
		return filepath
			
	return ""

static func find_files_in_dir(path : String, filename_expr : String, recursive_count : int = -1) -> PackedStringArray:
	var arr := PackedStringArray()
	traverse_directory(path, func(path): if path.get_file().match(filename_expr): arr.append(path))
	return arr

static func traverse_directory(path: String, callback: Callable, recursive_count : int = -1) -> bool:
	var access = DirAccess.open(path)
	if access == null:
		print_debug("Cannot access \"%s\" directory" % path)
		return false
		
	if access.list_dir_begin() != OK:
		print_debug("Cannot traverse \"%s\" directory" % path)
		return false
		
	var current := access.get_next()
	var dirs_to_search : PackedStringArray = []
	while not current.is_empty():
		var full_path = "%s/%s" % [ path, current ]
		print(current)
		if access.current_is_dir():
		#if not current.begins_with('.') and access.current_is_dir():
			dirs_to_search.append(full_path)
		elif FileAccess.file_exists(full_path):
			callback.call(full_path)
		current = access.get_next()
		
	if recursive_count != 0:
		for dir_path in dirs_to_search:
			if not traverse_directory(dir_path, callback, recursive_count - 1):
				return false
			
	return true
