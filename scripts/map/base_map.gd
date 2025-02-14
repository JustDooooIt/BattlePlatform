class_name HexGrid extends TileMapLayer

@export var map_size: Vector2 = Vector2(10, 10)
@export var polyline_drawer_script: Script = preload("res://scripts/map/drawer/solid_line_drawer.gd") : 
	set(value):
		if value == null:
			printerr('Please mount the line drawing script.')
		polyline_drawer = value.new()

@onready var tile_size: Vector2 = tile_set.tile_size
@onready var tile_layout:TileSet.TileLayout = tile_set.tile_layout
@onready var tile_offset_axis:TileSet.TileOffsetAxis = tile_set.tile_offset_axis
@onready var base_map_tile_set: BaseMapTileSet = tile_set as BaseMapTileSet
@onready var polyline_drawer: PolylineDrawer = polyline_drawer_script.new()

func _ready() -> void:
	pass
	
func _draw():
	# 遍历整个网格
	for row in range(map_size.y):
		for col in range(map_size.x):
			# 计算六边形中心点
			var center = get_hex_center(col, row)
			# 绘制矩形内接的六边形
			draw_hexagon(center)

# 计算每个六边形的中心
func get_hex_center(col, row):
	return map_to_local(Vector2(col, row))

# 绘制矩形内接六边形
func draw_hexagon(center):
	var points = []
	if tile_offset_axis == TileSet.TILE_OFFSET_AXIS_VERTICAL:
		points.append(Vector2(center.x - tile_size.x / 2, center.y))
		points.append(Vector2(center.x - tile_size.x / 4, center.y - tile_size.y / 2))
		points.append(Vector2(center.x + tile_size.x / 4, center.y - tile_size.y / 2))
		points.append(Vector2(center.x + tile_size.x / 2, center.y))
		points.append(Vector2(center.x + tile_size.x / 4, center.y + tile_size.y / 2))
		points.append(Vector2(center.x - tile_size.x / 4, center.y + tile_size.y / 2))
	else:
		points.append(Vector2(center.x, center.y - tile_size.y / 2))
		points.append(Vector2(center.x + tile_size.x / 2, center.y - tile_size.y / 4))
		points.append(Vector2(center.x + tile_size.x / 2, center.y + tile_size.y / 4))
		points.append(Vector2(center.x, center.y + tile_size.y / 2))
		points.append(Vector2(center.x - tile_size.x / 2, center.y + tile_size.y / 4))
		points.append(Vector2(center.x - tile_size.x / 2, center.y - tile_size.y / 4))
	points.append(points[0])
	polyline_drawer._draw_polyline(self, points, base_map_tile_set.color, base_map_tile_set.thickness)
