extends Node

# Stati delle celle
const EMPTY = 0
const FLOWER = 1
const TREE = 2
const ANIMAL = 3

var grid = []
var animals = []

# --- Grid functions ---
func make_grid(width: int, height: int, fill: bool=false) -> Array:
	var new_grid = []
	for y in range(height):
		var row = []
		for x in range(width):
			if fill and randi() % 100 < 20:  # 20% chance for a flower
				row.append(FLOWER)
			else:
				row.append(EMPTY)
		new_grid.append(row)
	return new_grid

func count_neighbors(grid: Array, x: int, y: int, torus: bool=false) -> int:
	var cnt = 0
	var h = grid.size()
	var w = grid[0].size()
	for dy in [-1, 0, 1]:
		for dx in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var nx = x + dx
			var ny = y + dy
			if torus:
				nx = (nx + w) % w
				ny = (ny + h) % h
			if nx >= 0 and nx < w and ny >= 0 and ny < h and grid[ny][nx] == FLOWER:
				cnt += 1
	return cnt

func step(grid: Array, torus: bool=false) -> Array:
	var h = grid.size()
	var w = grid[0].size()
	var new_grid = []
	for y in range(h):
		var new_row = []
		for x in range(w):
			new_row.append(grid[y][x])
		new_grid.append(new_row)

	for y in range(h):
		for x in range(w):
			if grid[y][x] in [TREE, ANIMAL]:
				continue
			var n = count_neighbors(grid, x, y, torus)
			if grid[y][x] == FLOWER:
				new_grid[y][x] = FLOWER if n in [2, 3] else EMPTY
			elif grid[y][x] == EMPTY:
				new_grid[y][x] = FLOWER if n == 3 else EMPTY
	return new_grid

func move_animals(grid: Array, animals: Array, width: int, height: int) -> Array:
	var new_positions = []
	for pos in animals:
		var x = pos[0]
		var y = pos[1]
		var directions = [[0,1],[1,0],[0,-1],[-1,0]]
		var choice = directions[randi() % directions.size()]
		var nx = x + choice[0]
		var ny = y + choice[1]
		if nx >= 0 and nx < width and ny >= 0 and ny < height and grid[ny][nx] != TREE:
			grid[y][x] = FLOWER
			grid[ny][nx] = ANIMAL
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
					if (pattern[dy][dx] == 1 and cell != FLOWER) or (pattern[dy][dx] == 0 and cell != EMPTY):
						matches = false
			if matches:
				grid[y+1][x+1] = TREE
				grid[y+1][x+2] = TREE
				grid[y+2][x+1] = TREE
				grid[y+2][x+2] = TREE

	# Alberi 2x2 => conflitto => generazione animali
	var tree_blocks = []
	for y in range(h-1):
		for x in range(w-1):
			if grid[y][x] == TREE and grid[y][x+1] == TREE and grid[y+1][x] == TREE and grid[y+1][x+1] == TREE:
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
		grid[y][x] = EMPTY
		grid[y][x+1] = EMPTY
		grid[y+1][x] = EMPTY
		grid[y+1][x+1] = EMPTY

	animals = move_animals(grid, animals, w, h)
