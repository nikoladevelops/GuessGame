extends "res://Scenes/GameLogic.gd"

var selectedEntities = {};

func _loadDataFromDb():
	"""
	Get a random PublishedWork.
	db.query returns an array that contains dictionaries
	The array's indexes are the rows indexes in the default order
	Each dictionary's key is the column name
	"""
	
	db.query("SELECT Id, Name FROM PublishedWorks ORDER BY RANDOM() LIMIT 1")
	var randomPublishedWork = db.query_result[0];
	
	questionLabel.text='Избери срещаните теми в произведението ' + randomPublishedWork["Name"]+ '.';
	
	""" Get all themes -> saves it into a dictionary """
	db.query("SELECT * FROM Themes");
	
	""" Add every theme's name into the entityList """
	for i in range(0, db.query_result.size()):
		entityList.add_item(db.query_result[i]["Name"]);
		
	""" Get all theme ids of a particular publishedwork """
	var publishedWorkId = str(randomPublishedWork["Id"]);
	db.query('SELECT ThemeId FROM PublishedWorkThemes WHERE PublishedWorkId = ' + publishedWorkId);
	
	""" Make a new string containing all theme ids in a particular format, so you can use it afterwards """
	var validThemeIdsToString = "";
	for i in range(0, db.query_result.size()):
		if (i == db.query_result.size()-1):
			validThemeIdsToString = validThemeIdsToString + str(db.query_result[i]["ThemeId"]);
			break;
		validThemeIdsToString = validThemeIdsToString + str(db.query_result[i]["ThemeId"]) + ",";
	
	""" Get all theme names of the published work, using the help of that new string """
	db.query("SELECT Name FROM Themes WHERE Id IN(" + validThemeIdsToString+")");
	
	""" Save all valid published work theme names into an array -> validEntityNames """
	for i in range(0, db.query_result.size()):
		validEntityNames.append(db.query_result[i]["Name"]);
		
	""" Save the indexes of all validEntityNames,that are located in entityList, inside validEntityIndexes """
	for i in range(0, entityList.get_item_count()):
		if validEntityNames.has(entityList.get_item_text(i)):
			validEntityIndexes.append(i);

func _on_ChooseButton_button_down():
	""" What happens when the choose button is clicked"""
	
	""" Play a click sound"""
	audioStreamPlayer2.play();
	
	""" If the EntityList is empty don't do anything"""
	if(!entityList.is_anything_selected()):
		return;
	
	""" 
	Check if the selected answer by the user is present in the validEntityNames list
	If it isn't present, that means the given answer by the user is INCORRECT
	Make the background color of the incorrect answer to be red
	"""
	var answerIsCorrect = true;
	
	for currentEntityIndex in selectedEntities.keys(): # for each dictionary key / index
		var currentItemText = selectedEntities[currentEntityIndex]; # get current item text value
		if(!validEntityNames.has(currentItemText)): # check if validEntityNames has that text
			answerIsCorrect=false; # if it isn't found -> then one of the selected answers is wrong
			entityList.set_item_custom_bg_color(currentEntityIndex, Color.red); # make the bg color of that incorrect item red
	
	""" Make the background color of all correct answers to be green"""
	for i in range(0, validEntityIndexes.size()):
		entityList.set_item_custom_bg_color(validEntityIndexes[i], Color.green);
	
	""" Depending on whether the answer is correct, display a different message"""
	if(answerIsCorrect):
		isAnswerCorrectLabel.add_color_override("default_color",Color("46e435"));
		isAnswerCorrectLabel.text="Правилен отговор!";
	else:
		isAnswerCorrectLabel.add_color_override("default_color",Color("FF160C"));
		isAnswerCorrectLabel.text="Грешен отговор!";
	
	""" Make the label that dispays that message visible"""
	isAnswerCorrectLabel.visible=true;
	
	""" 
	Make sure the user can no longer click the choose button
	Emit a signal that the question was answered
	"""
	chooseButton.disabled=true;
	emit_signal("questionAnswered");

func _on_EntityList_multi_selected(_index, _selected):
	audioStreamPlayer.play();
	selectedEntities.clear();
	
	var selectedItemsIndexes = entityList.get_selected_items(); # get all selected item indexes of entityList
	for i in range(0, selectedItemsIndexes.size()): # for each item index
		var currentItemIndex = selectedItemsIndexes[i]; # get the item index and save it in currentItemIndex
		var currentItem = entityList.get_item_text(currentItemIndex); # get the current item text that is located on the currentItemIndex
		selectedEntities[currentItemIndex]=currentItem; # save the selected item index and the text
