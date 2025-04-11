extends Node

@export var tooltip_text_ui : RichTextLabel

var detected_cams : Array[int] = []

var keys = {
	"green": false,
	"blue": false,
	"red": false
}

var player : CharacterBody3D = null
var spawn_node : Node3D = null 

# Spawns the player and begins the game
func start_game(scene_path: String, player_scene_path: String):
	# Load the new scene
	var scene_resource = load(scene_path)
	if scene_resource == null:
		push_error("Failed to load scene: " + scene_path)
		return

	var new_scene = scene_resource.instantiate()
	if new_scene == null:
		push_error("Failed to instantiate scene.")
		return

	## Remove the current scene
	#var current_scene = get_tree().current_scene
	#if current_scene:
		#current_scene.queue_free()

	# Add the new scene to the scene tree
	get_tree().root.add_child.call_deferred(new_scene)
	get_tree().current_scene = new_scene
	
	var player_resource = load(player_scene_path)
	player = player_resource.instantiate()
	get_tree().current_scene.add_child(player)
	player.set_jump_power_up(true)
	
	var spawn_point = new_scene.get_node_or_null("InitialSpawnPoint")
	if spawn_point == null:
		push_warning("No spawn point named 'InitialSpawnPoint' found in scene.")
		return

	player.respawn(spawn_point.transform)
	

func _ready() -> void:
	#set_jump_power_up(true)
	
	var scene = get_tree().current_scene
	spawn_node = scene.get_node("Checkpoints/InitialSpawnPoint")
	
	#start_game("res://scenes/test_levels/test_environment.tscn", "res://player/player_drone.tscn")
	start_game("res://scenes/levels/game/game.tscn", "res://player/player_drone.tscn")
	#tooltip_text_ui.visible_ratio = 0.0
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not player: return
	
	#print(player)
	if detected_cams.size() > 0:
		player.is_detected = true
	else:
		player.is_detected = false

## @deprecated: now Signal _on_add_detection
func add_detection(cam_id : float):
	detected_cams.append(cam_id)

## @deprecated: now Signal _on_remove_detection
func remove_detection(cam_id : float):
	detected_cams.erase(cam_id)

## @deprecated 
#func respawn() -> void:
	#player.respawn(spawn_node.transform)
	
func set_jump_power_up(flag: bool) -> void:
	player.jump_power_up = flag
	var tooltip_str = "[center]You have picked up a power up. Press SPACE to jump."
	set_tooltip_text(tooltip_str)
	
func set_key(key_color: String) -> void:
	if keys.has(key_color):
		keys[key_color] = true
		print("Player now has the " + key_color + " key.")
		var tooltip_str = "[center]You have picked up a " + key_color + " key";
		set_tooltip_text(tooltip_str)	
	else:
		print("Invalid key color!")
		
func set_tooltip_text(text: String) -> void:
	tooltip_text_ui.text = text
	tooltip_text_ui.visible_ratio = 1.0 
	await get_tree().create_timer(5.0).timeout
	tooltip_text_ui.visible_ratio = 0.0
	
func _on_add_detection(instance_id: int):
	detected_cams.append(instance_id)
	
func _on_remove_detection(instance_id: int):
	detected_cams.erase(instance_id)
	
func _on_player_died():
	player.respawn(spawn_node.transform)
	
func _on_game_paused():
	print("Game paused")
	
func update_settings():
	print("Update settings")
