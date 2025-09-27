extends AbstractTileLifeRule
class_name FlowerLifeRule

func evaluate_next_gen(tile_to_evaluate: Tile) -> void:
	var neighbors : Array[Tile] = get_tiles_in_area(tile_to_evaluate, PROXIMITY_SEARCH_AREA, Tile.CellType.FLOWER)
	if neighbors.size() in [2,3]:
		tile_to_evaluate.set_next_step_action(Tile.CellNextStep.LIVE)
	else:
		tile_to_evaluate.set_next_step_action(Tile.CellNextStep.DIE) #Morte per solitudine o sovrappopolamento
