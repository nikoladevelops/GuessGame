extends "res://Scenes/GameLogic.gd"

func _loadDataFromDb():
	"""
	Get a random PublishedWork.
	db.query returns an array that contains dictionaries
	The array's indexes are the rows indexes in the default order
	Each dictionary's key is the column name
	"""
	
	db.query("SELECT Id, Name FROM PublishedWorks ORDER BY RANDOM() LIMIT 1")
	var randomPublishedWork = db.query_result[0];
	
	questionLabel.text='Какъв е жанрът на произведението ' + randomPublishedWork["Name"]+ '?';
	
	""" Get all genres -> saves it into a dictionary """
	db.query("SELECT * FROM Genres");
	
	""" Add every genre's name into the entityList """
	for i in range(0, db.query_result.size()):
		entityList.add_item(db.query_result[i]["Name"]);
		
	""" Get all genre ids of a particular publishedwork """
	var publishedWorkId = str(randomPublishedWork["Id"]);
	db.query('SELECT GenreId FROM PublishedWorkGenres WHERE PublishedWorkId = ' + publishedWorkId);
	
	""" Make a new string containing all genre ids in a particular format, so you can use it afterwards """
	var validGenreIdsToString = "";
	for i in range(0, db.query_result.size()):
		if (i == db.query_result.size()-1):
			validGenreIdsToString = validGenreIdsToString + str(db.query_result[i]["GenreId"]);
			break;
		validGenreIdsToString = validGenreIdsToString + str(db.query_result[i]["GenreId"]) + ",";
	
	""" Get all genre names of the published work, using the help of that new string """
	db.query("SELECT Name FROM Genres WHERE Id IN(" + validGenreIdsToString+")");
	
	""" Save all valid published work genre names into an array -> validEntityNames """
	for i in range(0, db.query_result.size()):
		validEntityNames.append(db.query_result[i]["Name"]);
		
	""" Save the indexes of all validEntityNames,that are located in entityList, inside validEntityIndexes """
	for i in range(0, entityList.get_item_count()):
		if validEntityNames.has(entityList.get_item_text(i)):
			validEntityIndexes.append(i);
