extends Node2D

@onready var paint_tools = $"../CanvasLayer/Control/MarginContainer/PaintTools"

var paint_strategy: PaintStrategy = preload("res://scripts/map/paint_strategy/paint_strategy.gd").new()
var is_paint: bool = false

signal paint

func _ready() -> void:
	paint_tools.paint_strategy_selected.connect(paint_strategy_selected)
	
func paint_strategy_selected(paint_strategy: PaintStrategy):
	self.paint_strategy = paint_strategy

func _draw() -> void:
	for event in paint_strategy.events:
		event.call()

func _process(delta: float) -> void:
	if is_paint:
		paint_strategy.catch_paint_events_internal(self, get_local_mouse_position())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		is_paint = event.button_mask == MOUSE_BUTTON_MASK_LEFT		
