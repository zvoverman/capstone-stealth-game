class_name DialogueBox extends Sprite3D

@export var dialogue_box_ui : DialogueBoxUI

var current_sequence : DialogueSequence = null
var dialogue_index : int = -1

# Returns true if the dialogue box opened successfully, false otherwise
func begin_dialogue(dialogue_sequence : DialogueSequence) -> bool:
	
	if dialogue_sequence.lines.size() == 0:
		return false
	
	current_sequence = dialogue_sequence
	dialogue_index = 0
	
	visible = true
	dialogue_box_ui.display_text(current_sequence.lines[dialogue_index])
	return true

# Returns true if there was more dialogue to display, and false if not (menu closes)
func continue_dialogue() -> bool:
	
	if current_sequence == null:
		return false
	
	dialogue_index = dialogue_index + 1
	
	if dialogue_index >= current_sequence.lines.size():
		dialogue_box_ui.clear()
		visible = false
		return false
		
	dialogue_box_ui.display_text(current_sequence.lines[dialogue_index])
	return true

func _ready() -> void:
	dialogue_box_ui.clear()
	visible = false
