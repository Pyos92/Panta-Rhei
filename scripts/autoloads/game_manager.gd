extends Node

var debug_mode: bool

enum GameState{
	MANUAL, AUTOMATED
}
var current_game_state : GameState = GameState.MANUAL
var grid_manager : GridManager
var ui : UI

signal debug_mode_switched

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func stringify_Vector2(v : Vector2) -> String:
	if v == Vector2.UP: return "UP"
	if v == Vector2.DOWN: return "DOWN"
	if v == Vector2.LEFT: return "LEFT"
	if v == Vector2.RIGHT: return "RIGHT"
	return "(%d, %d)" % [v.x, v.y]


class Groups:
	const FLOWER = "Flower"
	const ANIMAL = "Animal"
	const TREE = "Tree"
	const TERRAIN = "Terrain"

class Notifications:

	static func show_error_message(message: String):
		"""Mostra un messaggio di errore"""
		show_toast_notification("ERRORE: " + message)

	static func show_toast_notification(message: String):
		"""Mostra una notifica toast temporanea"""
		var toast = Label.new()
		toast.text = message
		toast.add_theme_font_size_override("font_size", 15)
		toast.add_theme_color_override("font_color", Color.WHITE)
		toast.add_theme_color_override("font_shadow_color", Color.BLACK)
		toast.add_theme_constant_override("shadow_offset_x", 1)
		toast.add_theme_constant_override("shadow_offset_y", 1)
		toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		var LABEL_H := 60;
		var LABEL_W := 400;
		# Posiziona al centro dello schermo
		var screen_size = GameManager.get_tree().get_root().get_viewport().get_visible_rect().size
		var center_x = (screen_size.x - LABEL_W) / 2  # Centra i 400 pixel di larghezza
		toast.position = Vector2(center_x, screen_size.y - LABEL_H)  # 150 pixel dal basso
		toast.size = Vector2(400, LABEL_H)

		GameManager.get_tree().get_root().add_child(toast)

		# Animazione di fade out
		var tween = GameManager.create_tween()
		tween.tween_property(toast, "modulate:a", 0.0, 2.0)
		tween.tween_callback(toast.queue_free)
