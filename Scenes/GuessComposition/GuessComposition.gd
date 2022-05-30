extends "res://Scenes/GameLogic.gd"

func _loadDataFromDb():
	"""
	Get a random PublishedWork.
	db.query returns an array that contains dictionaries
	The array's indexes are the rows indexes in the default order
	Each dictionary's key is the column name
	"""
	
	db.query("SELECT Name, CompositionDetails FROM PublishedWorks ORDER BY RANDOM() LIMIT 1")
	var randomPublishedWork = db.query_result[0];
	
	""" Load the composition of the random published work inside CompositionLabel """
	$CompositionLabel.text = db.query_result[0]["CompositionDetails"];
	
	questionLabel.text='За кое произведение се отнася композицията?';
	
	""" Get all publishedWorks -> saves it into a dictionary """
	db.query("SELECT Name FROM PublishedWorks");
	
	""" Add every publishedWorks's name into the entityList """
	for i in range(0, db.query_result.size()):
		entityList.add_item(db.query_result[i]["Name"]);
	
	validEntityNames.append(randomPublishedWork["Name"]);
	
	""" Save the index of valid publishedWork name in entityList"""
	for i in range(0, entityList.get_item_count()):
		if validEntityNames.has(entityList.get_item_text(i)):
			validEntityIndexes.append(i);
