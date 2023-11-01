extends LineEdit
class_name LineEditForPath

signal path_changed(path : String)

var unallowed_characters_rgx := RegEx.new()

func _ready():
	unallowed_characters_rgx.compile(r'[*?"<>|]')
	text_changed.connect(_on_text_changed)
	
func set_path(new_text : String) -> void:
	var original_text := new_text
	var caret_pos := caret_column
	var scroll_pos_before := get_scroll_offset()
	var was_empty := text == ""
	new_text = new_text.strip_edges()
	new_text = new_text.replace('\\', '/')
	new_text = unallowed_characters_rgx.sub(new_text, '', true)
	var diff := original_text.length() - new_text.length()
	if diff == 1:
		delete_char_at_caret()
	elif diff == 0:
		text = new_text
		caret_column = caret_pos
	else:
		text = new_text
		caret_column = caret_pos
		
	if was_empty:
		caret_column = new_text.length()
	
func _on_text_changed(new_text : String) -> void:
	set_path(new_text)
	path_changed.emit(text)
