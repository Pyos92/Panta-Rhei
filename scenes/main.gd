extends Node2D

@onready var spawn_menu: SpawnMenu = %SpawnMenu

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and  event.is_released():
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Crea query per point intersection
			var query = PhysicsPointQueryParameters2D.new()
			query.position = event.position
			query.collide_with_bodies = true
			
			# Esegui la query
			var results = get_world_2d().direct_space_state.intersect_point(query)
			if results.is_empty():
				return
			
			var cell : Terreno = results[0]["collider"]
			spawn_menu.set_cell(cell)
			spawn_menu.position = cell.global_position
			spawn_menu.visible = true
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			spawn_menu.visible = false
