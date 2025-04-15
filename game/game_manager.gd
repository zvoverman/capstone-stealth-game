extends Node

#@export var tooltip_text_ui : RichTextLabel

const PlayerAbilityType = preload("res://interactable/player_ability/player_ability.gd").PlayerAbilityType
enum PlayerAbilityStatus {
	LOCKED,
	IN_TRANSIT,
	UNLOCKED
}

# Keep track of which cams are currently detecting the player
var detected_cams : Array[int] = []

# List of clearance keys the player has collected
var keys = {
	"green": false,
	"blue": false,
	"red": false
}

var ability_to_status: Dictionary # Dictionary[int: int] where keys = AbilityType, values = AbilityStatus

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
	
	spawn_node= level_root.get_node("Checkpoints/InitialSpawnPoint")
	if spawn_node == null:
		push_warning("No spawn point named 'InitialSpawnPoint' found in scene.")
		return
		
	# Initiate and spawn player
	var player_resource = load(player_scene_path)
	player = player_resource.instantiate()
	get_tree().current_scene.add_child(player)
	player.update_abilities(ability_to_status)

	player.respawn(spawn_node.transform)
	

func _ready() -> void:
	ability_to_status = {
		PlayerAbilityType.JUMP: PlayerAbilityStatus.LOCKED
	}
	
	
	## Test Environment Scene (ALL WORKING)
	start_game("res://scenes/test_levels/test_environment.tscn", "res://player/player_drone.tscn")
	
	## Old Game Scene (Checkpoints and Lever NOT working)
	#start_game("res://scenes/levels/game/game.tscn", "res://player/player_drone.tscn")


func _process(_delta: float) -> void:
	if not player: return
	
	if detected_cams.size() > 0:
		player.is_detected = true
	else:
		player.is_detected = false
	
func set_key(key_color: String) -> void:
	if keys.has(key_color):
		keys[key_color] = true
		print("Player now has the " + key_color + " key.")
		var tooltip_str = "[center]You have picked up a " + key_color + " key";
		#set_tooltip_text(tooltip_str)	
	else:
		print("Invalid key color!")

## potentially @deprecated
#func set_tooltip_text(text: String) -> void:
	#tooltip_text_ui.text = text
	#tooltip_text_ui.visible_ratio = 1.0 
	#await get_tree().create_timer(5.0).timeout
	#tooltip_text_ui.visible_ratio = 0.0
	
func _on_add_detection(instance_id: int):
	detected_cams.append(instance_id)
	
func _on_remove_detection(instance_id: int):
	detected_cams.erase(instance_id)
	
func _on_player_died():
	player.respawn(spawn_node.transform)
	
func _on_game_paused():
	print("Game paused")
	
func _on_grab_ability(ability: PlayerAbilityType):
	# TODO: Once NPC has been implemented, this should set ability->status to IN_TRANSIT
	ability_to_status[ability] = PlayerAbilityStatus.UNLOCKED
	player.update_abilities(ability_to_status)
