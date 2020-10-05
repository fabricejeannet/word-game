extends GridContainer

signal ground_touched
signal word_added

export var rows = 10

var cell_count:int
var current_letter
var list_of_words = []

onready var cases = get_parent().get_node("Cases")
onready var drop_timer = get_parent().get_node("DropTimer")
onready var start_button = get_tree().get_root().find_node("StartButton", true, false)
onready var reset_button = get_tree().get_root().find_node("ResetButton", true, false)
onready var word_container = get_tree().get_root().find_node("WordContainer", true, false)


func _ready() -> void:
	cell_count = rows * columns
	reset_game()
	start_button.connect("game_started", self, "start_game")
	reset_button.connect("game_reset", self, "reset_game")
	self.connect("word_added", word_container, "on_word_added")


func reset_game() -> void:
	empty()
	fill_with(cases.empty_case)	


func start_game() -> void:
	print("Game starting !")
	add_words(3)
	pop()
	drop_timer.start()


func add_words(n:int) -> void :
	var ref = Dico.get_random_word()
	print("-----", ref.to_upper(), "-----")
	list_of_words = Dico.get_words_with_common_letters(ref, n, 4, 6)
#	list_of_words = Dico.get_words_with_common_syllable(ref, n, 2)
	var letters = []
	for word in list_of_words:
		for letter in word:
#			if letters.count(letter) == 0:
			letters.append(letter)
		emit_signal("word_added", word)
		
	cases.initialize_letters(letters)		
	print(letters)


func pop() -> void: 
	var rng = RandomNumberGenerator.new()
	rng.randomize()
#	var where_to_drop_letter = rng.randi_range (0,3)
	var where_to_drop_letter = 3
	var letter_index = rng.randi_range (0,cases.letters.size() - 1)
	current_letter = cases.letters[letter_index].duplicate()
	put_at_index(current_letter, where_to_drop_letter)


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
	for n in range(cell_count):
		var cell = node.duplicate()
		cell.text = "%s" % n
		add_child(cell)


func _on_DropTimer_timeout() -> void:
	drop_all_unlocked_cells()
	drop_timer.start(0)


func drop_all_unlocked_cells() -> void:
	for i in range (cell_count - 1, -1, -1):
		var cell = self.get_child(i)
		if cell.is_a_letter() and cell.is_unlocked():
			drop(cell)	


func drop(this_cell) -> void:
	var index = this_cell.get_index()
	var next_index = index + columns
	
	if next_index < cell_count:
		var next_cell = self.get_child(next_index)
		if next_cell.is_unlocked() or next_cell.is_not_a_letter():
			move (this_cell, index, next_cell, next_index)
		else :
			stop_cell(this_cell)
	else:	
		stop_cell(this_cell)


func stop_cell(this_cell) -> void:
		this_cell.lock()
		check()
		if this_cell == current_letter:
			pop()


func side_move(this_cell, step:int) -> void:
	var index = this_cell.get_index()
	var next_index = index + step
	var current_column = index % columns
	if step > 0 and current_column < columns - 1 or step < 0 and current_column > 0:
		if next_index < cell_count:
			var next_cell = self.get_child(next_index)
			if next_cell.is_unlocked() and next_cell.is_not_a_letter():
				move (this_cell, index, next_cell, next_index)

	
func move(this_cell, index, next_cell, next_index) -> void :
	var new_case = cases.empty_case.duplicate()
	new_case.text = "%s" % index
	self.add_child(new_case)
	self.remove_child(next_cell)
	self.move_child(new_case, index)
	self.move_child(this_cell, next_index)	
	
	
func replace_with_empty_cell(i) -> void:
	var new_case = cases.empty_case.duplicate()
	new_case.text = "%s" % i
	self.add_child(new_case)
	self.remove_child(self.get_child(i))
	self.move_child(new_case, i)
	
	
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


func check() -> void:
	var horz_strings = []
	var row_string = ""
	var index = 0
	print ("\n---- GRID ----\n")
	
	for child in self.get_children():
		if !child.text.is_valid_integer(): 
			row_string = row_string + child.text
		else:
			row_string = row_string + "."
		index += 1
		if index % columns == 0:
			horz_strings.append(row_string)
#			print("-->\t", row_string)
			row_string = ""
			
	index = 0
	for row_string in horz_strings:
		var str_col = -1
		for word in list_of_words:
			str_col = row_string.find(word)
			if str_col > -1:
				var letter_index = 0
				var index_to_destroy = []				
				for l in word:
					index_to_destroy.append(index + str_col+ letter_index)
					letter_index += 1
				
				print("Index to destroy :", index_to_destroy)	
				
				for this_index in index_to_destroy:
					replace_with_empty_cell(this_index)
					var index_of_cell_above = this_index - columns
					if  index_of_cell_above >= 0:
						self.get_child(index_of_cell_above).unlock()
				
				unlock_all_cells()
				drop_all_unlocked_cells()				
		index += columns	


func unlock_all_cells() -> void:
	for cell in self.get_children():
		cell.unlock()
		
