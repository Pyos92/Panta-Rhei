@abstract
class_name AbstractTileLifeRule extends Resource

var tile: Tile

func _init(tile: Tile) -> void:
	self.tile = tile
	
@abstract
func evaluate_next_gen() -> void

func apply_next_gen() -> void:
	match tile.next_step_action:
		Tile.CellNextStep.DIE: tile.clear_tile()
		Tile.CellNextStep.GROW: tile.grow(Tile.CellType.FLOWER)

func get_neighbors(type_filter = null, print : bool = false) -> Array[Tile]:
	var tiles : Array[Tile] = []
	var directions: Array[Vector2i] = [
		Vector2i.UP+Vector2i.LEFT,
		Vector2i.UP,
		Vector2i.UP+Vector2i.RIGHT,
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i.DOWN+Vector2i.LEFT,
		Vector2i.DOWN,
		Vector2i.DOWN+Vector2i.RIGHT
	]
	var grid : Array[Array] = GameManager.grid_manager.grid
	if print: print("Vicini a " +str(tile.coords.x)+","+str(tile.coords.y))
	for direction in directions:
		var toroidal_coords: Vector2i = GameManager.Coords.to_toroidal(tile.coords + direction)
		if print and !grid[toroidal_coords.x][toroidal_coords.y].is_empty(): 
			print(GameManager.Vectors.stringify_Vector2(direction)+": "+str(grid[toroidal_coords.x][toroidal_coords.y]))
		if (type_filter == null) or (type_filter != null and type_filter == grid[toroidal_coords.x][toroidal_coords.y].type):
			tiles.append(grid[toroidal_coords.x][toroidal_coords.y])
	if print: print("-------")
	return tiles
