extends Node2D
class_name GridManager

# Dimensioni griglia
const GRID_WIDTH        = 100
const GRID_HEIGHT       = 100
const TILE: PackedScene = preload("uid://kbh15wp6fe5k")
var grid: Array[Array]  = []


func _ready():
	GameManager.grid_manager = self
	generate_grid()

func generate_grid():
	for x in range(GRID_WIDTH):
		var column: Array[Node2D] = []
		for y in range(GRID_HEIGHT):
			var new_tile: Tile = TILE.instantiate()
			new_tile.coords = Vector2i(x, y)
			add_child(new_tile)
			column.append(new_tile)

		grid.append(column)
