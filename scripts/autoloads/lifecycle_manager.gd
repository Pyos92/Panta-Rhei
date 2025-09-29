extends Node

var RULES : Dictionary[Tile.CellType, AbstractTileLifeRule] = {
	Tile.CellType.EMPTY: EmptyLifeRule.new(),
	Tile.CellType.FLOWER: FlowerLifeRule.new(),
	Tile.CellType.TREE: TreeLifeRule.new(),
	Tile.CellType.ANIMAL: AnimalLifeRule.new()
}

func evaluate_next_gen(tile_to_evaluate : Tile, preview : bool = false) -> void:
	RULES[tile_to_evaluate.type].evaluate_next_gen(tile_to_evaluate)
	if preview:
		tile_to_evaluate.show_next_step_action()
	
func apply_next_gen(tile_to_evaluate : Tile) -> void:
	RULES[tile_to_evaluate.type].apply_next_gen(tile_to_evaluate)
	tile_to_evaluate.show_next_step_action()
