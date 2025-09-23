extends Node2D
class_name Main

func _ready() -> void:
	GameManager.main = self

func _input(event: InputEvent) -> void:
	if event is InputEventKey and Input.is_key_pressed(KEY_F11) and not event.echo:
		GameManager.debug_mode = !GameManager.debug_mode
		GameManager.debug_mode_switched.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		var spawn_menu = GameManager.ui.spawn_menu
		if event.button_index == MOUSE_BUTTON_LEFT:
			var query = PhysicsPointQueryParameters2D.new()
			query.position = event.position
			query.collide_with_bodies = true
			
			var results = get_world_2d().direct_space_state.intersect_point(query)
			if results.is_empty():
				return
			
			var cell : Tile = results[0].collider
			if cell.is_empty():
				spawn_menu.set_cell(cell)
				spawn_menu.position = cell.global_position
				spawn_menu.visible = true
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			spawn_menu.visible = false

func go_to_next_gen() -> void:
	_evaluate_tiles(Tile.CellType.FLOWER)
	_evaluate_tiles(Tile.CellType.TREE)
	_evaluate_tiles(Tile.CellType.ANIMAL)
	_evaluate_tiles(Tile.CellType.EMPTY)
		
	_apply_next_gen_to_tiles(Tile.CellType.FLOWER)
	_apply_next_gen_to_tiles(Tile.CellType.TREE)
	_apply_next_gen_to_tiles(Tile.CellType.ANIMAL)
	_apply_next_gen_to_tiles(Tile.CellType.EMPTY)
		
func _evaluate_tiles(type : Tile.CellType) -> void:
	for tile in get_tree().get_nodes_in_group(_type_to_group(type)):
		tile.life_rule.evaluate_next_gen()
		
func _apply_next_gen_to_tiles(type : Tile.CellType) -> void:
	for tile in get_tree().get_nodes_in_group(_type_to_group(type)):
		tile.life_rule.apply_next_gen()
		
func _type_to_group(type : Tile.CellType) -> String:
	var group = null
	match type:
		Tile.CellType.EMPTY: group = GameManager.Groups.TERRAIN
		Tile.CellType.FLOWER: group = GameManager.Groups.FLOWER
		Tile.CellType.TREE: group = GameManager.Groups.TREE
		Tile.CellType.ANIMAL: group = GameManager.Groups.ANIMAL
	return group;
