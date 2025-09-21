extends Node2D
class_name GridManager

# Dimensioni griglia
const GRID_WIDTH = 100
const GRID_HEIGHT = 100
const CELL_SIZE = 32  # Dimensione in pixel di ogni cella

const TERRENO = preload("uid://bida6fh5vvlef")
@onready var step_button: Button = %Step
@onready var spawn_menu: SpawnMenu = %SpawnMenu

# Array per contenere tutte le sprite generate
var grid_sprites: Array[Array] = []

func _ready():
	generate_grid()
	step_button.pressed.connect(func(): step(); spawn_menu.visible = false)

func generate_grid():
	for y in range(GRID_HEIGHT):
		var row: Array[Node2D] = []
		for x in range(GRID_WIDTH):
			# Istanzia la sprite del terreno
			var terrain_sprite : Terreno = TERRENO.instantiate()
			terrain_sprite.coords = Vector2(x,y)
			add_child(terrain_sprite)
			# Posiziona la sprite
			terrain_sprite.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
			# Aggiungi all'array
			row.append(terrain_sprite)
		
		grid_sprites.append(row)

func count_neighbors(x: int, y: int) -> int:
	var cnt = 0
	for delta_y in [-1, 1]:
		var ny = y + delta_y
		ny = (ny + GRID_HEIGHT) % GRID_HEIGHT
		print("Coordinata " +str(x)+","+str(ny)+ "    " + str(grid_sprites[ny][x].type) )
		if grid_sprites[ny][x].has_flower():
			cnt += 1
			
	for delta_x in [-1, 1]:
		var nx = x + delta_x
		nx = (nx + GRID_WIDTH) % GRID_WIDTH
		print("Coordinata " +str(nx)+","+str(y)+ "  " + str(grid_sprites[y][nx].type) )
		if grid_sprites[y][nx].has_flower():
			cnt += 1
	return cnt

func step() -> void:
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if grid_sprites[y][x].type in [Terreno.CellType.TREE, Terreno.CellType.ANIMAL, Terreno.CellType.EMPTY]:
				continue
			print("Conto vicini a " +str(x)+","+str(y))
			var n = count_neighbors(x, y)
			if (grid_sprites[y][x].has_flower()):
				match n:
					2: 
						if y == 0: 
							y = GRID_HEIGHT -1
						if y+1 == GRID_HEIGHT: 
							y = 0
						if x == 0: 
							x = GRID_WIDTH -1
						if x+1 == GRID_WIDTH: 
							x = 0
						
						if(grid_sprites[y-1][x].queued_action == -1 and (grid_sprites[y-1][x].is_empty() or grid_sprites[y-1][x].has_flower())): 
							grid_sprites[y-1][x].queued_action = 1
						if(grid_sprites[y+1][x].queued_action == -1 and (grid_sprites[y+1][x].is_empty() or grid_sprites[y+1][x].has_flower())): 
							grid_sprites[y+1][x].queued_action = 1
						if(grid_sprites[y][x-1].queued_action == -1 and (grid_sprites[y][x].is_empty() or grid_sprites[y-1][x].has_flower())): 
							grid_sprites[y][x-1].queued_action = 1
						if(grid_sprites[y][x+1].queued_action == -1 and (grid_sprites[y][x+1].is_empty() or grid_sprites[y][x+1].has_flower())): 
							grid_sprites[y][x+1].queued_action = 1
					_:
						grid_sprites[y][x].queued_action = 0
						
			print("-------")

	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			match grid_sprites[y][x].queued_action:
				0: grid_sprites[y][x].clear_tile()
				1: grid_sprites[y][x].spawn_flower()
				2: grid_sprites[y][x].spawn_tree()
				3: grid_sprites[y][x].spawn_animal()

func move_animals(grid: Array, animals: Array, width: int, height: int) -> Array:
	var new_positions = []
	for pos in animals:
		var x = pos[0]
		var y = pos[1]
		var directions = [[0,1],[1,0],[0,-1],[-1,0]]
		var choice = directions[randi() % directions.size()]
		var nx = x + choice[0]
		var ny = y + choice[1]
		if nx >= 0 and nx < width and ny >= 0 and ny < height and !grid[ny][nx].has_tree():
			grid[y][x].spawn_flower()
			grid[ny][nx].spawn_animal()
			new_positions.append([nx, ny])
		else:
			new_positions.append([x, y])
	return new_positions

func apply_flowers_trees_animals(grid: Array, animals: Array) -> void:
	var h = grid.size()
	var w = grid[0].size()

	# Pattern speciale di fiori 4x4 => diventa alberi
	for y in range(h-3):
		for x in range(w-3):
			var pattern = [
				[0, 1, 1, 0],
				[1, 0, 0, 1],
				[1, 0, 0, 1],
				[0, 1, 1, 0]
			]
			var matches = true
			for dy in range(4):
				for dx in range(4):
					var cell = grid[y+dy][x+dx]
					if (pattern[dy][dx] == 1 and !cell.has_flower()) or (pattern[dy][dx] == 0 and !cell.is_empty()):
						matches = false
			if matches:
				grid[y+1][x+1].spawn_tree()
				grid[y+1][x+2].spawn_tree()
				grid[y+2][x+1].spawn_tree()
				grid[y+2][x+2].spawn_tree()

	# Alberi 2x2 => conflitto => generazione animali
	var tree_blocks = []
	for y in range(h-1):
		for x in range(w-1):
			if grid[y][x].has_tree() and grid[y][x+1].has_tree() and grid[y+1][x].has_tree() and grid[y+1][x+1].has_tree():
				tree_blocks.append([x, y])

	var to_kill = []
	for i in range(tree_blocks.size()):
		var x1 = tree_blocks[i][0]
		var y1 = tree_blocks[i][1]
		for j in range(i+1, tree_blocks.size()):
			var x2 = tree_blocks[j][0]
			var y2 = tree_blocks[j][1]
			if abs(x1-x2) <= 3 and abs(y1-y2) <= 3:
				if [x1,y1] not in to_kill:
					to_kill.append([x1,y1])
				if [x2,y2] not in to_kill:
					to_kill.append([x2,y2])

	for pos in to_kill:
		var x = pos[0]
		var y = pos[1]
		animals.append([x, y])
		grid[y][x].clear_tile()
		grid[y][x+1].clear_tile()
		grid[y+1][x].clear_tile()
		grid[y+1][x+1].clear_tile()

	animals = move_animals(grid, animals, w, h)
