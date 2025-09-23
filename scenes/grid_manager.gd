extends Node2D
class_name GridManager

# Dimensioni griglia
const GRID_WIDTH = 100
const GRID_HEIGHT = 100
const CELL_SIZE = 32  # Dimensione in pixel di ogni cella

const TILE : PackedScene = preload("uid://kbh15wp6fe5k")

var grid: Array[Array] = []

func _ready():
	GameManager.grid_manager = self
	generate_grid()

func generate_grid():
	for x in range(GRID_WIDTH):
		var column: Array[Node2D] = []
		for y in range(GRID_HEIGHT):
			var terrain_sprite : Tile = TILE.instantiate()
			terrain_sprite.coords = Vector2i(x,y)
			terrain_sprite.position = Vector2i(x * CELL_SIZE, y * CELL_SIZE)
			add_child(terrain_sprite)
			column.append(terrain_sprite)
		
		grid.append(column)

func count_neighbors(tile: Tile) -> int:
	var cnt = 0
	var directions : Array[Vector2i] = [Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
	for direction in directions:
		var toroidal_coords : Vector2i = _toroidal_coords(tile.coords + direction)
		print(GameManager.stringify_Vector2(direction)+": "+str(grid[toroidal_coords.x][toroidal_coords.y]))
		if tile.type == grid[toroidal_coords.x][toroidal_coords.y].type:
			cnt += 1
	return cnt
	
func _toroidal_coords(input_coords : Vector2i) -> Vector2i:
	var toroidal := input_coords
	if toroidal.x < 0: toroidal.x = GRID_WIDTH -1
	if toroidal.x > GRID_WIDTH-1: toroidal.x = 0
	if toroidal.y < 0: toroidal.y = GRID_HEIGHT -1
	if toroidal.y > GRID_HEIGHT-1: toroidal.y = 0
	return toroidal;

func step() -> void:
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if grid[x][y].type in [Tile.CellType.TREE, Tile.CellType.ANIMAL, Tile.CellType.EMPTY]:
				continue
			print("Conto vicini a " +str(x)+","+str(y))
			var n = count_neighbors(grid[x][y])
			if (grid[x][y].has_flower()):
				if n in [2,3]:
					#Se ci sono 2 fiori vicini -> fai proliferare altri fiori se non ci sono già altri ordini
					var my_lambda = func(coords : Vector2i, cell_type : Tile.CellType):
						if(grid[coords.x][coords.y].can_grow(cell_type)): 
							grid[coords.x][coords.y].next_step_action = Tile.CellNextStep.GROW
					var coords : Vector2i = Vector2i(x,y)
					my_lambda.call(_toroidal_coords(coords + Vector2i.UP), Tile.CellType.FLOWER)
					my_lambda.call(_toroidal_coords(coords + Vector2i.LEFT), Tile.CellType.FLOWER)
					my_lambda.call(_toroidal_coords(coords + Vector2i.RIGHT), Tile.CellType.FLOWER)
					my_lambda.call(_toroidal_coords(coords + Vector2i.DOWN), Tile.CellType.FLOWER)
				else:
					grid[x][y].next_step_action = Tile.CellNextStep.DIE
						
			print("-------")

	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			match grid[x][y].next_step_action:
				Tile.CellNextStep.DIE: grid[x][y].clear_tile()
				Tile.CellNextStep.GROW: grid[x][y].grow(Tile.CellType.FLOWER)

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
			grid[x][y].spawn_flower()
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
					var cell = grid[x+dx][y+dy]
					if (pattern[dx][dy] == 1 and !cell.has_flower()) or (pattern[dx][dy] == 0 and !cell.is_empty()):
						matches = false
			if matches:
				grid[x+1][y+1].spawn_tree()

	# Alberi 2x2 => conflitto => generazione animali
	var tree_blocks = []
	for y in range(h-1):
		for x in range(w-1):
			if grid[x][y].has_tree() and grid[x+1][y].has_tree() and grid[x][y+1].has_tree() and grid[x+1][y+1].has_tree():
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
		grid[x][y].clear_tile()
		grid[x+1][y].clear_tile()
		grid[x][y+1].clear_tile()
		grid[x+1][y+1].clear_tile()

	animals = move_animals(grid, animals, w, h)
