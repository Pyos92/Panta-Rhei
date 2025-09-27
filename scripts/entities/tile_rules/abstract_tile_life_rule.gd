@abstract
class_name AbstractTileLifeRule

static var PROXIMITY_SEARCH_AREA = build_area(3,3)

var tile: Tile

@warning_ignore("shadowed_variable")
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
	var grid_manager : GridManager = GameManager.grid_manager
	
	for point in area:
		var _tile : Tile = grid_manager.get_tile_at(tile.coords, point)
		if (type_filter == null) or (type_filter != null and type_filter == _tile.type):
			if _tile.root_tile != null:
				_tile = _tile.root_tile
			if tiles.has(_tile):
				continue
			tiles.append(_tile)
	
	var debug := false
	if debug and !tiles.is_empty():
		print(str(tile) + " ha vicino:")
		for n_tile in tiles:
			print(str(n_tile))
		print("-------")
	return tiles
	

func count_life_elements_in_area(area : Array[Vector2i]) -> int:
	var tiles : Array[Tile] = get_tiles_in_area(area, null)
	var count = 0
	for t in tiles:
		count += t.type
	return count


#Crea un area date le dimensioni dei 2 lati e presupponendo che il cercatore sia al centro
#Nel caso l'area sia pari si applica un offset di -1
static func build_area(area_width : int, area_height : int) -> Array[Vector2i]:
	@warning_ignore("integer_division")
	var radius_x := floori(area_width / 2)
	var offset_x = (area_width % 2) -1
	@warning_ignore("integer_division")
	var radius_y := floori(area_height / 2)
	var offset_y = (area_height % 2) -1
	var search_area: Array[Vector2i] = []
	for y in range(-(radius_y + offset_y), (radius_y) + 1, 1):
		for x in range(-(radius_x + offset_x), (radius_x) + 1 , 1):
			var point := Vector2i(x,y)
			if point == Vector2i.ZERO: continue
			if offset_x == -1 and (point == Vector2i.RIGHT): continue
			if offset_y == -1 and (point == Vector2i.DOWN or point == Vector2i.RIGHT+ Vector2i.DOWN): continue
			search_area.append(point)
			
	return search_area

func _has_space_to_grow_tree() -> bool:
	var grid_manager : GridManager = GameManager.grid_manager
	var tile_right : Tile = grid_manager.get_tile_at(tile.coords, Vector2i.RIGHT)
	var tile_down : Tile = grid_manager.get_tile_at(tile.coords, Vector2i.DOWN)
	var tile_down_right : Tile = grid_manager.get_tile_at(tile.coords, Vector2i.DOWN + Vector2i.RIGHT)
	if !tile_right.is_empty() or tile_right.next_step_action != Tile.CellNextStep.IDLE: return false
	if !tile_down.is_empty() or tile_down.next_step_action != Tile.CellNextStep.IDLE: return false
	if !tile_down_right.is_empty() or tile_down_right.next_step_action != Tile.CellNextStep.IDLE: return false
	return true
