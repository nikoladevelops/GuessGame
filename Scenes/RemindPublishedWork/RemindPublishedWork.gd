extends Control
const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns");

onready var db = SQLite.new();
var dbPath = "res://DataStore/PomagaloData"; # The path of the sqlite database

onready var publishedWorkList = $PublishedWorkList;
onready var audioStreamPlayer = $AudioStreamPlayer;

func _ready():
	db.path=dbPath;
	db.open_db();
	
	_loadDataFromDb();

func _loadDataFromDb():
	""" Load data from db """
	db.query("SELECT * FROM PublishedWorks");
	for publishedWork in db.query_result:
		publishedWorkList.add_item(publishedWork["Name"]);


func _on_PublishedWorkList_item_selected(index):
	audioStreamPlayer.play();
