extends Node

enum Collision {
	WALL = 1, 
	PLAYER = 2, 
	APPLE = 3
}

var viewportSize: Vector2

func _ready() -> void:
	viewportSize = get_viewport().get_visible_rect().size
