class_name PlayingArea
extends Node

signal apple_hit(area: Segment)
signal wall_hit

@export var snake: Snake

@onready var apple: Segment = $Apple
@onready var walls: Node = $Walls


var cells: Vector2

func _ready() -> void:
	# высчитываем размер сетки относительно размеров яблока
	cells = Vector2(
		Globals.viewportSize.x / apple.SIZE.x,
		Globals.viewportSize.y / apple.SIZE.y
	)
	
	apple.area_entered.connect(on_apple_area_entered)
	
	for wall: Area2D in walls.get_children():
		wall.area_entered.connect(on_wall_area_entered)

	# спавним яблоко в случайную точку на поле
	set_random_apple_position()

func set_random_apple_position() -> void:
	# получаем рандомное число в диапазоне от 1 до CELLS-2. Диапазон именно 
	# такой, потому что по перриметру поля стоят стены толщиной в одну точку. 
	# Это позволит исключить позиционирование яблока на стенах
	var pointX: int = randi_range(1, cells.x-2)
	var pointY: int = randi_range(1, cells.y-2)
	
	# поправка на центр яблока
	var centerCorrection: Vector2 = Vector2(apple.SIZE.x / 2, apple.SIZE.y / 2)
	
	# конвертируем точку в позицию на поле c поправкой на центр яблока
	var newPosition: Vector2 = Vector2(
		pointX * apple.SIZE.x, 
		pointY * apple.SIZE.y
	) + centerCorrection
	
	# проверяем, если эта позиция совпадает с позицией какого-то из сегментов
	# змейки - то рекурсивно вызываем еще раз этот метод чтобы получить новую 
	# случайную позицию клетки, и так пока не найдется свободная клетка
	if snake.is_some_segment_position(newPosition):
		return set_random_apple_position()
	
	# во всех остальных случаях - перемещаем яблоко по полученной позиции
	apple.position = newPosition


func on_apple_area_entered(area: Segment) -> void:
	if area.get_collision_layer_value(Globals.Collision.PLAYER):
		apple_hit.emit(area)
		set_random_apple_position()


func on_wall_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(Globals.Collision.PLAYER):
		wall_hit.emit()
