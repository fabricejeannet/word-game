class_name Cells
extends Node2D

var letters = []
onready var empty_case = get_node("EmptyCase")

func initialize_letters(alphabet) -> void:
	var case = self.get_node("LetterCase")
	for item in alphabet:
		var letter_case = case.duplicate()
		letter_case.text = item
		letter_case.name = "letter_%s" % item
		letters.append(letter_case)
		
