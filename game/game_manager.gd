extends Node

@export var tooltip_text_ui : RichTextLabel

var detected_cams : Array[int] = []

@export var spawn_node : Node3D

var keys = {
	"green": false,
	"blue": false,
	"red": false
}

var player_scene = preload("res://player/player_drone.tscn")
var player : CharacterBody3D = null

# Spawns the player and begins the game
# TODO: need to pick and instantiate chosen scene
func start_game():
	player = player_scene.instantiate()
	get_tree().current_scene.add_child(player)
	player.respawn(spawn_node.transform)

func _ready() -> void:
	#set_jump_power_up(true)
	
	var scene = get_tree().current_scene
	spawn_node = scene.get_node("InitialSpawnPoint")
	
	start_game()
	
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
	print("add")
	
func _on_remove_detection(instance_id: int):
	detected_cams.erase(instance_id)
	print("remove")
	
func _on_player_died():
	player.respawn(spawn_node.transform)
	
func _on_game_paused():
	print("Game paused")
	
func update_settings():
	print("Update settings")
