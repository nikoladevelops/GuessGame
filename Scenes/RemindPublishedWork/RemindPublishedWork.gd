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
	var currentSelectedPublishedWorkName = publishedWorkList.get_item_text(index);
	var getSelectedPublishedWorkDetailsQuery = getAllPublishedWorksOfAnAuthorQuery + 'AND pw.Name = "' + currentSelectedPublishedWorkName + '"';
	
	db.query(getSelectedPublishedWorkDetailsQuery);
	
	authorNameTextEdit.text = db.query_result[0]["AuthorName"];
	dateTextEdit.text = db.query_result[0]["PublishedDate"];
	compositionTextEdit.text = db.query_result[0]["CompositionDetails"];
	motivesAndFiguresTextEdit.text = db.query_result[0]["MotivesAndFigures"];
	ideologicalSuggestionsTextEdit.text = db.query_result[0]["IdeologicalSuggestions"];
	remarksTextEdit.text = db.query_result[0]["Remarks"];
	

func _on_ChooseAuthorList_item_selected(index):
	publishedWorkList.clear();
	audioStreamPlayer.play();
	currentSelectedAuthorName = authorList.get_item_text(index);
	
	getAllPublishedWorksOfAnAuthorQuery = 'SELECT pw.Id, pw.AuthorId, pw.CompositionDetails, pw.IdeologicalSuggestions, pw.MotivesAndFigures, pw.Name, pw.PublishedDate, pw.Remarks, author.Name as AuthorName FROM PublishedWorks pw JOIN Authors author ON author.Id = pw.AuthorId WHERE author.Name = "'+currentSelectedAuthorName+'"';
	db.query(getAllPublishedWorksOfAnAuthorQuery);
	
	for dict in db.query_result:
		publishedWorkList.add_item(dict["Name"]);
