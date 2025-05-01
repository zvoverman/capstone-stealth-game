extends Interactable

class_name NonPersonCharacter

@export var dialogue_sequence : DialogueSequence
@export var dialogue_box : DialogueBox
@export var mesh : MeshInstance3D

var _in_dialogue : bool = false
	
func interact() -> void:
	super()
	
	if not _in_dialogue:
		_in_dialogue = dialogue_box.begin_dialogue(dialogue_sequence)
	else:
		_in_dialogue = dialogue_box.continue_dialogue()

func focus() -> void:
	mesh.get_active_material(0).next_pass.set_shader_parameter("use_outline", 1)
	
func unfocus() -> void:
	mesh.get_active_material(0).next_pass.set_shader_parameter("use_outline", 0)
