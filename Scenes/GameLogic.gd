extends Control
const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns");

onready var db = SQLite.new();

var dbPath = "res://DataStore/PomagaloData"; # The path of the sqlite database
var validEntityNames = []; # All valid entity names
var validEntityIndexes = []; # The indexes of all valid entity names in the EntityList

var selectedEntityName; # The selected entity name by the user
var selectedEntityIndex; # The selected entity index inside EntityList

signal questionAnswered;

# The scene nodes saved in variables.
onready var questionLabel = $Control/QuestionLabel;
onready var isAnswerCorrectLabel = $Control/isAnswerCorrectLabel;
onready var entityList = $Control2/EntityList;
onready var chooseButton = $Control2/ChooseButton;
onready var audioStreamPlayer = $AudioStreamPlayer;
onready var audioStreamPlayer2 = $AudioStreamPlayer2;

func _ready():
	db.path=dbPath;
	db.open_db();
	
	randomize();
	_loadDataFromDb();
	

func _loadDataFromDb():
	""" Load data from db """
	pass;

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
	if(!validEntityNames.has(selectedEntityName)):
		entityList.set_item_custom_bg_color(selectedEntityIndex, Color.red);
		answerIsCorrect = false;
	
	""" Make the background color of all correct answers to be green"""
	for i in range(0, validEntityIndexes.size()):
		entityList.set_item_custom_bg_color(validEntityIndexes[i], Color.green);
	
	""" Depending on whether the answer is correct, display a different message"""
	if(answerIsCorrect):
		isAnswerCorrectLabel.add_color_override("default_color",Color("46e435"));
		isAnswerCorrectLabel.text="Правилен отговор!";
	else:
		isAnswerCorrectLabel.add_color_override("default_color",Color("d82a2a"));
		isAnswerCorrectLabel.text="Грешен отговор!";
	
	""" Make the label that dispays that message visible"""
	isAnswerCorrectLabel.visible=true;
	
	""" 
	Make sure the user can no longer click the choose button
	Emit a signal that the question was answered
	"""
	chooseButton.disabled=true;
	emit_signal("questionAnswered");
		

func _on_EntityList_item_selected(index):
	"""
	 When an item is selected inside EntityList,
	 play a select sound
	 save the selected entity's name
	 and save the index of that selected entity name
	'"""
	audioStreamPlayer.play();
	selectedEntityName = entityList.get_item_text(index);
	selectedEntityIndex = index;
