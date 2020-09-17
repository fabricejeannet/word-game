extends GridContainer

signal ground_touched

export var rows = 10

var cell_count:int
var current_letter:Case

onready var cases = get_parent().get_node("Cases")
onready var drop_timer = get_parent().get_node("DropTimer")

func _ready() -> void:
	cell_count = rows * columns
	empty()
	fill_with(cases.empty_case)
	pop()
	
	var ref = Dico.get_random_word()
	print("-----", ref.to_upper(), "-----")
	var refs = Dico.get_words_with_common_letters(ref, 3, 3)
	for w in refs:
		print(w)
		
	drop_timer.start()
	
	
func pop() -> void: 
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var index = rng.randi_range (0,5)
	var letter_index = rng.randi_range (0,25)
	current_letter = cases.letters[letter_index].duplicate()
	put_at_index(current_letter, index)
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		move_left()
	if event.is_action_pressed("ui_right"):
		move_right()
	if event.is_action_pressed("ui_down"):
		drop(current_letter)	
		
		
func move_left() -> void:
	side_move(current_letter, -1)

	
func move_right() -> void:
	side_move(current_letter, 1)

	
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
		var case = self.get_child(i)
		if case.letter and !case.locked:
			drop(case)	
		
	drop_timer.start(0)


func drop(current_node:Case) -> void:
	var index = current_node.get_index()
	var next_index = index + 6
	
	if next_index < cell_count:
		var next_node = self.get_child(next_index)
		if !next_node.locked or !next_node.letter:
			move (current_node, index, next_node, next_index)
		else :
			current_node.locked = true	
			emit_signal("ground_touched")		
	else:	
		current_node.locked = true	
		emit_signal("ground_touched")	
		
		
func side_move(current_node:Case, step:int) -> void:
	var index = current_node.get_index()
	var next_index = index + step
	var current_column = index % 6
	if step > 0 and current_column < 5 or step < 0 and current_column > 0:
		if next_index < cell_count:
			var next_node = self.get_child(next_index)
			if !next_node.locked and !next_node.letter:
				move (current_node, index, next_node, next_index)

	
func move(current_node, index, next_node, next_index) -> void :
	var new_case = cases.empty_case.duplicate()
	new_case.text = "%s" % index
	self.add_child(new_case)
	self.remove_child(next_node)
	self.move_child(new_case, index)
	self.move_child(current_node, next_index)	
	
func put_at_index(cell, index) -> void:
	if index >= 0 and index < columns :
		var cell_to_remove = self.get_child(index)
		if !cell_to_remove.letter:
			self.remove_child(cell_to_remove)
			cell_to_remove.queue_free()
			self.add_child(cell)
			self.move_child(cell, index)
		else:
			print("Chevauchement")


func _on_ground_touched() -> void:
	pop()
