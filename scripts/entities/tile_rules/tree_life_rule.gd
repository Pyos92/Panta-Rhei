extends AbstractTileLifeRule
class_name TreeLifeRule

func evaluate_next_gen() -> void:
	tile.next_step_action = Tile.CellNextStep.LIVE
