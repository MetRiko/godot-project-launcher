extends MarginContainer

const stylebox_editor_entry_normal := preload("res://src/ui/editors_tab/editor_entry_normal.tres") 
const stylebox_editor_entry_hovered := preload("res://src/ui/editors_tab/editor_entry_hovered.tres") 
const stylebox_editor_entry_focused := preload("res://src/ui/editors_tab/editor_entry_focused.tres") 
const stylebox_editor_name_normal := preload("res://src/ui/editors_tab/editor_name_normal.tres") 
const stylebox_editor_name_hovered := preload("res://src/ui/editors_tab/editor_name_hovered.tres") 

@export var name_label : Label
@export var back_panel : Panel
#@onready var back_panel : Panel = $Back

var hovered := false

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
