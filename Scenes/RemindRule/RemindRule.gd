extends Control
const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns");

onready var db = SQLite.new();
var dbPath = "res://DataStore/PomagaloData"; # The path of the sqlite database

onready var ruleList = $RuleList;
onready var descriptionTextEdit = $DescriptionTextEdit;
onready var audioStreamPlayer = $AudioStreamPlayer;

func _ready():
	db.path=dbPath;
	db.open_db();
	
	_loadDataFromDb();

func _loadDataFromDb():
	""" Load data from db """
	pass;
