extends Node2D

@onready var spawn_menu: SpawnMenu = %SpawnMenu

func _input(event: InputEvent) -> void:
	if event is InputEventKey and Input.is_key_pressed(KEY_F11) and not event.echo:
		GameManager.debug_mode = !GameManager.debug_mode
		GameManager.debug_mode_switched.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
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
