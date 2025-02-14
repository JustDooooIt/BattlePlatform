extends PolylineDrawer

func _draw_polyline(canvas: CanvasItem, points: PackedVector2Array, color: Color, thickness: int):
	canvas.draw_polyline(points, color, thickness, false)
