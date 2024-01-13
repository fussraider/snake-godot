class_name Game
extends Node2D

@onready var player: Snake = $Snake
@onready var playingArea: PlayingArea = $PlayingArea


func _ready() -> void:
	playingArea.apple_hit.connect(player.handle_apple_hit)
	playingArea.wall_hit.connect(on_playing_area_wall_hit)


func on_playing_area_wall_hit() -> void:
	# так, потому что иначе может быть ошибка, что нельзя вызывать рестарт 
	# сцен пока она не доконц обработана или типа того. А так метод вызовится 
	# когда закончтся обработка текущего кадра
	call_deferred("game_over")

func game_over() -> void:
	get_tree().reload_current_scene()
