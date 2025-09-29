extends Button

var cumulative_delta : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(on_pressed)
	
func _process(delta: float) -> void:
	match GameManager.current_game_state:
		GameManager.GameState.MANUAL:
			return
		GameManager.GameState.AUTOMATED:
			var now_tick = Time.get_datetime_dict_from_system()
			cumulative_delta += delta
			if cumulative_delta > 1:
				cumulative_delta = 0
				GameManager.main.go_to_next_gen()

func on_pressed() -> void:
	match GameManager.current_game_state:
		GameManager.GameState.MANUAL:
			text = "Pause"
			GameManager.current_game_state = GameManager.GameState.AUTOMATED
		GameManager.GameState.AUTOMATED:
			text = "Auto-Play"
			GameManager.current_game_state = GameManager.GameState.MANUAL
	GameManager.ui.spawn_menu.visible = false
