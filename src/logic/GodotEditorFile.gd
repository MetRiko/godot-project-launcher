extends Resource
class_name GodotEditorFile

enum EditorLoadingError {
	OK,
	INVALID_FILE,
	FILE_NOT_EXIST,
	UNKNOWN_VERSION,
	NONE
}

var exe_path := ""
var latest_error := EditorLoadingError.NONE

enum VersionStatus {
	ALPHA, DEV, BETA, RELEASE_CANDIDATE, STABLE, UNKNOWN
}

var suffix := ""
var full_name := ""
var about_godot_name_like := ""
var major_version := 0
var minor_version := 0
var patch_version := 0
var version_status := VersionStatus.UNKNOWN
var version_status_index := 0
var mono := false
var official := false
var version_uid := "xxxxxxxxx"

var display_name := ""

func get_detailed_name() -> String:
	return about_godot_name_like

func get_display_name() -> String:
	if display_name == "":
		_compile_display_name()
	return display_name

func is_editor_executable_valid() -> bool:
	return latest_error == EditorLoadingError.OK
	
func _compile_display_name() -> void:
	if latest_error != EditorLoadingError.OK:
		display_name = ""
		about_godot_name_like = ""
		return
		
	var uid_split := full_name.rsplit(".", true, 1)
	about_godot_name_like = "%s [%s]" % [uid_split[0], uid_split[1]]
		
	var version_arr := [major_version, minor_version]
	if patch_version > 0:
		version_arr.append(patch_version)
	var version_str := ".".join(version_arr)
	var status_str := ""
	match version_status:
		VersionStatus.ALPHA: status_str = "Alpha"
		VersionStatus.DEV: status_str = "Dev"
		VersionStatus.BETA: status_str = "Beta"
		VersionStatus.RELEASE_CANDIDATE: status_str = "RC"
		VersionStatus.STABLE: status_str = ""
		VersionStatus.UNKNOWN: status_str = ""
	
	display_name = "Godot " + version_str
	
	if status_str != "":
		if version_status_index != 0:
			status_str += str(version_status_index)
		display_name += " " + status_str
		
	if suffix != "":
		display_name += " - " + suffix

func _load_project_and_validate(godot_exe_path : String) -> EditorLoadingError:
	self.exe_path = godot_exe_path
	
	if not FileAccess.file_exists(godot_exe_path):
		return EditorLoadingError.FILE_NOT_EXIST
		
	if godot_exe_path.get_extension() != "exe" or not "godot" in godot_exe_path.get_basename().to_lower():
		return EditorLoadingError.INVALID_FILE
		
	var output : Array[String] = []
	var result = OS.execute(godot_exe_path, ['--version'], output)
	if result == -1 or output.size() != 1:
		return EditorLoadingError.INVALID_FILE
	
	var version := output[0].strip_edges()
	var godot_version_regex = RegEx.new()
	var godot_version_regex_str := r"^(\d)\.(\d\d?)\.(?:(\d\d?)\.)?(?:([a-z]+)(\d+)?)\.(?:([a-z0-9_]+)\.)?([a-z0-9_]+)\.([a-z0-9]{9})$"
	godot_version_regex.compile(godot_version_regex_str)
	
	var match_result := godot_version_regex.search(version)
	if match_result == null:
		return EditorLoadingError.UNKNOWN_VERSION
		
	var groups := match_result.strings
		
	full_name = groups[0]
	major_version = int(groups[1])
	minor_version = int(groups[2])
	patch_version = int(groups[3])
	version_status_index = int(groups[5])
	var version_status_str := groups[4]
	match version_status_str:
		"alpha": version_status = VersionStatus.ALPHA
		"dev": version_status = VersionStatus.DEV
		"beta": version_status = VersionStatus.BETA
		"rc": version_status = VersionStatus.RELEASE_CANDIDATE
		"stable": version_status = VersionStatus.STABLE
		_: version_status = VersionStatus.UNKNOWN
	mono = groups[6] == "mono"
	official = groups[7] == "official"
	version_uid = groups[8]
	
	if version_status != VersionStatus.STABLE and version_status_index == 0:
		version_status_index = 1

	_compile_display_name()

	return EditorLoadingError.OK
	
func try_load_project(godot_exe_path : String) -> EditorLoadingError:
	self.exe_path = FileUtils.convert_string_to_proper_path(godot_exe_path)
	var error := _load_project_and_validate(self.exe_path)
	latest_error = error
	
	match error:
		EditorLoadingError.OK:
			print("[Success] Editor executable found: " + self.exe_path)
		EditorLoadingError.FILE_NOT_EXIST:
			print("[Error] Editor executable doesn't exist at: " + self.exe_path)
		EditorLoadingError.INVALID_FILE:
			print("[Error] Invalid editor executable: " + self.exe_path)
		EditorLoadingError.UNKNOWN_VERSION:
			print("[Error] This editor executable has invalid version format: " + self.exe_path)
			
	return latest_error
