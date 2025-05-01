extends Interactable

class_name PlayerAbility

enum PlayerAbilityType {
	JUMP
}

@export var ability_type : PlayerAbilityType

signal grab_ability(ability: PlayerAbilityType)

func _ready():
	grab_ability.connect(GameManager._on_grab_ability)

func interact() -> void:
	super()
	match ability_type:
		PlayerAbilityType.JUMP:
			pickup_ability()
		_:
			print("No ability type given.")

func pickup_ability() -> void:
	grab_ability.emit(ability_type)
	queue_free()
