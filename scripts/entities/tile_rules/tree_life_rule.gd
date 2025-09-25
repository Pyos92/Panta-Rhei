extends AbstractTileLifeRule
class_name TreeLifeRule

static var TREE_SEARCH_AREA = build_area(4,4)

func evaluate_next_gen() -> void:
	var trees : Array[Tile] = get_tiles_in_area(TREE_SEARCH_AREA, Tile.CellType.TREE)
	if trees.size() in [1,2,3]:
		tile.next_step_action = Tile.CellNextStep.LIVE
	else:
		tile.next_step_action = Tile.CellNextStep.DIE #Morte per solitudine o sovrappopolamento
	
