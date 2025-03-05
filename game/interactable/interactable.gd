extends Node3D

class_name Interactable

@export var interact_object : Node3D

var valid_input : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent):
	if event.is_action_pressed("interact") and valid_input:
		interact_object.interact()
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		valid_input = true
		
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		valid_input = false
