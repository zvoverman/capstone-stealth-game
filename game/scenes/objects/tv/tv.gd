extends Node3D

@export var dialogue_box : DialogueBox
@export var dialogue : DialogueSequence

func _ready() -> void:
	
	if dialogue == null:
		return
	
	await get_tree().create_timer(1.0).timeout
	dialogue_box.begin_dialogue(dialogue)
	
	while true:
		await get_tree().create_timer(3.0).timeout
		if not dialogue_box.continue_dialogue():
			dialogue_box.begin_dialogue(dialogue)
