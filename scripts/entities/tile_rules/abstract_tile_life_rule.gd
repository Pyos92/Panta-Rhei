@abstract
class_name AbstractTileLifeRule extends Resource

const PROXIMITY_SEARCH_AREA: Array[Vector2i] = [
	Vector2i.UP+Vector2i.LEFT,
	Vector2i.UP,
	Vector2i.UP+Vector2i.RIGHT,
	Vector2i.LEFT,
	Vector2i.RIGHT,
	Vector2i.DOWN+Vector2i.LEFT,
	Vector2i.DOWN,
	Vector2i.DOWN+Vector2i.RIGHT
]

var tile: Tile

func _init(tile: Tile) -> void:
	self.tile = tile
	
@abstract
func evaluate_next_gen() -> void

func apply_next_gen() -> void:
	match tile.next_step_action:
		Tile.CellNextStep.DIE: tile.clear_tile()
		Tile.CellNextStep.GROW_FLOWER: tile.spawn_flower()
		Tile.CellNextStep.GROW_TREE: tile.spawn_tree()
		Tile.CellNextStep.GROW_ANIMAL: tile.spawn_animal()

func get_tiles_in_area(area : Array[Vector2i], type_filter = null) -> Array[Tile]:
	var tiles : Array[Tile] = []
	var grid : Array[Array] = GameManager.grid_manager.grid
	
	for point in area:
		var toroidal_coords: Vector2i = GameManager.Coords.to_toroidal(tile.coords + point)
		if (type_filter == null) or (type_filter != null and type_filter == grid[toroidal_coords.x][toroidal_coords.y].type):
			tiles.append(grid[toroidal_coords.x][toroidal_coords.y])
	
	var debug := false
	if debug and !tiles.is_empty():
		print(str(tile) + " ha vicino:")
		for n_tile in tiles:
			print(str(n_tile))
		print("-------")
	return tiles
