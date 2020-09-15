extends GridContainer

export var rows = 10
var cell_count:int

onready var cases = get_parent().get_node("Cases")
onready var drop_timer = get_parent().get_node("DropTimer")
onready var pop_timer = get_parent().get_node("PopTimer")


func _ready() -> void:
	cell_count = rows * columns
	empty()
	fill_with(cases.empty_case)
#	put_at_index(cases.letters[0].duplicate(), 1)
	drop_timer.start()
	pop_timer.start()
	
	
func empty() -> void:
	for child in self.get_children():
		self.remove_child(child)
		child.queue_free()
	
	
func fill_with(node) -> void:
	var index = 0
	for n in range(cell_count):
		var cell = node.duplicate()
		cell.text = "%s" % index
		add_child(cell)
		index +=1
		
		
func _on_DropTimer_timeout() -> void:
	for i in range (cell_count - 1, -1, -1):
		print("i : ", i)
		var case = self.get_child(i)
		if case.letter and !case.locked:
			drop(case)	


func drop(current_node:Case) -> void:
	var index = current_node.get_index()
	var next_index = index + 6
	
	if next_index < cell_count:
		var next_node = self.get_child(next_index)

		if !next_node.locked and !next_node.letter:
			var new_case = cases.empty_case.duplicate()
			self.add_child(new_case)
			self.remove_child(next_node)
			self.move_child(new_case, index)
			self.move_child(current_node, next_index)	
	else:	
		current_node.locked = true		
		
	
func put_at_index(cell, index) -> void:
	var cell_to_remove = self.get_child(index)
	if !cell_to_remove.letter:
		self.remove_child(cell_to_remove)
		cell_to_remove.queue_free()
		self.add_child(cell)
		self.move_child(cell, index)
	else:
		print("Chevauchement")


func _on_PopTimer_timeout() -> void:
	print("New letter")
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var index = rng.randi_range (0,5)
	var letter_index = rng.randi_range (0,25)
	
	var case = cases.letters[letter_index].duplicate()
	put_at_index(case, index)
