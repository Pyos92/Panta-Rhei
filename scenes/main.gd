extends Node2D
class_name Main

func _ready() -> void:
	GameManager.main = self
	GameManager.debug_mode_switched.connect(func(): GameManager.ui.debug_panel.visible = GameManager.debug_mode)
	
func _process(_delta: float) -> void:
	if GameManager.debug_mode:
		var tile : Tile = raycast(get_global_mouse_position())
		if tile != null:
			GameManager.ui.debug_coords.text = GameManager.Vectors.stringify_Vector2(tile.coords)
			GameManager.ui.debug_tipo.text = str(Tile.CellType.find_key(tile.type))
			GameManager.ui.debug_next_gen.text = str(Tile.CellNextStep.keys()[tile.next_step_action])

func _input(event: InputEvent) -> void:
	if event is InputEventKey and Input.is_key_pressed(KEY_F11) and not event.echo:
		GameManager.debug_mode = !GameManager.debug_mode
		GameManager.debug_mode_switched.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		var spawn_menu = GameManager.ui.spawn_menu
		if event.button_index == MOUSE_BUTTON_LEFT:
			var cell : Tile = raycast(event.position)
			if cell.is_empty():
				spawn_menu.set_cell(cell)
				spawn_menu.position = cell.global_position
				spawn_menu.visible = true
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			spawn_menu.visible = false
			
func raycast(to_position : Vector2) -> Tile:
	var query = PhysicsPointQueryParameters2D.new()
	query.position = to_position
	query.collide_with_bodies = true
	
	var results = get_world_2d().direct_space_state.intersect_point(query)
	if results.is_empty():
		return
	
	return results[0].collider

func evaluate_next_gen(preview : bool = true) -> void:
	_evaluate_tiles(Tile.CellType.FLOWER, preview)
	_evaluate_tiles(Tile.CellType.TREE, preview)
	_evaluate_tiles(Tile.CellType.ANIMAL, preview)
	_evaluate_tiles(Tile.CellType.EMPTY, preview)	
		
func go_to_next_gen() -> void:
	evaluate_next_gen(false)
		
	_apply_next_gen_to_tiles()
		
func _evaluate_tiles(type : Tile.CellType, preview : bool = false) -> void:
	for y in range(0, GameManager.grid_manager.GRID_HEIGHT):
		for x in range(0, GameManager.grid_manager.GRID_WIDTH):
			var tile : Tile = GameManager.grid_manager.get_tile_at(Vector2i(x, y))
			if tile.type == type:
				LifecycleManager.evaluate_next_gen(tile, preview)
		
func _apply_next_gen_to_tiles(type_filter = null) -> void:
	for y in range(0, GameManager.grid_manager.GRID_HEIGHT):
		for x in range(0, GameManager.grid_manager.GRID_WIDTH):
			var tile : Tile = GameManager.grid_manager.get_tile_at(Vector2i(x, y))
			if type_filter == null or tile.type == type_filter:
				LifecycleManager.apply_next_gen(tile)
