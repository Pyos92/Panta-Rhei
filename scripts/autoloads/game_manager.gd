extends Node

var debug_mode: bool
var dev_mode := false

enum GameState{
	MANUAL, AUTOMATED, PREVIEW
}
var current_game_state : GameState = GameState.MANUAL:
	get:
		return current_game_state
	set(value):
		current_game_state = value
		game_state_changed.emit()
var grid_manager : GridManager
var main : Main
var ui : UI

var _cumulative_delta : float = 0

var last_selected_tile : Tile = null

signal debug_mode_switched
signal game_state_changed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	match current_game_state:
		GameState.MANUAL:
			return
		GameState.AUTOMATED:
			_cumulative_delta += _delta
			if _cumulative_delta > 1:
				_cumulative_delta = 0
				main.go_to_next_gen()

	
class Coords:
	static func to_toroidal(input_coords: Vector2i) -> Vector2i:
		var toroidal := input_coords
		if toroidal.x < 0: toroidal.x = GameManager.grid_manager.GRID_WIDTH -1
		if toroidal.x > GameManager.grid_manager.GRID_WIDTH-1: toroidal.x = 0
		if toroidal.y < 0: toroidal.y = GameManager.grid_manager.GRID_HEIGHT -1
		if toroidal.y > GameManager.grid_manager.GRID_HEIGHT-1: toroidal.y = 0
		return toroidal;
		
class Vectors:
	static func stringify_Vector2(v : Vector2i) -> String:
		if v == Vector2i.UP: return "UP"
		if v == Vector2i.UP+Vector2i.LEFT: return "UP-LEFT"
		if v == Vector2i.UP+Vector2i.RIGHT: return "UP-RIGHT"
		if v == Vector2i.DOWN: return "DOWN"
		if v == Vector2i.DOWN+Vector2i.LEFT: return "DOWN-LEFT"
		if v == Vector2i.DOWN+Vector2i.RIGHT: return "DOWN-RIGHT"
		if v == Vector2i.LEFT: return "LEFT"
		if v == Vector2i.RIGHT: return "RIGHT"
		return "(%d, %d)" % [v.x, v.y]

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
		toast.position = Vector2i(center_x, screen_size.y - LABEL_H)  # 150 pixel dal basso
		toast.size = Vector2i(400, LABEL_H)

		GameManager.get_tree().get_root().add_child(toast)

		# Animazione di fade out
		var tween = GameManager.create_tween()
		tween.tween_property(toast, "modulate:a", 0.0, 2.0)
		tween.tween_callback(toast.queue_free)
