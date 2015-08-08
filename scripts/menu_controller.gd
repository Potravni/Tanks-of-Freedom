
var root
var control_nodes

var red_player_button
var red_player_button_label
var blue_player_button
var blue_player_button_label
var play_button
var close_button
var demo_button
var quit_button

var main_menu
var settings
var menu_button
var settings_button
var campaign_button

var label_completed
var label_wins
var label_maps_created
var label_version

var maps_sub_menu = preload("res://gui/menu_maps.xscn").instance()
var maps_play_custom_button
var maps_close_button
var maps_turns_cap
var maps_turns_cap_label
var maps_select_custom_map
var workshop_button
var workshop

var sound_toggle_button
var music_toggle_button
var shake_toggle_button
var camera_follow_button
var camera_zoom_in_button
var camera_zoom_out_button

var sound_toggle_label
var music_toggle_label
var shake_toggle_label
var camera_follow_label
var camera_zoom_label

var background_map
var root_tree

func _ready():
	self.control_nodes = [self.get_node("top"),self.get_node("middle"),self.get_node("bottom")]

	workshop_button = get_node("bottom/center/workshop")

	campaign_button = get_node("bottom/center/start_campaign")

	play_button = get_node("bottom/center/play")
	close_button = get_node("top/center/close")
	quit_button = get_node("bottom/center/quit")
	demo_button = get_node("bottom/center/demo")

	main_menu = get_node("middle/center/game_panel")
	settings = get_node("middle/center/settings_panel")

	menu_button = get_node("top/center/main_menu")
	settings_button = get_node("top/center/settings")

	sound_toggle_button = settings.get_node("sound_toggle")
	music_toggle_button = settings.get_node("music_toggle")
	shake_toggle_button = settings.get_node("shake_toggle")
	camera_follow_button = settings.get_node("camera_follow")
	camera_zoom_in_button = settings.get_node("camera_zoom_in")
	camera_zoom_out_button = settings.get_node("camera_zoom_out")

	sound_toggle_label = sound_toggle_button.get_node("Label")
	music_toggle_label = music_toggle_button.get_node("Label")
	shake_toggle_label = shake_toggle_button.get_node("Label")
	camera_follow_label = camera_follow_button.get_node("Label")
	camera_zoom_label = settings.get_node("camera_zoom_level")

	campaign_button.connect("pressed", self, "show_campaign_menu")
	workshop_button.connect("pressed", self, "enter_workshop")
	play_button.connect("pressed", self, "show_maps_menu")

	sound_toggle_button.connect("pressed", self, "toggle_sound")
	music_toggle_button.connect("pressed", self, "toggle_music")
	shake_toggle_button.connect("pressed", self, "toggle_shake")
	camera_follow_button.connect("pressed", self, "toggle_follow")
	camera_zoom_in_button.connect("pressed", self.root.dependency_container.camera, "camera_zoom_in")
	camera_zoom_out_button.connect("pressed", self.root.dependency_container.camera, "camera_zoom_out")

	close_button.connect("pressed", root, "toggle_menu")
	quit_button.connect("pressed", self, "quit_game")
	menu_button.connect("pressed", self, "show_main_menu")
	settings_button.connect("pressed", self, "show_settings")
	demo_button.connect("pressed", self, "start_demo_mode")

	self.label_completed = self.get_node("bottom/center/completed")
	self.label_maps_created = self.get_node("bottom/center//maps_created")
	self.label_version = self.get_node("middle/center/game_panel/copy")

	self.refresh_buttons_labels()
	self.load_maps_menu()
	self.load_workshop()

	blue_player_button = maps_sub_menu.get_node("control/menu_controls/blue_player")
	blue_player_button_label = blue_player_button.get_node("Label")
	red_player_button = maps_sub_menu.get_node("control/menu_controls/red_player")
	red_player_button_label = red_player_button.get_node("Label")

	blue_player_button.connect("pressed", self, "toggle_player", [0])
	red_player_button.connect("pressed", self, "toggle_player", [1])

	self.update_progress_labels()
	self.update_version_label()
	self.update_zoom_label()
	self.load_background_map()

func start_demo_mode():
	self.root.dependency_container.demo_mode.start_demo_mode(false)

func load_maps_menu():
	maps_sub_menu.hide()
	self.add_child(maps_sub_menu)

	maps_play_custom_button = maps_sub_menu.get_node("control/menu_controls/play_custom")
	maps_close_button = maps_sub_menu.get_node("control/menu_controls/close")
	maps_turns_cap = maps_sub_menu.get_node("control/menu_controls/turns_cap")
	maps_turns_cap_label = maps_turns_cap.get_node("Label")
	maps_select_custom_map = maps_sub_menu.get_node("control/menu_controls/custom_maps")

	self.load_custom_maps_list(maps_select_custom_map)

	maps_play_custom_button.connect("pressed", self, "load_map_from_list", [maps_select_custom_map, true])
	maps_close_button.connect("pressed", self, "hide_maps_menu")
	maps_turns_cap.connect("pressed", self, "toggle_turns_cap")

func load_custom_maps_list(dropdown):
	var map_list = root.dependency_container.map_list.maps

	for map in map_list:
		dropdown.add_item(map)

func refresh_custom_maps_list():
	self.maps_select_custom_map.clear()
	self.load_custom_maps_list(self.maps_select_custom_map)

func show_campaign_menu():
	self.root.dependency_container.controllers.campaign_menu_controller.show_campaign_menu()
	self.hide_control_nodes()

func show_maps_menu():
	self.refresh_custom_maps_list()
	self.hide_control_nodes()
	self.reset_player_buttons()
	self.maps_sub_menu.show()

func show_control_nodes():
	for nod in self.control_nodes:
		nod.show()

func hide_control_nodes():
	for nod in self.control_nodes:
		nod.hide()

func hide_maps_menu():
	self.show_control_nodes()
	maps_sub_menu.hide()

func show_main_menu():
	main_menu.show()
	settings.hide()

func show_settings():
	main_menu.hide()
	settings.show()

func load_workshop():
	self.workshop = self.root.dependency_container.workshop

func enter_workshop():
	self.root.unload_map()
	self.workshop.is_working = true
	self.workshop.is_suspended = false
	self.show_workshop()

func show_workshop():
	self.hide()
	self.root.toggle_menu()
	self.workshop.show()
	self.workshop.units.raise()
	self.hide_background_map()

func hide_workshop():
	self.workshop.hide()
	self.show()
	if not self.root.is_map_loaded:
		self.show_background_map()

func toggle_player(player):
	root.settings['cpu_' + str(player)] = not root.settings['cpu_' + str(player)]
	self.set_player_button_state(player)

func set_player_button_state(player):
	var label
	if root.settings['cpu_' + str(player)]:
		label = "CPU"
	else:
		label = "HUMAN"

	if player == 0:
		blue_player_button_label.set_text(label)
	else:
		red_player_button_label.set_text(label)

func reset_player_buttons():
	self.set_player_button_state(0)
	self.set_player_button_state(1)

func load_map_from_list(list, from_workshop):
	var map_identifier
	if from_workshop:
		map_identifier = list.get_item_text(list.get_selected())
	else:
		map_identifier = list.get_selected()
	self.load_map(map_identifier, from_workshop)

func load_map(name, from_workshop):
	if from_workshop:
		root.load_map('workshop', name)
	else:
		root.load_map(name, false)
	root.toggle_menu()
	self.hide_maps_menu()
	workshop.hide()
	workshop.is_working = false
	workshop.is_suspended = true

func toggle_sound():
	root.settings['sound_enabled'] = not root.settings['sound_enabled']
	self.refresh_buttons_labels()
	root.write_settings_to_file()

func toggle_music():
	root.settings['music_enabled'] = not root.settings['music_enabled']
	if root.settings['music_enabled']:
		root.sound_controller.play_soundtrack()
	else:
		root.sound_controller.stop_soundtrack()
	self.refresh_buttons_labels()
	root.write_settings_to_file()

func toggle_shake():
	root.settings['shake_enabled'] = not root.settings['shake_enabled']
	if root.settings['shake_enabled']:
		shake_toggle_label.set_text("ON")
	else:
		shake_toggle_label.set_text("OFF")
	root.write_settings_to_file()

func toggle_follow():
	root.settings['camera_follow'] = not root.settings['camera_follow']
	if root.settings['camera_follow']:
		camera_follow_label.set_text("ON")
	else:
		camera_follow_label.set_text("OFF")
	root.write_settings_to_file()

func refresh_buttons_labels():
	if root.settings['sound_enabled']:
		sound_toggle_label.set_text("ON")
	else:
		sound_toggle_label.set_text("OFF")
	if root.settings['music_enabled']:
		music_toggle_label.set_text("ON")
	else:
		music_toggle_label.set_text("OFF")
	if root.settings['shake_enabled']:
		shake_toggle_label.set_text("ON")
	else:
		shake_toggle_label.set_text("OFF")
	if root.settings['camera_follow']:
		camera_follow_label.set_text("ON")
	else:
		camera_follow_label.set_text("OFF")

func quit_game():
	OS.get_main_loop().quit()

func toggle_turns_cap():
	var turns_cap_modifer = 25

	if root.settings['turns_cap'] >= 100:
		root.settings['turns_cap'] = 0
	else:
		root.settings['turns_cap'] = root.settings['turns_cap'] + turns_cap_modifer
	self.adjust_turns_cap_label()

func adjust_turns_cap_label():
	if root.settings['turns_cap'] > 0:
		maps_turns_cap_label.set_text(str(root.settings['turns_cap']))
	else:
		maps_turns_cap_label.set_text("OFF")

func update_zoom_label():
	self.camera_zoom_label.set_text(str(self.root.scale_root.get_scale().x))

func update_progress_labels():
	self.update_custom_maps_count_label()
	self.update_campaign_progress_label()

func update_custom_maps_count_label():
	var maps_created = self.root.dependency_container.map_list.maps.size()
	self.label_maps_created.set_text("MAPS CREATED: " + str(maps_created))

func update_campaign_progress_label():
	var completed_maps = self.root.dependency_container.campaign.get_completed_map_count()
	var total_maps = self.root.dependency_container.campaign.maps.size()
	self.label_completed.set_text("COMPLETED: " + str(completed_maps) + "/" + str(total_maps))

func update_version_label():
	self.label_version.set_text(self.root.version_name)

func init_root(root_node):
	root = root_node
	self.root_tree = self.root.get_tree()

func load_background_map():
	self.background_map = self.root.map_template.instance()
	self.background_map.is_dead = true
	self.background_map.get_node('terrain').set_tileset(self.root.main_tileset)
	self.background_map.fill_map_from_data_array(self.root.dependency_container.menu_background_map.map_data)
	self.background_map.show_blueprint = false
	self.root.scale_root.add_child(self.background_map)
	self.flush_group("units")
	self.flush_group("buildings")
	self.flush_group("terrain")
	self.update_background_scale()

func flush_group(name):
	var collection = self.root_tree.get_nodes_in_group(name)
	for entity in collection:
		entity.remove_from_group(name)

func show_background_map():
	if self.background_map != null:
		self.background_map.show()

func hide_background_map():
	if self.background_map != null:
		self.background_map.hide()

func update_background_scale():
	if self.background_map != null:
		self.background_map.scale = self.root.scale_root.get_scale()
		self.background_map.set_map_pos(Vector2(20, 20))

