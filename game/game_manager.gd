extends Node

class_name GameManager

@export var player : CharacterBody3D
@export var tooltip_text_ui : RichTextLabel

var detected_cams : Array[float] = []

var spawn_transform : Transform3D

var keys = {
	"green": false ,
	"blue": false,
	"red": false
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_transform = player.global_transform
	set_jump_power_up(false)
	
	tooltip_text_ui.visible_ratio = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if detected_cams.size() > 0:
		player.is_detected = true
	else:
		player.is_detected = false
	
func add_detection(cam_id : float):
	detected_cams.append(cam_id)
	
func remove_detection(cam_id : float):
	detected_cams.erase(cam_id)
	
func respawn() -> void:
	player.global_transform = spawn_transform
	player
	
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
	
