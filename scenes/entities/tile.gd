class_name Tile
extends StaticBody2D

@onready var sprite: Sprite2D = %Sprite
@onready var coords_label: Label = %Coords

enum CellType {EMPTY = 0, FLOWER = 1, TREE = 5, ANIMAL = 10}
enum CellNextStep {IDLE, LIVE, GROW_FLOWER, GROW_TREE, GROW_TREE_BRANCHES, GROW_ANIMAL, DIE}

# Scena del terreno da istanziare
const SPRITE_EMPTY = "res://assets/sprite/tiles/grass-tile.png"
const SPRITE_FLOWER = "res://assets/sprite/tiles/fiori.png"
const SPRITE_ANIMAL = "res://assets/sprite/tiles/animal.png"
const SPRITE_TREE_1 ="res://assets/sprite/tiles/tree1.png"
const SPRITE_TREE_2 ="res://assets/sprite/tiles/tree2.png"
const SPRITE_TREE_3 ="res://assets/sprite/tiles/tree3.png"
const SPRITE_TREE_4 ="res://assets/sprite/tiles/tree4.png"

const CELL_SIZE = 32

var type := CellType.EMPTY
var sub_type := 0 #Per gli alberi serve a renderizzare gli altri quadratini
var coords := Vector2i.ZERO:
	get: return coords
	set(value): 
		coords = value
		position = Vector2i(coords.x * CELL_SIZE, coords.y * CELL_SIZE)
var next_step_action := CellNextStep.IDLE
var root_tile : Tile = null
var branch_tiles : Array[Tile] = []
var selected := false:
	get: return selected
	set(value): 
		selected = value; 
		queue_redraw()

func _ready() -> void:
	coords_label.text = str(int(coords.x)) + ", " + str(int(coords.y))
	GameManager.debug_mode_switched.connect(func(): coords_label.visible = GameManager.debug_mode)
	
func _draw() -> void:
	if selected:
		draw_rect(Rect2(Vector2(-CELL_SIZE/2, -CELL_SIZE/2), Vector2(CELL_SIZE, CELL_SIZE)), Color.BLACK, false, 1)

func clear_tile():
	if root_tile == null:
		_update_global_count(type, CellType.EMPTY)
	for branch_tile in branch_tiles:
		branch_tile.clear_tile()
	type = CellType.EMPTY
	root_tile = null
	sub_type = 0
	sprite.texture = load(SPRITE_EMPTY)
	next_step_action = CellNextStep.IDLE
	selected = false
	
func spawn_flower():
	_update_global_count(type, CellType.FLOWER)
	type = CellType.FLOWER
	sprite.texture = load(SPRITE_FLOWER)
	next_step_action = CellNextStep.IDLE
	selected = false

func spawn_tree():
	_update_global_count(type, CellType.TREE)
	_spawn_tree(self, 1)
	var t2 : Tile = GameManager.grid_manager.get_tile_at(coords, Vector2i.RIGHT)
	t2._spawn_tree(self, 2)
	branch_tiles.append(t2)
	var t3 : Tile = GameManager.grid_manager.get_tile_at(coords, Vector2i.DOWN)
	t3._spawn_tree(self, 3)
	branch_tiles.append(t3)
	var t4 : Tile = GameManager.grid_manager.get_tile_at(coords, Vector2i.DOWN+Vector2i.RIGHT)
	t4._spawn_tree(self, 4)
	branch_tiles.append(t4)
	selected = false
	
func _spawn_tree(root_tile : Tile, _sub_type : int):
	type = CellType.TREE
	self.sub_type = _sub_type
	match sub_type:
		1: sprite.texture = load(SPRITE_TREE_1)
		2: sprite.texture = load(SPRITE_TREE_2); self.root_tile = root_tile
		3: sprite.texture = load(SPRITE_TREE_3); self.root_tile = root_tile
		4: sprite.texture = load(SPRITE_TREE_4); self.root_tile = root_tile
	next_step_action = CellNextStep.IDLE
	
func spawn_animal():
	_update_global_count(type, CellType.ANIMAL)
	type = CellType.ANIMAL
	sprite.texture = load(SPRITE_ANIMAL)
	next_step_action = CellNextStep.IDLE
	selected = false
	
func set_next_step_action(action : CellNextStep):
	next_step_action = action
	# Se non ho ancora spawnato un albero, non ho branch tiles
	for branch_tile in branch_tiles:
		if next_step_action in [CellNextStep.IDLE, CellNextStep.LIVE, CellNextStep.DIE]:
			branch_tile.next_step_action = next_step_action

	if next_step_action in [CellNextStep.GROW_TREE]:
		var t2 : Tile = GameManager.grid_manager.get_tile_at(coords, Vector2i.RIGHT)
		t2.next_step_action=CellNextStep.GROW_TREE_BRANCHES
		var t3 : Tile = GameManager.grid_manager.get_tile_at(coords, Vector2i.DOWN)
		t3.next_step_action=CellNextStep.GROW_TREE_BRANCHES
		var t4 : Tile = GameManager.grid_manager.get_tile_at(coords, Vector2i.DOWN+Vector2i.RIGHT)
		t4.next_step_action=CellNextStep.GROW_TREE_BRANCHES
			
func show_next_step_action() -> void:
	match next_step_action:
		Tile.CellNextStep.DIE:
			sprite.modulate = Color.RED
		Tile.CellNextStep.GROW_TREE:
			sprite.modulate = Color.GREEN
		Tile.CellNextStep.GROW_TREE_BRANCHES:
			sprite.modulate = Color.GREEN
		Tile.CellNextStep.GROW_FLOWER:
			sprite.modulate = Color.GOLDENROD
		Tile.CellNextStep.GROW_ANIMAL:
			sprite.modulate = Color.PURPLE
		_:
			sprite.modulate = Color.WHITE
	for branch_tile in branch_tiles:
		branch_tile.sprite.modulate = sprite.modulate
		
func is_empty() -> bool:
	return type == CellType.EMPTY
func has_flower() -> bool:
	return type == CellType.FLOWER
func has_tree() -> bool:
	return type == CellType.TREE
func has_animal() -> bool:
	return type == CellType.ANIMAL
	
func _update_global_count(old_type : CellType, new_type : CellType) -> void:
	var label_old : Label = GameManager.ui.get_label_of_type(old_type)
	var label_new : Label = GameManager.ui.get_label_of_type(new_type)
	if label_old != null: label_old.text = str(int(label_old.text) - 1)
	if label_new != null: label_new.text = str(int(label_new.text) + 1)
	
func _to_string() -> String:
	var str_type : String = CellType.keys()[type]
	return str_type + "   " + GameManager.Vectors.stringify_Vector2(coords) 
