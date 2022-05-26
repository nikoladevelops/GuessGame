extends "res://Scenes/GameLogic.gd"

func _ready():
	pass # Replace with function body.

func _loadDataFromDb():
	""" get all publishedworks' ids and names -> saves it in a dictionary """
	db.query("SELECT Id, Name FROM PublishedWorks;");
	
	""" get a random publishedwork"""
	var randomNumber = randi() % db.query_result.size();
	var randomPublishedWork = db.query_result[randomNumber];
	
	$Control/QuestionLabel.text='Какъв е жанрът на произведението ' + randomPublishedWork["Name"]+ "?";
	
	"""get all genres -> saves it into a dictionary"""
	db.query("SELECT * FROM Genres");
	
	"""add every genre's name into the genrelist"""
	for i in range(0, db.query_result.size()):
		$Control2/EntityList.add_item(db.query_result[i]["Name"]);
	print(db.query_result.size());
	
	"""get all genre ids of a particular publishedwork"""
	var publishedWorkId = str(randomPublishedWork["Id"]);
	db.query('SELECT GenreId FROM PublishedWorkGenres WHERE PublishedWorkId = ' + publishedWorkId);
	
	"""make a new string containing all genre ids in a particular format, so you can use it afterwards"""
	var validGenreIdsToString = "";
	for i in range(0, db.query_result.size()):
		if (i == db.query_result.size()-1):
			validGenreIdsToString = validGenreIdsToString + str(db.query_result[i]["GenreId"]);
			break;
		validGenreIdsToString = validGenreIdsToString + str(db.query_result[i]["GenreId"]) + ",";
	
	"""get all genre names of the published work, using the help of that new string"""
	db.query("SELECT Name FROM Genres WHERE Id IN(" + validGenreIdsToString+")");
	
	"""save all valid published work genre names into an array -> validPublishedWorkGenres"""
	for i in range(0, db.query_result.size()):
		validEntityNames.append(db.query_result[i]["Name"]);
		
	print(validEntityNames);
	
	for i in range(0, $Control2/EntityList.get_item_count()):
		if validEntityNames.has($Control2/EntityList.get_item_text(i)):
			validEntityIndexes.append(i);
