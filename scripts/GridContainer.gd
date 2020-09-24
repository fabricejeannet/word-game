extends GridContainer

signal ground_touched
signal word_added

export var rows = 10

var cell_count:int
var current_letter:Case
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
	add_words(2)
	pop()
	drop_timer.start()
	
	
func add_words(n:int) -> void :
	var ref = Dico.get_random_word()
	print("-----", ref.to_upper(), "-----")
	list_of_words = Dico.get_words_with_common_letters(ref, n, 3, 5)
	var letters = []
	for word in list_of_words:
		for letter in word:
			if letters.count(letter) == 0:
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
	for i in range (cell_count - 1, -1, -1):
		var case = self.get_child(i)
		if case.letter and !case.locked:
			drop(case)	
		
	drop_timer.start(0)


func drop(current_node:Case) -> void:
	var index = current_node.get_index()
	var next_index = index + columns
	
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
	var current_column = index % columns
	if step > 0 and current_column < columns - 1 or step < 0 and current_column > 0:
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
	check()
	pop()
	
func check() -> void:
	var horz_strings = []
	var row_string = ""
	var index = 0
	for child in self.get_children():
		if !child.text.is_valid_integer(): 
			row_string = row_string + child.text
		else:
			row_string = row_string + " "
		index += 1
		if index % columns == 0:
			horz_strings.append(row_string)
			print("-->", row_string)
			row_string = ""
			
	var index_to_destroy = []			
	
	index = 0
	for row_string in horz_strings:
		var str_col = -1
		for word in list_of_words:
			str_col = row_string.find(word)
			if str_col > -1:
				var letter_index = 0
				for l in word:
					index_to_destroy.append(index + str_col+ letter_index)
					letter_index += 1
				
				print("Index to destroy :", index_to_destroy)	
				
				for i in index_to_destroy:
					var new_case = cases.empty_case.duplicate()
					new_case.text = "%s" % i
					self.add_child(new_case)
					self.remove_child(self.get_child(i))
					self.move_child(new_case, i)

		
		index += columns	

