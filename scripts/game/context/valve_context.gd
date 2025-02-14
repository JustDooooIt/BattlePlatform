## 存储当前时刻算子的状态
class_name ValveContext extends Context

var piece: Piece = null

func get_myself() -> Pipeline:
	return piece.pipeline
	
func get_enemy() -> Enemy:
	return piece.enemy
