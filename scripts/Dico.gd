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


func get_words_with_common_letters(reference_word:String, words_count:int, common_letters_count:int) -> Array:
	var words_to_return = []
	
	while words_to_return.size() < words_count:
		var tested_word = get_random_word().to_upper()
		print("Testing ", tested_word, "...")
		if tested_word.length() >= common_letters_count:
			var clc = 0
			for c in reference_word.to_upper():
				if tested_word.count(c) > 0:
					clc+= 1
			if clc >= common_letters_count:
				words_to_return.append(tested_word)
				print("\t-> Accepted")
			else:
				print("\t-> Rejected cause only have ", clc, " out of ", common_letters_count, " expected common letters")
		else:
			print("Rejected because too short.")	
	
	return words_to_return
	
	
	
func get_random_word() -> String:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var index = rng.randi_range (0,words.size() - 1)
	return words[index]
