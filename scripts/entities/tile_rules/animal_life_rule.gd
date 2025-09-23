extends AbstractTileLifeRule
class_name AnimalLifeRule

func evaluate_next_gen() -> void:
	tile.next_step_action = Tile.CellNextStep.LIVE
