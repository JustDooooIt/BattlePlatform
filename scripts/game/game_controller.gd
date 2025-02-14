extends Node2D

var selected_piece: Piece = null : 
	set = set_piece
var pipelines: Array[Pipeline] = []
var my_pipeline: Player = null
var enemy: Network = null
var pieces: CellStack = CellStack.new()
var playing_faction: int = 1
var faction: int = 1

var is_host: bool = false
var github_username: String = 'JustDooooIt'
var discussion_number: int = 0
var discussion_id: String = ''

var crypto = Crypto.new()
var my_key: CryptoKey = null
var my_private_key: String = ''
var my_public_key: String = ''
var enemy_public_key: String = ''

func _ready() -> void:
	init_pipeline()
	get_node('/root/Game/CanvasLayer/Run').pressed.connect(_on_button_pressed)
	get_node('/root/Game/CanvasLayer/Faction').toggled.connect(_on_faction_changed)
	get_node('/root/Game/CanvasLayer/Host').toggled.connect(_on_host_toggled)
	get_node('/root/Game/CanvasLayer/Start').pressed.connect(_on_start_pressed)

func create_keys():
	crypto = Crypto.new()
	my_key = crypto.generate_rsa(2048)
	my_private_key = my_key.save_to_string(true)
	my_public_key = my_key.save_to_string(false)

func sign_data(data: CryptoKey, private_key: String) -> PackedByteArray:
	var key = crypto.load_rsa(private_key)
	var signature = crypto.sign(HashingContext.HASH_SHA256, key, data)
	return signature

## 创建管道,并给全局上下文挂载管道
func init_pipeline():
	my_pipeline = get_node("/root/Game/Pieces/0")
	enemy = get_node("/root/Game/Pieces/1")

## 在移动阶段,操作算子后生成valves
## 比如移动算子,会生成移动路径,将其原子化为多个valve并执行
## 如果遇到waitable可能会暂停
func move(start: Vector2i, target: Vector2i):
	var operation = MoveOperation.new(selected_piece, start, target)
	operation._run()
	await my_pipeline.run(selected_piece)

func pre_attack(start: Vector2i, target: Vector2i):
	var operation = AttackOperation.new(BattleController.attack_info, selected_piece, start, pieces.get_cell_pieces(target), target)
	operation._run()
	await my_pipeline.run(selected_piece)

## 结算攻击
func attack():
	my_pipeline.emit_signal('notify')

func _cell_right_clicked(position: Vector2i):
	if selected_piece is PlayerPiece:
		var cell_type: int = pieces.cell_type(position, 0)
		if selected_piece.can_move(position):
			move(selected_piece.get_map_position(), position)
		elif selected_piece.can_attack(position):
			pre_attack(selected_piece.get_map_position(), position)

func get_global_target():
	return %HexMap.map_to_local(position) + %HexMap.position

func create_room():
	await Discussion.connected
	var discussion: Dictionary = await Discussion.create_discussion()
	discussion_id = discussion['data']['createDiscussion']['discussion']['id']
	discussion_number = discussion['data']['createDiscussion']['discussion']['number']

func _on_host_toggled(toggled_on: bool) -> void:
	is_host = toggled_on
	my_pipeline.state = int(toggled_on) % 1
	playing_faction = (not toggled_on) as int

func _on_start_pressed() -> void:
	if is_host:
		#GameController.create_room()
		discussion_id = 'D_kwDON1yf484AeRBk'
		discussion_number = 7
		print('Room created.')
	else:
		discussion_id = 'D_kwDON1yf484AeRBk'
		discussion_number = 7
		#Discussion.headers[1] = 'Authorization: Bearer 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'
	enter_room()

func enter_room():
	create_keys()
	print('Key created.')
	var content = { 'faction': faction, 'public_key': my_public_key }
	if !Discussion.is_github_connected:
		await Discussion.connected
	await Discussion.upload_public_key(faction, my_public_key)
	print('Public key uploaded.')
	var public_key = await Discussion.query_public_key(faction, discussion_number)
	if public_key == '':
		printerr('The other user`s connection was unsuccessful.')
	else:
		enemy_public_key = public_key
		print('The other user`s connection was successful.')

## 友方算子被选中
func _my_piece_selected(piece: Piece):
	selected_piece = piece

## 敌方算子被选中
func _other_piece_selected(piece: Piece):
	selected_piece = piece

func set_piece(value: Piece):
	selected_piece = value

func _on_button_pressed() -> void:
	attack()

func _on_end_pressed() -> void:
	my_pipeline.stage += 1
	my_pipeline.stage %= Player.Stage.IDLE

func _on_faction_changed(value: bool):
	self.faction = int(not value)

enum Op {
	IDLE,
	MOVE,
	ATTACK
}
