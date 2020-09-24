extends Button

signal game_reset

func _on_StartButton_pressed() -> void:
	print("Reset Button pressed")
	emit_signal("game_reset")
