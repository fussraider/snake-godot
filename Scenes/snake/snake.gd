class_name Snake
extends Node2D

@export var segmentScene: PackedScene
@export var stepSpeed: float = 0.2

@onready var segmentsNode: Node = $Segments
@onready var stepTimer: Timer = $StepTimer

var direction: Vector2 = Vector2.ZERO
var segmentSize: int = 32


func _ready() -> void:
	var head = add_segment()
	
	head.position = Globals.viewportSize / 2 - Vector2(segmentSize/2, segmentSize/2)
	
	# todo: для отладки, потом удалять
	#add_segment()
	#add_segment()
	#add_segment()
	#add_segment()
	
	stepTimer.wait_time = stepSpeed
	stepTimer.timeout.connect(on_step_timer_timeout)
	stepTimer.start()
	
#func _physics_process(delta: float) -> void:
	#if direction != Vector2.ZERO:
		#on_step_timer_timeout()
		#direction = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		direction = Vector2.UP
	elif event.is_action_pressed("ui_down"):
		direction = Vector2.DOWN
	elif event.is_action_pressed("ui_left"):
		direction = Vector2.LEFT
	elif event.is_action_pressed("ui_right"):
		direction = Vector2.RIGHT


func move_segments() -> void:
	var segments = segmentsNode.get_children()
	var firstSegment = segments[0]
	var lastSegment = segments[-1]
	
	# двигаем последний сегент на место головы, перед первым сегментом по вектору движения
	lastSegment.position = firstSegment.position + direction * segmentSize
	# ставим его в дереве на первое место, чтоб знать что теперь он - голова
	segmentsNode.move_child(lastSegment, 0)
	


func add_segment() -> Segment:
	var newSegment: Segment = segmentScene.instantiate()
	
	# добавляем слой и маску для коллизий
	newSegment.set_collision_layer_value(Globals.Collision.PLAYER, true)
	newSegment.set_collision_mask_value(Globals.Collision.APPLE, true)
	newSegment.set_collision_mask_value(Globals.Collision.WALL, true)
	
	# позицинируем за пределами игровой области и добавляем в ноду сегментов
	newSegment.position = Vector2(-100, -100)
	segmentsNode.call_deferred("add_child", newSegment)
	
	return newSegment

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
