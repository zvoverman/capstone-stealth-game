extends Node3D

class_name Tooltip

@export var message : String

@onready var collision_area : Area3D = $Area3D
@onready var label: Label = $Label

signal checkpoint_entered(node: Node3D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_area.connect("body_entered", _on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.name == "PlayerDrone" && body.can_move:
		print(body)
		label.text = message
		await get_tree().create_timer(1.0).timeout
		label.visible_ratio = 0.0
		label.text = ''
