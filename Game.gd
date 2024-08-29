extends Node2D
# 1. 定义横向多少个格子
# 2. 定义纵向多少个格子
# 3. 定义炸弹数量
# 3. 定义数组保存格子状态
# 4.定义button的大小
# 4. 定义格子状态的class
	# 1. 包含了格子的坐标
	# 2. 格子是否是炸弹
	# 3. 格子是否插旗
	# 4. 周围炸弹的数量
	# 5. 是否是翻开状态
# 5. 初始化所有格子
# 6. 随机给格子埋雷
# 7. 根据格子渲染 button
# 8. button 点击后 将格子设置为翻开状态，并将周围的非炸弹的格子翻开，迭代直到周围是炸弹或者已经翻开了。并将周围的炸弹的数量标记在地图上
# 9. 格子标记为炸弹时候添加 button修改属性
class Cell:
	var x:int
	var y:int
	var button:Button
	var is_bomb = false
	var is_flagged = false
	var around_bombs = 0
	var is_revealed = false
	
	func _init(x:int,y:int):
		self.x = x
		self.y = y
	
const ROWS := 10
const COLS := 10
const BOMB_COUNT := 10;
const CELL_SIZE := Vector2(40,40)
const SPACING := 2
var grid = []
	
func _ready():
	
	for y in range(ROWS):
		var row = []
		for x in range(COLS):
			var cell = Cell.new(x,y)
			var button = Button.new()
			cell.button = button
			add_child(button)
			button.set_size(CELL_SIZE)
			button.position.x = x * (CELL_SIZE.x + SPACING)
			button.position.y = y * (CELL_SIZE.y + SPACING)
			button.pressed.connect(_on_button_pressed.bind(cell))
			button.gui_input.connect(_on_cell_right_click.bind(cell))
			row.append(cell)
		grid.append(row)
		
	for _b in range(BOMB_COUNT):
		var x = randi() % COLS
		var y = randi() % ROWS
		grid[y][x].is_bomb = true
		
	for y in range(ROWS):
		for x in range(COLS):
			if not grid[y][x].is_bomb:
				var count = 0
				for i in range(max(0,y-1),min(ROWS,y+2)):
					for j in range(max(0,x-1),min(COLS,x+2)):
						if i!=y or j!=x:
							count += int(grid[i][j].is_bomb)
				grid[y][x].around_bombs = count
				

func _on_cell_right_click(event:InputEvent,cell:Cell):
	if event is InputEvent and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
		if cell.is_revealed:
			return 
		if cell.is_flagged:
			cell.is_flagged = false
			cell.button.text= ""
		else:
			cell.is_flagged=  true
			cell.button.text="🚩"
		check_for_victory()

func check_for_victory():
	var flagged_bombs_count = 0
	var total_bombs = 0
	
	for y in range(ROWS):
		for x in range(COLS):
			if grid[y][x].is_flagged and grid[y][x].is_bomb:
				flagged_bombs_count += 1
	# 计算所有炸弹的总数
	for y in range(ROWS):
		for x in range(COLS):
			if grid[y][x].is_bomb:
				total_bombs += 1
				
	# 如果标记的炸弹数量等于实际炸弹数量，则玩家胜利
	if flagged_bombs_count == total_bombs:
		print("恭喜，您赢得了游戏！")
	else:
		#print("继续努力，还有一些炸弹没有被标记。")
		pass
		
		
func _on_button_pressed(cell:Cell):
	if cell.is_flagged:
		return
	if cell.is_bomb:
		cell.button.text = "💣"
		#  显示所有的炸弹
		print("游戏结束！您触雷了。")
		reveal_bombs()  # 调用函数显示所有炸弹
		return
	reveal_cell(cell.x,cell.y)

func reveal_bombs():
	for y in range(ROWS):
		for x in range(COLS):
			var cell = grid[y][x]
			if cell.is_bomb:
				cell.button.text =  "💣"
				
				
func reveal_cell(x,y):
	var cell:Cell=grid[y][x]
	if cell.is_revealed:
		return 
	cell.is_revealed = true
	if cell.around_bombs == 0:
		remove_child(cell.button)
	cell.button.text = str(cell.around_bombs)
	if cell.is_bomb:
		return
	else:
		if cell.around_bombs == 0:
			for dx in [-1,0,1]:
				for dy in [-1,0,1]:
					if dx == 0 and dy == 0:
						continue
					var nx = x+dx
					var ny = y+dy
					if nx >= 0 and nx < COLS and ny >=0 and ny < ROWS:
						reveal_cell(nx,ny)
		else:
			pass
