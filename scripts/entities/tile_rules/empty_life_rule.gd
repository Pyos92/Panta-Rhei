extends AbstractTileLifeRule
class_name EmptyLifeRule

func evaluate_next_gen() -> void:
	# Controllo se può far nascere alberi
	var flowers_2_tree1 : Array[Tile] = get_tiles_in_area(_build_flower_into_tree_search_area(Vector2i.ZERO), Tile.CellType.FLOWER)
	var flowers_2_tree2 : Array[Tile] = get_tiles_in_area(_build_flower_into_tree_search_area(Vector2i.RIGHT), Tile.CellType.FLOWER)
	var flowers_2_tree3 : Array[Tile] = get_tiles_in_area(_build_flower_into_tree_search_area(Vector2i.DOWN), Tile.CellType.FLOWER)
	var flowers_2_tree4 : Array[Tile] = get_tiles_in_area(_build_flower_into_tree_search_area(Vector2i.DOWN+Vector2i.RIGHT), Tile.CellType.FLOWER)
	if flowers_2_tree1.size() >= 4 or flowers_2_tree2.size() >= 4 or flowers_2_tree3.size() >= 4 or flowers_2_tree4.size() >= 4:
		tile.next_step_action = Tile.CellNextStep.GROW_TREE
	
	# Controllo se può far nascere fiori
	var flowers : Array[Tile] = get_tiles_in_area(PROXIMITY_SEARCH_AREA, Tile.CellType.FLOWER)
	if flowers.size() == 3:
		tile.next_step_action = Tile.CellNextStep.GROW_FLOWER

#Costruisco l'area della ricerca. Offset=0 è il punto in alto a sx
func _build_flower_into_tree_search_area(offset : Vector2i = Vector2i.ZERO) -> Array[Vector2i]:
	var search_area: Array[Vector2i] = []
	search_area.append_array([Vector2i(-1,-1),Vector2i(0,-1),Vector2i(1,-1),Vector2i(2,-1)])
	search_area.append_array([Vector2i(-1,0),                               Vector2i(2,0)])
	search_area.append_array([Vector2i(-1,1),                               Vector2i(2,1)])
	search_area.append_array([Vector2i(-1,2), Vector2i(0,2), Vector2i(1,2), Vector2i(2,2)])
	##Applica offset
	for point in search_area:
		point -= offset
	return search_area
