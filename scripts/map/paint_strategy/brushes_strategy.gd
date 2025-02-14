class_name BrushesStrategy extends PaintStrategy

func catch_paint_events(canvas: CanvasItem, position: Vector2, color: Color = Color()) -> void:
	var callable: Callable = Callable(canvas.draw_line).bind(position, position + Vector2.ONE, Color(0,0,0))
	events.append(callable)
