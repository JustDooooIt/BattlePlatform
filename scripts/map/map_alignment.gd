extends Node2D

@onready var start_align_button: Button = $"../CanvasLayer/Control/HBoxContainer/StartAlign"
@onready var length = $"../CanvasLayer/Control/HBoxContainer/Length"
@onready var direction: CheckButton = $"../CanvasLayer/Control/HBoxContainer/CheckButton"

var is_start_align: bool = false
var grid_radius = 2

func _ready() -> void:
	start_align_button.pressed.connect(align)
	
func align() -> void:
	is_start_align = true
	pass

func _draw():
	if not is_start_align:
		return
	var side_length = length.value
	# 遍历六边形网格 (以轴坐标 q, r 为基础)
	for q in range(-grid_radius, grid_radius + 1):
		for r in range(-grid_radius, grid_radius + 1):
			var s = -q - r  # 第三个轴坐标
			if abs(s) <= grid_radius:  # 限制在六边形范围内
				# 计算六边形中心点的像素坐标
				var hex_center = axial_to_pixel(q, r, side_length)
				# 绘制六边形
				draw_hexagon(hex_center, side_length)

# 计算轴坐标到像素坐标的转换
func axial_to_pixel(q: int, r: int, size: float) -> Vector2:
	var x: float
	var y: float
	var center = get_local_mouse_position()
	var is_horizontal = direction.button_pressed
	if is_horizontal:
		x = center.x + size * sqrt(3)* (r / 2.0 + q)
		y = center.y + size * 1.5 * r
	else:
		x = center.x + size * 1.5 * q
		y = center.y + size * sqrt(3) * (r + q / 2.0)
	return Vector2(x, y)

# 绘制一个六边形
func draw_hexagon(center: Vector2, size: float):
	var vertices = []
	var offset = 30 if direction.button_pressed else 0
	for i in range(6):
		var angle = deg_to_rad(offset + 60 * i)  # 水平方向六边形
		var x = center.x + size * cos(angle)
		var y = center.y + size * sin(angle)
		vertices.append(Vector2(x, y))
	
	# 绘制六边形边框
	draw_polygon(vertices, [Color(0.2, 0.6, 1.0, 0.4)])  # 半透明填充颜色
	draw_polyline(vertices + [vertices[0]], Color(1, 1, 1), 2)  # 绘制边框

func _process(delta: float) -> void:
	if is_start_align:
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT and event.is_pressed():
			is_start_align = false
			queue_redraw()
