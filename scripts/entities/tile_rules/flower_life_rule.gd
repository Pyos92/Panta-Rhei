extends AbstractTileLifeRule
class_name FlowerLifeRule

func evaluate_next_gen() -> void:
	var neighbors : Array[Tile] = get_tiles_in_area(PROXIMITY_SEARCH_AREA, Tile.CellType.FLOWER)
	if neighbors.size() in [2,3]:
		tile.next_step_action = Tile.CellNextStep.LIVE
	else:
		tile.next_step_action = Tile.CellNextStep.DIE #Morte per solitudine o sovrappopolamento
