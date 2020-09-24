extends VBoxContainer

onready var word_label = get_node("WordLabel")

func _ready() -> void:
	self.remove_child(word_label)

func on_word_added(word:String) -> void:
	var label = word_label.duplicate()
	label.text = word
	label.name = "label_%s" % word
	print (label.name, " added.")
	self.add_child(label)
	
func on_word_removed(word:String) -> void:
	var label = get_node("label_%s" % word)
	self.remove_child(label)
	label.queue_free()
