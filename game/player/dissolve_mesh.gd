extends MeshInstance3D

@export var dissolve_color: Color = "#ff7349"
@export var reform_color: Color = "#4ad2ff"

var dissolve_amount = 0.0
var dissolve_speed = 0.5
var dissolve_material: ShaderMaterial

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dissolve_material = get_surface_override_material(0) as ShaderMaterial
	dissolve_material.set_shader_parameter("dissolve_amount", 0.0)

func trigger_dissolve() -> void:
	dissolve_material.set_shader_parameter("glow_color", dissolve_color)
	
	tween = create_tween()
	tween.tween_property(dissolve_material, "shader_parameter/dissolve_amount", 1.0, dissolve_speed)
	tween.tween_callback(on_dissolve_complete)

func trigger_reform() -> void:
	dissolve_material.set_shader_parameter("glow_color", reform_color)
	
	tween = create_tween()
	tween.tween_property(dissolve_material, "shader_parameter/dissolve_amount", 0.0, dissolve_speed)
	tween.tween_callback(on_dissolve_complete)
	
	
func on_dissolve_complete() -> void:
	pass
