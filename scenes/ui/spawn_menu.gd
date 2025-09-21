extends Control
class_name SpawnMenu

@onready var spawn_flower: Button = $VBoxContainer/SpawnFlower
@onready var spawn_tree: Button = $VBoxContainer/SpawnTree
@onready var spawn_animal: Button = $VBoxContainer/SpawnAnimal

var cell : Terreno

func _ready() -> void:
	spawn_flower.pressed.connect(spawn_flower_bt)
	spawn_tree.pressed.connect(spawn_tree_bt)
	spawn_animal.pressed.connect(spawn_animal_bt)

func set_cell(cell : Terreno) -> void:
	self.cell = cell

func spawn_flower_bt():
	cell.spawn_flower()
	self.visible = false
	
func spawn_tree_bt():
	cell.spawn_tree(1) 
	var grid : Array[Array] = cell.get_parent().grid_sprites
	grid[cell.coords.y][cell.coords.x+1].spawn_tree(2) 
	grid[cell.coords.y+1][cell.coords.x].spawn_tree(3) 
	grid[cell.coords.y+1][cell.coords.x+1].spawn_tree(4) 
	self.visible = false
	
func spawn_animal_bt():
	cell.spawn_animal() 
	self.visible = false
