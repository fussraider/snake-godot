class_name GameOver 
extends CanvasLayer

@export var score: int = 0

@onready var scoreValue: Label = $%ScoreValue
@onready var restartButton: Button = $%RestartButton


func _ready() -> void:
	scoreValue.text = str(score)
	restartButton.pressed.connect(on_restart_button_presses)
	
func on_restart_button_presses() -> void:
	get_tree().reload_current_scene()

