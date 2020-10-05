class_name Cell
extends Label

var is_being_destroyed = false

export var letter = true
export var locked = true

func _ready() -> void:
	pass # Replace with function body.

func lock() -> void:
	locked = true
	
func unlock() -> void:
	locked = false
	
func is_locked() -> bool:
	return locked == true

func is_unlocked() -> bool:
	return locked == false
	
func is_a_letter() -> bool:
	return letter == true

func is_not_a_letter() -> bool:
	return letter == false
		
#func _physics_process(delta: float) -> void:
#	if is_being_destroyed:
#		self.
