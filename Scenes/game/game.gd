class_name Game
extends Node2D

@export var gameOverScene: PackedScene

@onready var player: Snake = $Snake
@onready var playingArea: PlayingArea = $PlayingArea
@onready var ui: UI = $UI

var score: int = 0

func _ready() -> void:
	playingArea.apple_hit.connect(player.handle_apple_hit)
	playingArea.wall_hit.connect(on_playing_area_wall_hit)
	player.segment_added.connect(on_player_segment_added)
	player.ate_self.connect(on_player_ate_self)


func game_over() -> void:
	var gameOver: GameOver = gameOverScene.instantiate()
	gameOver.score = score
	
	player.queue_free()
	playingArea.queue_free()
	ui.queue_free()
	
	add_child(gameOver)


func on_playing_area_wall_hit() -> void:
	game_over()


func on_player_ate_self() -> void:
	game_over()


func on_player_segment_added(is_first: bool) -> void:
	if !is_first:
		score += 1
		ui.set_score_value(score)
