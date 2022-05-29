extends "res://Scenes/GameLogic.gd"

func _loadDataFromDb():
	"""
	Get a random PublishedWork.
	db.query returns an array that contains dictionaries
	The array's indexes are the rows indexes in the default order
	Each dictionary's key is the column name
	"""
	
	db.query("SELECT Id, Name, AuthorId FROM PublishedWorks ORDER BY RANDOM() LIMIT 1")
	var randomPublishedWork = db.query_result[0];
	
	questionLabel.text='Кой е авторът на произведението ' + randomPublishedWork["Name"]+ '?';
	
	""" Get all authors -> saves it into a dictionary """
	db.query("SELECT * FROM Authors");
	
	""" Add every author's name into the entityList """
	for i in range(0, db.query_result.size()):
		entityList.add_item(db.query_result[i]["Name"]);
		
	""" Get the valid author's name of the published work and save it """
	db.query("SELECT Name FROM Authors WHERE Id = " + str(randomPublishedWork["AuthorId"]))
	""" Save the valid author name """
	validEntityNames.append(db.query_result[0]["Name"]);
		
	""" Save the index of valid author name in entityList"""
	for i in range(0, entityList.get_item_count()):
		if validEntityNames.has(entityList.get_item_text(i)):
			validEntityIndexes.append(i);
