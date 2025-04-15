extends Node

signal dialogue_opened
signal dialogue_closed
signal dialogue_spat(line: String)

@export var dialogue_sequence: DialogueSequence
var current_index := 0
var is_active := false

## FIXME: THIS IS TEMPORARY. Text should be displayed in UI separately
var label: Label3D = null

func start_sequence(sequence: DialogueSequence):
	dialogue_sequence = sequence
	current_index = 0
	is_active = true
	dialogue_opened.emit()
	_show_line()

func _show_line():
	if current_index >= dialogue_sequence.lines.size():
		_end_dialogue()
		return
	
	print(current_index)
	var line = dialogue_sequence.lines[current_index]
	dialogue_spat.emit(line)
	print("> " + line)
	if label:
		label.text = line

func _end_dialogue():
	print("[Dialogue Ended]")
	is_active = false
	current_index = 0
	dialogue_closed.emit()
		
func _on_start_sequence(sequence: DialogueSequence, temp_label: Label3D):
	if not is_active:
		label = temp_label
		start_sequence(sequence)
	else:
		current_index += 1
		_show_line()
