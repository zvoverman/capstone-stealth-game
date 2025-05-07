extends Area3D

signal player_died

func _ready() -> void:
	connect("body_entered", _body_entered)
	player_died.connect(GameManager._on_player_died)
	
func _body_entered(body) -> void:
	if body.name == "PlayerDrone":
		body.player_death_sequence()
