extends AbstractTileLifeRule
class_name TreeLifeRule

static var TREE_SEARCH_GROW_AREA = build_area(4,4)
static var TREE_SEARCH_AREA = build_area(9,9)

func evaluate_next_gen(tile_to_evaluate: Tile) -> void:
	var trees : Array[Tile] = get_tiles_in_area(tile_to_evaluate, TREE_SEARCH_AREA, Tile.CellType.TREE)
	if trees.size() > 0 and trees.size() < 4:
		tile_to_evaluate.set_next_step_action(Tile.CellNextStep.LIVE)
	else:
		tile_to_evaluate.set_next_step_action(Tile.CellNextStep.DIE) #Morte per solitudine o sovrappopolamento
	
