class_name Terreno
extends StaticBody2D

enum CellType {EMPTY, FLOWER, TREE, ANIMAL}

var type := CellType.EMPTY
var sub_type := 0
var queued_action := -1
var coords : Vector2 

# Scena del terreno da istanziare
const SPRITE_EMPTY = "res://assets/sprite/grass-tile.png"
const SPRITE_FLOWER = "res://assets/sprite/fiori.png"
const SPRITE_ANIMAL = "res://assets/sprite/animal.png"
const SPRITE_TREE ="res://assets/sprite/tree.png"
const SPRITE_TREE_1 ="res://assets/sprite/tree1.png"
const SPRITE_TREE_2 ="res://assets/sprite/tree2.png"
const SPRITE_TREE_3 ="res://assets/sprite/tree3.png"
const SPRITE_TREE_4 ="res://assets/sprite/tree4.png"

func _ready() -> void:
	$Sprite.texture = load(SPRITE_EMPTY)
	
func _process(delta: float) -> void:
	match type:
		CellType.EMPTY: $Sprite.texture = load(SPRITE_EMPTY)
		CellType.FLOWER: $Sprite.texture = load(SPRITE_FLOWER)
		CellType.TREE: 
			match sub_type:
				1: $Sprite.texture = load(SPRITE_TREE_1)
				2: $Sprite.texture = load(SPRITE_TREE_2)
				3: $Sprite.texture = load(SPRITE_TREE_3)
				4: $Sprite.texture = load(SPRITE_TREE_4)
				_: $Sprite.texture = load(SPRITE_TREE)
		CellType.ANIMAL: $Sprite.texture = load(SPRITE_ANIMAL)


func clear_tile():
	type = CellType.EMPTY
	queued_action = -1
	
func spawn_flower():
	type = CellType.FLOWER
	queued_action = -1
	
func spawn_tree(sub_type : int):
	type = CellType.TREE
	self.sub_type = sub_type
	queued_action = -1
	
func spawn_animal():
	type = CellType.ANIMAL
	queued_action = -1
	
func is_empty() -> bool:
	return type == CellType.EMPTY
func has_flower() -> bool:
	return type == CellType.FLOWER
func has_tree() -> bool:
	return type == CellType.TREE
func has_animal() -> bool:
	return type == CellType.ANIMAL
