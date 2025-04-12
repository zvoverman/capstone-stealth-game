extends Node

@export var tooltip_text_ui : RichTextLabel

# Keep track of which cams are currently detecting the player
var detected_cams : Array[int] = []

# List of clearance keys the player has collected
var keys = {
	"green": false,
	"blue": false,
	"red": false
}

# List of power ups the player has collected
var power_ups = {}

var player : CharacterBody3D = null
var spawn_node : Node3D = null

# Removes the current scene and loads a new level
func load_level(scene_path: String) -> Node:
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.queue_free()

	# Load and instantiate the new scene
	var new_scene = load(scene_path).instantiate()
	get_tree().root.add_child.call_deferred(new_scene)
	await get_tree().process_frame # Wait for scene to finish setup
	get_tree().current_scene = new_scene  # Set as current so pause, etc. work properly
	return new_scene

# Loads a specified scene path, finds InitialSpawnPoint, and spawns the player there
func start_game(scene_path: String, player_scene_path: String):
	var level_root = await load_level(scene_path)
	
	var spawn_point = level_root.get_node("Checkpoints/InitialSpawnPoint")
	if spawn_point == null:
		push_warning("No spawn point named 'InitialSpawnPoint' found in scene.")
		return
		
	# Initiate and spawn player
	var player_resource = load(player_scene_path)
	player = player_resource.instantiate()
	get_tree().current_scene.add_child(player)
	player.set_jump_power_up(true)

	player.respawn(spawn_point.transform)
	

func _ready() -> void:
	start_game("res://scenes/test_levels/test_environment.tscn", "res://player/player_drone.tscn")
	#start_game("res://scenes/levels/game/game.tscn", "res://player/player_drone.tscn")


func _process(_delta: float) -> void:
	if not player: return
	
	if detected_cams.size() > 0:
		player.is_detected = true
	else:
		player.is_detected = false
	
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
