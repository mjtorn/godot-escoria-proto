extends Control

var background = null
export var expected_ingame_buttons = ["inv_toggle", "buttons", "buttons/hints", "buttons/menu"]

func set_tooltip(text):
	printt("hud got tooltip text ", text)
	get_node("tooltip").set_text(text)

func inv_toggle():
	#get_node("inventory").toggle()
	pass


func _on_inv_toggle_vis_chaged():
	if (get_node("inv_toggle").is_hidden()):
		get_node("buttons").hide()
	else:
		get_node("buttons").show()

func _on_hint_pressed():
	printt("hint pressed")
	if background != null:
		background.emit_right_click()

func _on_menu_pressed():
	printt("menu pressed")
	if vm.can_save() && vm.can_interact() && vm.menu_enabled():
		main.load_menu("res://game/ui/main_menu.xml")
	else:
		#get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFAULT, "game", "ui_blocked")
		if vm.menu_enabled():
			main.load_menu(ProjectSettings.get_setting("escoria/ui/in_game_menu"))
		else:
			get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFAULT, "game", "ui_blocked")


func menu_opened():
	hide()

func menu_closed():
	show()

func _ready():
	add_to_group("hud")
	add_to_group("game")

	if ProjectSettings.get_setting("escoria/platform/show_ingame_buttons"):
		var good_ingame_buttons = true
		for expected_ingame_button in expected_ingame_buttons:
			if !get_node(expected_ingame_button):
				vm.report_errors("hud.gd", ["show_ingame_buttons with no " + expected_ingame_button])
				good_ingame_buttons = false

		if good_ingame_buttons:
			get_node("buttons").hide()

			if (not get_node("inv_toggle").is_hidden()):
					get_node("buttons").show()

			get_node("inv_toggle").connect("visibility_changed",self,"_on_inv_toggle_vis_chaged")
			get_node("inv_toggle").connect("pressed", self, "inv_toggle")
			get_node("inv_toggle").set_focus_mode(Control.FOCUS_NONE)
			get_node("buttons/hints").connect("pressed",self,"_on_hint_pressed")
			get_node("buttons/menu").connect("pressed",self,"_on_menu_pressed")

		var p = get_parent().get_parent().get_parent()
		for i in range(0, p.get_child_count()):
			var c = p.get_child(i)
			if (c is preload("res://globals/background.gd")):
				background = c
				break

	set_tooltip("")

