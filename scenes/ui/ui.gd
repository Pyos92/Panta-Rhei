extends Control
class_name UI

@onready var step_button: Button = %Step
@onready var spawn_menu: SpawnMenu = %SpawnMenu
@onready var num_fiori: Label = %NumFiori
@onready var num_alberi: Label = %NumAlberi
@onready var num_animali: Label = %NumAnimali


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.ui = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_label_of_type(type : Tile.CellType) -> Label:
	match type:
		Tile.CellType.FLOWER: return num_fiori
		Tile.CellType.TREE: return num_alberi
		Tile.CellType.ANIMAL: return num_animali
	return null
