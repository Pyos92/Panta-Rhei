extends Control
class_name UI

@onready var step_button: Button = %Step
@onready var spawn_menu: SpawnMenu = %SpawnMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.ui = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
