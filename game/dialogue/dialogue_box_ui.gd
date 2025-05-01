class_name DialogueBoxUI extends Control

@export var _label : Label

func display_text(text : String):
	_label.text = text
	
func clear():
	_label.text = ""
