extends VBoxContainer

@export var button_group: ButtonGroup

var paint_tool: PaintTool = PaintTool.NONE : 
	set = set_paint_tool

signal paint_strategy_selected(paint_strategy: PaintStrategy)

func _ready() -> void:
	button_group.pressed.connect(tool_pressed)
	
func tool_pressed(button:BaseButton):
	match button.name:
		"Brushes":
			paint_tool = PaintTool.BRUSHES
		"Eraser":
			paint_tool = PaintTool.ERASER
		_:
			paint_tool = PaintTool.NONE
			
func set_paint_tool(value):
	paint_tool = value
	var paint_strategy: Script = null
	match paint_tool:
		PaintTool.NONE:
			paint_strategy = preload("res://scripts/map/paint_strategy/paint_strategy.gd")
		PaintTool.BRUSHES:
			paint_strategy = preload("res://scripts/map/paint_strategy/brushes_strategy.gd")
		PaintTool.ERASER:
			paint_strategy = preload("res://scripts/map/paint_strategy/paint_strategy.gd")
	emit_signal('paint_strategy_selected', paint_strategy.new() as PaintStrategy)

enum PaintTool {
	NONE, BRUSHES, ERASER
}
