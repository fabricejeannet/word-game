extends Node

var words = []
var dictionnary_path = "res://assets/json/words.json"

func _init() -> void:
	var file = File.new()
	if not file.file_exists(dictionnary_path):
		print("Missing dictionnary json file.")
	else :
		file.open(dictionnary_path, File.READ)
		var text = file.get_as_text()
		var parsed_json = JSON.parse(text)
		if typeof(parsed_json.result) == TYPE_ARRAY:
			words = parsed_json.result
			print("Dictionnary loaded")
		else:
			print("unexpected results")
	
		file.close()


func get_words_with_common_letters(reference_word:String, words_count:int, common_letters_count:int, word_max_size = 6) -> Array:
	var words_to_return = []
	
	while words_to_return.size() < words_count:
		var tested_word = get_random_word().to_upper()
#		print("Testing ", tested_word, "...")
		if tested_word.length() <= word_max_size:
			if tested_word.length() >= common_letters_count:
				var clc = 0
				for c in reference_word.to_upper():
					if tested_word.count(c) > 0:
						clc+= 1
				if clc >= common_letters_count:
					words_to_return.append(tested_word)
#					print("\t-> Accepted")
#				else:
#					print("\t-> Rejected cause only have ", clc, " out of ", common_letters_count, " expected common letters")
#			else:
#				print("Rejected because too short.")	
#		else:
#			print("Rejected because to long")
#
	return words_to_return
	
	
#func get_words_with_common_syllable(reference_word:String, words_count:int, common_syllable_count:int, word_min_size = 6) -> Array:
#	var words_to_return = []
#
#	while words_to_return.size() < words_count:
#		var tested_word = get_random_word().to_upper()
#		print("Testing ", tested_word, "...")
#		if tested_word.length() >= word_min_size:
#			var csc = 0
#			for i in range (0, reference_word.length() - 2):
#				var syllabe = reference_word.substr(i, 2)
#				print("Looking for [", syllabe, "]")
#				if tested_word.count(syllabe) > 0:
#					csc+= 1
#
#			print("Found ", csc, " times")		
#			if csc >= common_syllable_count:
#				print ("[OK] ", tested_word, " added to list")
#				words_to_return.append(tested_word)
#			else:
#				print ("[ERROR]", tested_word,  " rejected")
##
#	return words_to_return
	
func get_random_word() -> String:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var index = rng.randi_range (0,words.size() - 1)
	return words[index]
