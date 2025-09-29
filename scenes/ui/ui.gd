extends Control
class_name UI

@onready var spawn_menu: SpawnMenu = %SpawnMenu
#Labels conteggio entità
@onready var num_fiori: Label = %NumFiori
@onready var num_alberi: Label = %NumAlberi
@onready var num_animali: Label = %NumAnimali
#Pulsanti
@onready var step_button: Button = %Step
@onready var auto_play: Button = %AutoPlay
@onready var preview: Button = %Preview

#DEBUG
@onready var debug_panel: PanelContainer = %DebugPanel
@onready var debug_coords: Label = %DebugCoords
@onready var debug_tipo: Label = %DebugTipo
@onready var debug_next_gen: Label = %DebugNextGen


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.ui = self
	step_button.button_up.connect(step_button_action)
	auto_play.button_up.connect(autoplay_button_action)
	preview.button_up.connect(preview_button_action)

	GameManager.game_state_changed.connect(game_mode_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_label_of_type(type : Tile.CellType) -> Label:
	match type:
		Tile.CellType.FLOWER: return num_fiori
		Tile.CellType.TREE: return num_alberi
		Tile.CellType.ANIMAL: return num_animali
	return null
	
#region "Actions"
func step_button_action() -> void:
	spawn_menu.visible = false
	GameManager.main.go_to_next_gen()

func autoplay_button_action() -> void:
	spawn_menu.visible = false
	match GameManager.current_game_state:
		GameManager.GameState.MANUAL:
			GameManager.current_game_state = GameManager.GameState.AUTOMATED
		GameManager.GameState.AUTOMATED:
			GameManager.current_game_state = GameManager.GameState.MANUAL
	
func preview_button_action() -> void:
	spawn_menu.visible = false
	GameManager.main.evaluate_next_gen()
#endregion

func game_mode_changed() -> void:
	match GameManager.current_game_state:
		GameManager.GameState.MANUAL:
			auto_play.text = "Auto-Play"
			auto_play.visible = true
			step_button.visible = true
			preview.visible = true
		GameManager.GameState.AUTOMATED:
			auto_play.text = "Pause"
			auto_play.visible = true
			step_button.visible = false
			preview.visible = false
		GameManager.GameState.PREVIEW:
			auto_play.visible = false
			step_button.visible = false
			preview.visible = true
