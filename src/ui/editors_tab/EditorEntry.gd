extends MarginContainer

const stylebox_editor_entry_normal := preload("res://src/ui/editors_tab/editor_entry_normal.tres") 
const stylebox_editor_entry_hovered := preload("res://src/ui/editors_tab/editor_entry_hovered.tres") 
const stylebox_editor_entry_focused := preload("res://src/ui/editors_tab/editor_entry_focused.tres") 
const stylebox_editor_name_normal := preload("res://src/ui/editors_tab/editor_name_normal.tres") 
const stylebox_editor_name_hovered := preload("res://src/ui/editors_tab/editor_name_hovered.tres") 
const labelstyle_editor_name_error := preload("res://src/ui/editors_tab/editor_name_error.tres")
const labelstyle_editor_path_error := preload("res://src/ui/editors_tab/editor_path_error.tres")

@export var name_label : Label
@export var path_label : Label
@export var back_panel : Panel

#@export_category("tags")
@export var alert_icon : Control
@export var mono_tag : Control
@export var stable_tag : Control
@export var dev_tag : Control
@export var custom_tag : Control

#@onready var back_panel : Panel = $Back

var editor_data : GodotEditorFile = null

var hovered := false

func set_editor_data(data : GodotEditorFile) -> void:
	editor_data = data
	if data.is_editor_executable_valid():
		_switch_to_valid_state(data)
	else:
		_switch_to_error_state(data)

func _switch_to_valid_state(data : GodotEditorFile) -> void:
	alert_icon.visible = false
	name_label.label_settings = null
	path_label.label_settings = null
	mono_tag.visible = data.mono_support
	stable_tag.visible = data.is_official() and data.is_stable()
	dev_tag.visible = data.is_official() and not data.is_stable()
	custom_tag.visible = not data.is_official()
		
	var display_name := data.get_display_name()
	name_label.text = display_name
	var path := data.get_editor_executable_path()
	path_label.text = path
	
	var codename := data.get_detailed_name()
	var tooltip := "%s\n\n%s\n%s" % [display_name, codename, path]
	tooltip_text = tooltip
	
func _switch_to_error_state(data : GodotEditorFile) -> void:
	alert_icon.visible = true
	name_label.label_settings = labelstyle_editor_name_error
	path_label.label_settings = labelstyle_editor_path_error
	mono_tag.visible = false
	stable_tag.visible = false
	dev_tag.visible = false
	custom_tag.visible = false
	
	var display_name := data.get_display_name()
	name_label.text = display_name
	var path := data.get_editor_executable_path()
	path_label.text = path
	
	var codename := data.get_detailed_name()
	var error_msg := ""
	match data.latest_error:
		GodotEditorFile.EditorLoadingError.INVALID_FILE:
			error_msg = "[Error] File not recognized as a Godot executable."
		GodotEditorFile.EditorLoadingError.FILE_NOT_EXIST:
			error_msg = "[Error] File not found."
		GodotEditorFile.EditorLoadingError.UNKNOWN_VERSION:
			error_msg = "[Error] File not recognized as a godot executable.\nUnexpected Godot --version format."
	var tooltip := "%s\n%s\n\n%s\n%s" % [display_name, error_msg, codename, path]
	tooltip_text = tooltip
	
func _ready():
	_mouse_exited()
	focus_entered.connect(_focus_entered)
	focus_exited.connect(_focus_exited)
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	tooltip_text = $MarginContainer/EditorEntry/Path.text
	
func _set_back_theme(stylebox : StyleBox):
	back_panel.add_theme_stylebox_override("panel", stylebox)
	
func _set_name_theme(stylebox : StyleBox):
	name_label.add_theme_stylebox_override("normal", stylebox)
	
func _switch_to_normal():
	var is_focused := get_viewport().gui_get_focus_owner() == self
	_set_back_theme(stylebox_editor_entry_focused if is_focused else stylebox_editor_entry_normal)
	_set_name_theme(stylebox_editor_name_hovered if is_focused else stylebox_editor_name_normal)
	
func _switch_to_hovered():
	var is_focused := get_viewport().gui_get_focus_owner() == self
	_set_back_theme(stylebox_editor_entry_focused if is_focused else stylebox_editor_entry_hovered)
	_set_name_theme(stylebox_editor_name_hovered if is_focused or hovered else stylebox_editor_name_normal)

func _mouse_entered():
	hovered = true
	_switch_to_hovered()
	
func _mouse_exited():
	hovered = false
	_switch_to_normal()
	
func _focus_entered():
	_switch_to_normal()
	
func _focus_exited():
	if hovered:
		_switch_to_hovered()
	else:
		_switch_to_normal()
