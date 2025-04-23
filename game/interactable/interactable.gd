extends Node3D

class_name Interactable

func interact() -> void:
	print("Interacted with ", self.name)

# These should be overriden by subclasses of Interactable
func focus() -> void:
	pass
func unfocus() -> void:
	pass
