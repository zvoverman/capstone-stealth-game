extends Interactable

class_name NonPersonCharacter

@export var sequence : DialogueSequence

## FIXME: THIS IS TEMPORARY. Text should be displayed in UI.
@onready var temp_label: Label3D = $Label

signal on_start_sequence(sequence: DialogueSequence, label: Label3D)

func _ready():
	on_start_sequence.connect(DialogueManager._on_start_sequence)
	
func interact() -> void:
	super()
	on_start_sequence.emit(sequence, temp_label)
