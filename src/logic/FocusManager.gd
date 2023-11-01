extends Node

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			_release_if_mouse_outside()
			
func _release_if_mouse_outside():
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner != null:
		var pos := focus_owner.get_global_mouse_position()
		var is_hovered := focus_owner.get_global_rect().has_point(pos)
		if not is_hovered:
			focus_owner.release_focus()
