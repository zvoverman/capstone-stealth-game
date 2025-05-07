extends Node

var music_player : AudioStreamPlayer
var theme : AudioStreamWAV = preload("res://audio/SpiderTheme.wav")

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.volume_db = -16.0
	music_player.finished.connect(_music_player_finished)

func play_theme():
	music_player.stream = theme
	music_player.play(0.0)

func _music_player_finished():
	music_player.play(0.0)
