extends Resource
class_name GodotProjectFile

enum ProjectLoadingError {
	OK,
	PROJECT_NOT_FOUND,
	INVALID_PROJECT,
	NONE
}

class ProjectLoadingResult:
	var data : ConfigFile = null
	var error : ProjectLoadingError

var project_path := ""
var latest_error := ProjectLoadingError.PROJECT_NOT_FOUND
var project_data : ConfigFile = null

func get_project_name() -> String:
	if project_data == null:
		return ""
	return project_data.get_value("application", "config/name", "")

func is_project_valid() -> bool:
	return latest_error == ProjectLoadingError.OK

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

func _load_project_and_validate(project_path : String) -> ProjectLoadingResult:
	print("Checking... [%s]" % [project_path])
	
	var result := ProjectLoadingResult.new()
	
	if project_path == "":
		result.error = ProjectLoadingError.PROJECT_NOT_FOUND
		return result
		
	var project := ConfigFile.new()
	var err = project.load(project_path)
	if err != OK:
		result.error = ProjectLoadingError.INVALID_PROJECT
		return result
	
	if not project.has_section_key("application", "config/name"):
		result.error = ProjectLoadingError.INVALID_PROJECT
		return result
	
	result.data = project
	return result

func try_load_project(project_path : String) -> ProjectLoadingError:
	self.project_path = FileUtils.convert_string_to_proper_path(project_path)
	var result := _load_project_and_validate(self.project_path)
	latest_error = result.error
	project_data = result.data
	
	match result.error:
		ProjectLoadingError.OK:
			print("[Success] Project found: " + self.project_path)
		ProjectLoadingError.PROJECT_NOT_FOUND:
			print("[Error] Project not found!")
		ProjectLoadingError.INVALID_PROJECT:
			print("[Error] Invalid project: " + self.project_path)
			
	return latest_error
