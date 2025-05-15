#extends Interactable
extends Collectable

class_name PlayerAbility

enum PlayerAbilityType {
	JUMP,
	DASH,
	BALL,
	GRAPPLE
}

@export var ability_type : PlayerAbilityType
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var mesh : MeshInstance3D = $Mesh

signal grab_ability(ability: PlayerAbilityType)

func _ready():
	grab_ability.connect(GameManager._on_grab_ability)
	animation_player.play("collectable_float_anim")
	

#func interact() -> void:
	#super()
	#match ability_type:
		#PlayerAbilityType.JUMP:
			#pickup_ability()
		#_:
			#print("No ability type given.")
			
func collect() -> void:
	super()
	match ability_type:
		PlayerAbilityType.JUMP:
			pickup_ability()
		_:
			print("No ability type given.")

func pickup_ability() -> void:
	grab_ability.emit(ability_type)
	queue_free()
	
func focus() -> void:
	mesh.get_active_material(0).next_pass.next_pass.set_shader_parameter("use_outline", 1)
	
func unfocus() -> void:
	mesh.get_active_material(0).next_pass.next_pass.set_shader_parameter("use_outline", 0)


func _on_collectable_area_3d_body_entered(body: Node3D) -> void:
	collect()
