extends AbstractTileLifeRule
class_name TreeLifeRule

var TREE_SEARCH_AREA : Array[Vector2i]:
	get: return _build_tree_search_area()
	
func evaluate_next_gen() -> void:
	var trees : Array[Tile] = get_tiles_in_area(TREE_SEARCH_AREA, Tile.CellType.TREE)
	if trees.size() in [1,2,3]:
		tile.next_step_action = Tile.CellNextStep.LIVE
	else:
		tile.next_step_action = Tile.CellNextStep.DIE #Morte per solitudine o sovrappopolamento
	
#Crea un'area 9x9 per la ricerca degli alberi
func _build_tree_search_area() -> Array[Vector2i]:
	var search_area: Array[Vector2i] = []
	for y in range(-4,4):
		for x in range(-4,4):
			search_area.append(Vector2i(x, y))
	return search_area
