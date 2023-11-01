extends Control
class_name EditorsTab

const editor_entry_tscn := preload("res://src/ui/editors_tab/EditorEntry.tscn")

#var godot_editor_file : GodotEditorFile

@export var entries_node : VBoxContainer

func load_editors(editors : Array[GodotEditorFile]) -> void:
	clear()
	for editor in editors:
		var editor_path := editor.get_editor_executable_path()
		var godot_editor_file = GodotEditorFile.new()
		godot_editor_file.try_load_project(editor_path)
		var editor_entry := editor_entry_tscn.instantiate()
		entries_node.add_child(editor_entry)
		editor_entry.set_editor_data(godot_editor_file)
		
func clear():
	for c in entries_node.get_children():
		c.queue_free()
		entries_node.remove_child(c)

func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_SPACE:
			test()
			
func test():
	clear()
		
	var paths_to_test := [
		"F:/Dev/godot/beta/Godot_v4.0-beta12_mono_win64/Godot_v4.0-beta12_mono_win64.exe",
		"F:/Dev/godot/beta/Godot_v4.0-beta12_mono_win64/Godot_v4.0-beta12_mono_win64.ex",
		"F:/Dev/godot/beta/Godot_v4.0-beta12_mono_win64/Godot_v4.0-beta12_mono_win6.exe",
		"D:/Games/Minecraft/bin/TLauncher-MCL.exe",
		"F:/Dev/godot/Godot_v3.5.2-stable_mono_win64/Godot_v3.5.2-stable_mono_win64.exe",
		"F:/Dev/godot/beta/Godot_v4.2-dev5_win64.exe",
		"F:/Dev/godot/beta/Godot_v4.0-beta12_mono_win64/Godot_v4.0-beta12_mono_win64.exe",
		"F:/Job/DoomsdayParadise/doomsday-godot/bin/godot.windows.opt.tools.64.exe"
	]
	for exe_path in paths_to_test:
		var godot_editor_file = GodotEditorFile.new()
		godot_editor_file.try_load_project(exe_path)
		var editor_entry := editor_entry_tscn.instantiate()
		entries_node.add_child(editor_entry)
		editor_entry.set_editor_data(godot_editor_file)
		
		#if godot_editor_file.is_editor_executable_valid():
			#var display_name := godot_editor_file.get_display_name()
			#var detailed_name := godot_editor_file.get_detailed_name()
			#print(display_name)
			#print(detailed_name)
