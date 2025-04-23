extends Interactable

class_name NonPersonCharacter

@export var dialogue_sequence : DialogueSequence
@export var dialogue_box : DialogueBox

var _in_dialogue : bool = false
	
func interact() -> void:
	super()
	
	if not _in_dialogue:
		_in_dialogue = dialogue_box.begin_dialogue(dialogue_sequence)
	else:
		_in_dialogue = dialogue_box.continue_dialogue()
