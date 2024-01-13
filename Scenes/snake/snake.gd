class_name Snake
extends Node2D

signal segment_added(first: bool)
signal ate_self

@export var segmentScene: PackedScene
@export var speedBoost: float = 0.002
@export var maxStepTime: float = 0.25
@export var minStepTime: float = 0.05

@onready var segmentsNode: Node = $Segments
@onready var stepTimer: Timer = $StepTimer

var direction: Vector2 = Vector2.ZERO
var segmentSize: int = 32


func _ready() -> void:
	var head = add_segment()
	
	head.position = Globals.viewportSize / 2 - Vector2(segmentSize/2, segmentSize/2)
	stepTimer.timeout.connect(on_step_timer_timeout)
	stepTimer.wait_time = maxStepTime
	stepTimer.start()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		change_direction(Vector2.UP)
	elif event.is_action_pressed("ui_down"):
		change_direction(Vector2.DOWN)
	elif event.is_action_pressed("ui_left"):
		change_direction(Vector2.LEFT)
	elif event.is_action_pressed("ui_right"):
		change_direction(Vector2.RIGHT)


func move_segments() -> void:
	var segments = segmentsNode.get_children()
	var firstSegment = segments[0]
	var lastSegment = segments[-1]
	
	# двигаем последний сегент на место головы, перед первым сегментом по вектору движения
	lastSegment.position = firstSegment.position + direction * segmentSize
	# ставим его в дереве на первое место, чтоб знать что теперь он - голова
	segmentsNode.move_child(lastSegment, 0)


func change_direction(new_direction: Vector2) -> void:
	if new_direction != direction * -1:
		direction = new_direction


func add_segment() -> Segment:
	var isFirst: bool = segmentsNode.get_child_count() == 0
	var newSegment: Segment = segmentScene.instantiate()
	
	# добавляем слой и маски для коллизий
	newSegment.set_collision_layer_value(Globals.Collision.PLAYER, true)
	newSegment.set_collision_mask_value(Globals.Collision.PLAYER, true)
	newSegment.set_collision_mask_value(Globals.Collision.APPLE, true)
	newSegment.set_collision_mask_value(Globals.Collision.WALL, true)
	
	# подключаем обработчк коллизии с другими сегментами
	newSegment.area_entered.connect(on_segment_area_entered)
	
	# позицинируем за пределами игровой области и добавляем в ноду сегментов
	newSegment.position = Vector2(-100, -100)
	segmentsNode.call_deferred("add_child", newSegment)
	
	segment_added.emit(isFirst)
	
	# ускоряемся всегда, кроме добавления первого сегмента (головы)
	if !isFirst:
		boost_step_timer()
	
	return newSegment


func boost_step_timer() -> void:
	if stepTimer.wait_time > minStepTime:
		stepTimer.wait_time -= speedBoost


func get_current_head_segment() -> Segment:
	return segmentsNode.get_children()[0]


func handle_apple_hit(area: Segment) -> void:
	if area.get_instance_id() == get_current_head_segment().get_instance_id():
		add_segment()
	else:
		push_error("Collision apple with NOT HEAD segment: " + str(area))


func is_some_segment_position(some_position: Vector2) -> bool:
	for segment in segmentsNode.get_children():
		if segment.position == some_position:
			return true
	
	return false


func on_step_timer_timeout() -> void:
	if direction != Vector2.ZERO:
		move_segments()


func on_segment_area_entered(area: Segment) -> void:
	# столкновение с другим сегментом змеи считаем самопоеданием )
	if area.get_collision_layer_value(Globals.Collision.PLAYER):
		ate_self.emit()

