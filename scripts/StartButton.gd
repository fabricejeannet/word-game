extends Button

signal game_started

func _on_StartButton_pressed() -> void:
	print("Start Button pressed")
	emit_signal("game_started")
