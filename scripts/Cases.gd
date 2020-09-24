class_name Cases
extends Node2D

var letters = []
onready var empty_case = get_node("EmptyCase")

#func _ready() -> void:	
#	initialize_letters()


#func initialize_letters() -> void:
#	var alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
#	var case = self.get_node("LetterCase")
#	for item in alphabet:
#		var letter_case = case.duplicate()
#		letter_case.text = item
#		letter_case.name = "letter_%s" % item
#		letters.append(letter_case)
		
func initialize_letters(alphabet) -> void:
	var case = self.get_node("LetterCase")
	for item in alphabet:
		var letter_case = case.duplicate()
		letter_case.text = item
		letter_case.name = "letter_%s" % item
		letters.append(letter_case)
		
