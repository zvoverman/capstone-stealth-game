extends CSGCylinder3D

var dissolve_material: ShaderMaterial
@export var dissolve_color: Color = Color(1, 0.5, 0.0) # You can adjust this
@export var dissolve_speed: float = 1.0

var tween: Tween

func _ready() -> void:
	# Ensure the next_pass is a ShaderMaterial
	var base_material = self.get_material()
	if base_material:
		dissolve_material = base_material
		dissolve_material.set_shader_parameter("dissolve_amount", 0.0)
		dissolve_material.set_shader_parameter("glow_color", dissolve_color)
	else:
		push_error("No valid next_pass ShaderMaterial found!")
		
	await get_tree().create_timer(11.0).timeout
	trigger_dissolve()
	await get_tree().create_timer(3.0).timeout
	trigger_reform()

func trigger_dissolve() -> void:
	dissolve_material.set_shader_parameter("glow_color", dissolve_color)

	tween = create_tween()
	tween.tween_property(dissolve_material, "shader_parameter/dissolve_amount", 1.0, dissolve_speed)
	tween.tween_callback(Callable(self, "on_dissolve_complete"))

func trigger_reform() -> void:
	# Instantly restore the material to normal
	dissolve_material.set_shader_parameter("dissolve_amount", 0.0)
	self.visible = true

func on_dissolve_complete() -> void:
	self.visible = false
