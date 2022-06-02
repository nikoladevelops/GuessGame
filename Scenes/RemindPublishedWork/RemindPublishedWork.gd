extends Control
const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns");

onready var db = SQLite.new();
var dbPath = "res://DataStore/PomagaloData"; # The path of the sqlite database

onready var authorList = $ChooseAuthorList;
onready var publishedWorkList = $ChoosePublishedWorkList;
onready var audioStreamPlayer = $AudioStreamPlayer;

onready var authorNameTextEdit = $Control/AuthorNameTextEdit;
onready var dateTextEdit = $Control2/DateTextEdit;
onready var compositionTextEdit = $Control6/CompositionTextEdit;
onready var motivesAndFiguresTextEdit = $Control9/MotivesAndFiguresTextEdit;
onready var ideologicalSuggestionsTextEdit = $Control11/IdeologicalSuggestionsTextEdit;
onready var remarksTextEdit = $Control12/RemarksTextEdit;

onready var genreTextEdit = $Control5/GenreTextEdit
onready var charactersTextEdit = $Control7/CharactersTextEdit;
onready var themesTextEdit = $Control8/ThemesTextEdit;
onready var oppositionsTextEdit = $Control10/OppositionsTextEdit;

var currentSelectedAuthorName;
var getAllPublishedWorksOfAnAuthorQuery;

func _ready():
	db.path=dbPath;
	db.open_db();
	
	_loadDataFromDb();

func _loadDataFromDb():
	""" Load data from db """
	db.query("SELECT Id, Name FROM Authors");
	
	for dict in db.query_result:
		authorList.add_item(dict["Name"]);

func _on_PublishedWorkList_item_selected(index):
	audioStreamPlayer.play();
	""" Get the current selected published work of the current selected author and update the corresponding TextEdit nodes """
	var currentSelectedPublishedWorkName = publishedWorkList.get_item_text(index);
	var getSelectedPublishedWorkDetailsQuery = getAllPublishedWorksOfAnAuthorQuery + 'AND pw.Name = "' + currentSelectedPublishedWorkName + '"';
	
	db.query(getSelectedPublishedWorkDetailsQuery);
	
	authorNameTextEdit.text = db.query_result[0]["AuthorName"];
	dateTextEdit.text = db.query_result[0]["PublishedDate"];
	compositionTextEdit.text = db.query_result[0]["CompositionDetails"];
	motivesAndFiguresTextEdit.text = db.query_result[0]["MotivesAndFigures"];
	ideologicalSuggestionsTextEdit.text = db.query_result[0]["IdeologicalSuggestions"];
	remarksTextEdit.text = db.query_result[0]["Remarks"];
	
	var publishedWorkId = str(db.query_result[0]["Id"]);
	
	""" Get all genres of the current published work and update the genreTextEdit node """
	db.query("SELECT genre.Name as GenreName FROM PublishedWorkGenres pwg JOIN Genres genre ON genre.Id = pwg.GenreId JOIN PublishedWorks pw ON pw.Id = pwg.PublishedWorkId  WHERE PublishedWorkId = " + publishedWorkId);
	updateTextEdit(genreTextEdit);
	
	""" Get all character names of the current published work and update the charactersTextEdit node"""
	db.query("SELECT character.Name as CharacterName FROM PublishedWorkCharacters pwc JOIN Characters character ON character.Id = pwc.CharacterId JOIN PublishedWorks pw ON pw.Id = pwc.PublishedWorkId  WHERE PublishedWorkId = " + publishedWorkId);
	updateTextEdit(charactersTextEdit);
	
	""" Get all themes names of the current published work and update the themesTextEdit node"""
	db.query("SELECT theme.Name as ThemeName FROM PublishedWorkThemes pwt JOIN Themes theme ON theme.Id = pwt.ThemeId JOIN PublishedWorks pw ON pw.Id = pwt.PublishedWorkId  WHERE PublishedWorkId = " + publishedWorkId);
	updateTextEdit(themesTextEdit);
	
	""" Get all opposition names of the current published work and update the oppositionsTextEdit node"""
	db.query("SELECT opposition.Name as OppositionName FROM PublishedWorkOppositions pwo JOIN Oppositions opposition ON opposition.Id = pwo.OppositionId JOIN PublishedWorks pw ON pw.Id = pwo.PublishedWorkId  WHERE PublishedWorkId = " + publishedWorkId);
	updateTextEdit(oppositionsTextEdit);
	
func _on_ChooseAuthorList_item_selected(index):
	publishedWorkList.clear();
	audioStreamPlayer.play();
	currentSelectedAuthorName = authorList.get_item_text(index);
	
	getAllPublishedWorksOfAnAuthorQuery = 'SELECT pw.Id, pw.AuthorId, pw.CompositionDetails, pw.IdeologicalSuggestions, pw.MotivesAndFigures, pw.Name, pw.PublishedDate, pw.Remarks, author.Name as AuthorName FROM PublishedWorks pw JOIN Authors author ON author.Id = pw.AuthorId WHERE author.Name = "'+currentSelectedAuthorName+'"';
	db.query(getAllPublishedWorksOfAnAuthorQuery);
	
	for dict in db.query_result:
		publishedWorkList.add_item(dict["Name"]);
		
func updateTextEdit(textEdit):
	textEdit.text="";
	var generatedText = "";
	for dict in db.query_result:
		var allValues = dict.values();
		for value in allValues:
			generatedText = generatedText + value + "\n";
	
	textEdit.text = generatedText;

