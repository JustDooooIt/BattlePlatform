class_name PaintStrategy extends RefCounted

var events: Array[Callable] = []
var index: Array = []

func catch_paint_events(canvas: CanvasItem, position: Vector2, color: Color = Color()) -> void:
	return Callable()

func catch_paint_events_internal(canvas: CanvasItem, position: Vector2, color: Color = Color()):
	catch_paint_events(canvas, position, color)
	if events.size() > 0:
		canvas.queue_redraw()
