extends Node3D

class_name Tooltip

@export var message : String
@export var delay: float = 3.0

@onready var collision_area : Area3D = $Area3D
@onready var label: Label = $Label

signal checkpoint_entered(node: Node3D)

var should_display: bool = false
var disabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.visible_ratio = 0.0
	label.text = message
	collision_area.connect("body_entered", _on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (should_display):
		label.visible_ratio = lerpf(label.visible_ratio, 1.0, 0.1)
	elif label.visible_ratio != 0.0:
		label.visible_ratio = lerpf(label.visible_ratio, 0.0, 0.1)


func _on_body_entered(body: Node3D) -> void:
	if body.name == "PlayerDrone" && not disabled:
		await get_tree().create_timer(delay).timeout
		should_display = true
		await get_tree().create_timer(5.0).timeout
		should_display = false
		disabled = true
