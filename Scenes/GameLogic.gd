extends Control
const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns");

var db = SQLite.new();

var dbPath = "res://DataStore/PomagaloData";
var validPublishedWorkGenres = [];
var validPublishedWorkGenresIndexes = [];

var selectedGenre;
var selectedGenreIndex;

func _ready():
	db.path=dbPath;
	db.open_db();
	
	_loadDataFromDb();

func _loadDataFromDb():
	$Control/isAnswerCorrectLabel.visible=false;
	$Control2/GenreList.clear();
	
	randomize();
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
		$Control2/GenreList.add_item(db.query_result[i]["Name"]);
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
		validPublishedWorkGenres.append(db.query_result[i]["Name"]);
		
	print(validPublishedWorkGenres);
	
	for i in range(0, $Control2/GenreList.get_item_count()):
		if validPublishedWorkGenres.has($Control2/GenreList.get_item_text(i)):
			validPublishedWorkGenresIndexes.append(i);

func _on_ChooseButton_button_down():
	if(!$Control2/GenreList.is_anything_selected()):
		return;
	
	var answerIsCorrect = true;
	if(!validPublishedWorkGenres.has(selectedGenre)):
		$Control2/GenreList.set_item_custom_bg_color(selectedGenreIndex, Color.red);
		answerIsCorrect = false;
		
	for i in range(0, validPublishedWorkGenresIndexes.size()):
		$Control2/GenreList.set_item_custom_bg_color(validPublishedWorkGenresIndexes[i], Color.green);
	
	$Control/isAnswerCorrectLabel.visible=true;
	if(answerIsCorrect):
		$Control/isAnswerCorrectLabel.add_color_override("default_color",Color("46e435"));
		$Control/isAnswerCorrectLabel.text="Правилен отговор!";
	else:
		$Control/isAnswerCorrectLabel.add_color_override("default_color",Color("d82a2a"));
		$Control/isAnswerCorrectLabel.text="Грешен отговор!";
		
func _on_GenreList_item_selected(index):
	selectedGenre = $Control2/GenreList.get_item_text(index);
	selectedGenreIndex = index;
	$AudioStreamPlayer.play();

