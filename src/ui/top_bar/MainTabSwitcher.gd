extends MarginContainer

signal tab_changed(tab_type : TabType)

@export var button_projects : Button
@export var button_editors : Button

enum TabType {
	None, Projects, Editors
}

var tab := TabType.Projects

func toggle_tab(tab_type : TabType):
	button_projects.button_pressed = tab_type == TabType.Projects
	button_editors.button_pressed = tab_type == TabType.Editors
	
	button_projects.custom_minimum_size.x = 105.0 if button_projects.button_pressed else 95.0
	button_editors.custom_minimum_size.x = 105.0 if button_editors.button_pressed else 95.0
	
	if tab != tab_type:
		tab = tab_type
		tab_changed.emit(tab)

func _ready():
	button_projects.pressed.connect(toggle_tab.bind(TabType.Projects))
	button_editors.pressed.connect(toggle_tab.bind(TabType.Editors))
	toggle_tab(tab)
