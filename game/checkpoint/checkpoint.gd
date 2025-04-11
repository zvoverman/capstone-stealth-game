extends Marker3D

class_name Checkpoint

@export var game_manager : GameManager

@export var spawn_name : String

@onready var collision_area : Marker3D = $Area3D

# TODO: FIX CHECKPOINTS!

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#collision_area.connect("body_entered", _on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		#game_manager.spawn_node = spawn_point
		#game_manager.set_tooltip_text("[center]" + spawn_name)
		print("Player in checkpoint area: " + spawn_name)
