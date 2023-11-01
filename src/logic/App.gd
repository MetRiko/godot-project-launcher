extends Node
class_name AppManager

const app_data_path = "data.tres"

var app_data : AppData = null

@onready var root : Control = get_tree().root.get_node("Root")
@onready var editors_tab : EditorsTab = root.get_node("Main/EditorsTab")

func _ready():
	var success = try_load_data()
	editors_tab.load_editors(app_data.editors)

func try_load_data() -> bool:
	var does_app_data_exist := ResourceLoader.exists(app_data_path, "AppData")
	if does_app_data_exist:
		print("[Success] Existing 'app_data.tres' loaded successfully.")
		var data : AppData = ResourceLoader.load(app_data_path, "AppData", ResourceLoader.CACHE_MODE_IGNORE)
		app_data = data
		return true
	else:
		print("[Info] File with data not found. New 'app_data.tres' created.")
		app_data = AppData.new()
		return false

func save_data():
	var error := ResourceSaver.save(app_data, app_data_path, ResourceSaver.FLAG_OMIT_EDITOR_PROPERTIES)
	if error == OK:
		print("[Success] 'app_data.tres' saved successfully.")
	else:
		print("[Error] Couldn't save 'app_data.tres'. Reason: " + error_string(error))
		
