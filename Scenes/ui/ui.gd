class_name UI
extends CanvasLayer

@onready var scoreValue: Label = $%ScoreValue


func set_score_value(value: int) -> void:
	scoreValue.text = str(value)
