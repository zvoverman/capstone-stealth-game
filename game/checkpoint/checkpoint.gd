extends Marker3D

class_name Checkpoint

@export var spawn_name : String

@onready var collision_area : Area3D = $Area3D

# TODO: FIX CHECKPOINTS!

signal checkpoint_entered(node: Node3D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_area.connect("body_entered", _on_body_entered)
	checkpoint_entered.connect(GameManager._on_checkpoint_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.name == "PlayerDrone":
		checkpoint_entered.emit(self)
