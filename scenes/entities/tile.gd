class_name Tile
extends StaticBody2D

@onready var sprite: Sprite2D = %Sprite
@onready var coords_label: Label = %Coords

enum CellType {EMPTY = 0, FLOWER = 1, TREE = 5, ANIMAL = 10}
enum CellNextStep {IDLE, LIVE, GROW_FLOWER, GROW_TREE, GROW_ANIMAL, DIE}

# Scena del terreno da istanziare
const SPRITE_EMPTY = "res://assets/sprite/grass-tile.png"
const SPRITE_FLOWER = "res://assets/sprite/fiori.png"
const SPRITE_ANIMAL = "res://assets/sprite/animal.png"
const SPRITE_TREE ="res://assets/sprite/tree.png"
const SPRITE_TREE_1 ="res://assets/sprite/tree1.png"
const SPRITE_TREE_2 ="res://assets/sprite/tree2.png"
const SPRITE_TREE_3 ="res://assets/sprite/tree3.png"
const SPRITE_TREE_4 ="res://assets/sprite/tree4.png"

const CELL_SIZE = 32

var type := CellType.EMPTY
var sub_type := 0 #Per gli alberi serve a renderizzare gli altri quadratini
var coords := Vector2i.ZERO:
	get: return coords
	set(value): 
		coords = value
		position = Vector2i(coords.x * CELL_SIZE, coords.y * CELL_SIZE)
var next_step_action := CellNextStep.IDLE
var life_rule : AbstractTileLifeRule = null
var root_tile : Tile = null

func _ready() -> void:
	clear_tile()
	coords_label.text = str(int(coords.x)) + ", " + str(int(coords.y))
	GameManager.debug_mode_switched.connect(func(): coords_label.visible = GameManager.debug_mode)
	
func clear_tile():
	if type == CellType.TREE:
		clear_tree()
	else:
		type = CellType.EMPTY
		sprite.texture = load(SPRITE_EMPTY)
		next_step_action = CellNextStep.IDLE
		life_rule = EmptyLifeRule.new(self)
		_switch_group(GameManager.Groups.TERRAIN)
	
#Va chiamato sempre e solo sulla tile principale
func clear_tree():
	type = CellType.EMPTY
	clear_tile()
	var t2 : Tile = GameManager.grid_manager.get_tile_at(coords, Vector2i.RIGHT)
	t2.type = CellType.EMPTY
	t2.clear_tile()
	var t3 : Tile = GameManager.grid_manager.get_tile_at(coords, Vector2i.DOWN)
	t3.type = CellType.EMPTY
	t3.clear_tile()
	var t4 : Tile = GameManager.grid_manager.get_tile_at(coords, Vector2i.DOWN+Vector2i.RIGHT)
	t4.type = CellType.EMPTY
	t4.clear_tile()
	
func spawn_flower():
	type = CellType.FLOWER
	sprite.texture = load(SPRITE_FLOWER)
	next_step_action = CellNextStep.IDLE
	life_rule = FlowerLifeRule.new(self)
	_switch_group(GameManager.Groups.FLOWER)

func spawn_tree():
	_spawn_tree(self, 1)
	GameManager.grid_manager.get_tile_at(coords, Vector2i.RIGHT)._spawn_tree(self, 2)
	GameManager.grid_manager.get_tile_at(coords, Vector2i.DOWN)._spawn_tree(self, 3)
	GameManager.grid_manager.get_tile_at(coords, Vector2i.DOWN+Vector2i.RIGHT)._spawn_tree(self, 4)
	next_step_action = CellNextStep.IDLE
	life_rule = TreeLifeRule.new(self)
	_switch_group(GameManager.Groups.TREE)
	
func _spawn_tree(root_tile : Tile, _sub_type : int):
	type = CellType.TREE
	self.sub_type = _sub_type
	match sub_type:
		1: sprite.texture = load(SPRITE_TREE_1)
		2: sprite.texture = load(SPRITE_TREE_2); self.root_tile = root_tile
		3: sprite.texture = load(SPRITE_TREE_3); self.root_tile = root_tile
		4: sprite.texture = load(SPRITE_TREE_4); self.root_tile = root_tile
		_: sprite.texture = load(SPRITE_TREE)
	next_step_action = CellNextStep.IDLE
	
func spawn_animal():
	type = CellType.ANIMAL
	sprite.texture = load(SPRITE_ANIMAL)
	next_step_action = CellNextStep.IDLE
	life_rule = AnimalLifeRule.new(self)
	_switch_group(GameManager.Groups.ANIMAL)
	
func _switch_group(group : String):
	remove_from_group(GameManager.Groups.TERRAIN)
	remove_from_group(GameManager.Groups.FLOWER)
	remove_from_group(GameManager.Groups.TREE)
	remove_from_group(GameManager.Groups.ANIMAL)
	add_to_group(group)
	
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
	return str_type + "   " + GameManager.Vectors.stringify_Vector2(coords) 
