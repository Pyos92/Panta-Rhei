class_name Tile
extends StaticBody2D

@onready var sprite: Sprite2D = %Sprite
@onready var coords_label: Label = %Coords

enum CellType {EMPTY, FLOWER, TREE, ANIMAL}
enum CellNextStep {IDLE, THRIVE, GROW, DIE}

# Scena del terreno da istanziare
const SPRITE_EMPTY = "res://assets/sprite/grass-tile.png"
const SPRITE_FLOWER = "res://assets/sprite/fiori.png"
const SPRITE_ANIMAL = "res://assets/sprite/animal.png"
const SPRITE_TREE ="res://assets/sprite/tree.png"
const SPRITE_TREE_1 ="res://assets/sprite/tree1.png"
const SPRITE_TREE_2 ="res://assets/sprite/tree2.png"
const SPRITE_TREE_3 ="res://assets/sprite/tree3.png"
const SPRITE_TREE_4 ="res://assets/sprite/tree4.png"

var type := CellType.EMPTY
var sub_type := 0 #Per gli alberi serve a renderizzare gli altri quadratini
var coords := Vector2i.ZERO
var next_step_action := CellNextStep.IDLE

func _ready() -> void:
	sprite.texture = load(SPRITE_EMPTY)
	coords_label.text = str(int(coords.x)) + ", " + str(int(coords.y))
	GameManager.debug_mode_switched.connect(func(): coords_label.visible = GameManager.debug_mode)
	
func _process(delta: float) -> void:
	pass
	
func can_grow(growth_type : CellType) -> bool:
	if next_step_action == Tile.CellNextStep.IDLE and is_empty():
		return true
	else: 
		return false
	
func grow(growth_type : CellType):
	match growth_type:
		CellType.FLOWER: 
			spawn_flower()
		CellType.TREE:
			spawn_tree()
		CellType.ANIMAL: 
			spawn_animal()
		_: pass

func clear_tile():
	type = CellType.EMPTY
	sprite.texture = load(SPRITE_EMPTY)
	next_step_action = CellNextStep.IDLE
	
func spawn_flower():
	type = CellType.FLOWER
	sprite.texture = load(SPRITE_FLOWER)
	next_step_action = CellNextStep.IDLE

func spawn_tree():
	type = CellType.TREE
	_spawn_tree(1)
	var grid : Array[Array] = GameManager.grid_manager.grid
	grid[coords.x+1][coords.y]._spawn_tree(2)
	grid[coords.x][coords.y+1]._spawn_tree(3)
	grid[coords.x+1][coords.y+1]._spawn_tree(4)
	next_step_action = CellNextStep.IDLE
	
func _spawn_tree(_sub_type : int):
	type = CellType.TREE
	self.sub_type = _sub_type
	match sub_type:
		1: sprite.texture = load(SPRITE_TREE_1)
		2: sprite.texture = load(SPRITE_TREE_2)
		3: sprite.texture = load(SPRITE_TREE_3)
		4: sprite.texture = load(SPRITE_TREE_4)
		_: sprite.texture = load(SPRITE_TREE)
	next_step_action = CellNextStep.IDLE
	
func spawn_animal():
	type = CellType.ANIMAL
	sprite.texture = load(SPRITE_ANIMAL)
	next_step_action = CellNextStep.IDLE
	
func is_empty() -> bool:
	return type == CellType.EMPTY
func has_flower() -> bool:
	return type == CellType.FLOWER
func has_tree() -> bool:
	return type == CellType.TREE
func has_animal() -> bool:
	return type == CellType.ANIMAL
	
func _to_string() -> String:
	var str_type : String = CellType.keys()[type]
	return str_type + "   " + GameManager.stringify_Vector2(coords) 
