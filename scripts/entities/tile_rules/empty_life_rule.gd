extends AbstractTileLifeRule
class_name EmptyLifeRule

func evaluate_next_gen() -> void:
	var neighbors : Array[Tile] = get_neighbors(Tile.CellType.FLOWER)
	if neighbors.size() == 3:
		tile.next_step_action = Tile.CellNextStep.GROW
