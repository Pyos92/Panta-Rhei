extends AbstractTileLifeRule
class_name AnimalLifeRule

static var ANIMAL_SEARCH_AREA = build_area(13,13)

func evaluate_next_gen(tile_to_evaluate: Tile) -> void:
	var neighbors_animals : Array[Tile] = get_tiles_in_area(tile_to_evaluate,ANIMAL_SEARCH_AREA, Tile.CellType.ANIMAL)
	if neighbors_animals.size() < 3 or (count_life_elements_in_area(tile_to_evaluate, ANIMAL_SEARCH_AREA) >= 10):
		tile_to_evaluate.set_next_step_action(Tile.CellNextStep.LIVE)
	else:
		tile_to_evaluate.set_next_step_action(Tile.CellNextStep.DIE) #Morte per solitudine o sovrappopolamento

func apply_next_gen(tile_to_apply: Tile) -> void:
	if Tile.CellNextStep.DIE:
		tile_to_apply.clear_tile()
		if _has_space_to_grow_tree(tile_to_apply):
			tile_to_apply.spawn_tree()
			var flower_ring : Array[Tile] = get_tiles_in_area(tile_to_apply,TreeLifeRule.TREE_SEARCH_GROW_AREA, Tile.CellType.EMPTY)
			for _tile in flower_ring:
				if _tile.next_step_action == Tile.CellNextStep.IDLE:
					_tile.spawn_flower()
