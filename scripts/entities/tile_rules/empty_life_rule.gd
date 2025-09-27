extends AbstractTileLifeRule
class_name EmptyLifeRule

func evaluate_next_gen() -> void:
	if tile.next_step_action != Tile.CellNextStep.IDLE: 
		return
	# Controllo se può far nascere alberi
	var flowers_2_tree : Array[Tile] = get_tiles_in_area(TreeLifeRule.TREE_SEARCH_GROW_AREA, Tile.CellType.FLOWER)
	if flowers_2_tree.size() >= 4 and _has_space_to_grow_tree():
		tile.set_next_step_action(Tile.CellNextStep.GROW_TREE)
		return
	
	# Controllo se può far nascere fiori
	var flowers : Array[Tile] = get_tiles_in_area(PROXIMITY_SEARCH_AREA, Tile.CellType.FLOWER)
	if flowers.size() == 3:
		tile.set_next_step_action(Tile.CellNextStep.GROW_FLOWER)
		return
	
	#Conto gli elementi vitali e ignoro lo spawn di animali se nell'area sta già per nascerne 1
	var tiles : Array[Tile] = get_tiles_in_area(AnimalLifeRule.ANIMAL_SEARCH_AREA, null)
	var count = 0
	for t in tiles: 
		if t.next_step_action == Tile.CellNextStep.GROW_ANIMAL: 
			count = -1
			break
		count += t.type
	if count >= 30:
		tile.set_next_step_action(Tile.CellNextStep.GROW_ANIMAL)
		return
