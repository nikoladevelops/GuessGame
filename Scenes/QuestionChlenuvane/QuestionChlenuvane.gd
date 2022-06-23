extends Control
const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns");

onready var db = SQLite.new();
var dbPath = "res://DataStore/PomagaloData"; # The path of the sqlite database

onready var sentenceTextLabel = $SentenceTextLabel;
onready var isAnswerCorrectLabel = $isAnswerCorrectLabel;
onready var answerList = $AnswerList;
onready var audioStreamPlayer = $AudioStreamPlayer;
onready var audioStreamPlayer2 = $AudioStreamPlayer2;
onready var chooseButton = $ChooseButton;

var correctAnswerString="";
var correctAnswerIndex;

var selectedAnswer="";
var selectedAnswerIndex;

signal questionAnswered;

func _ready():
	db.path=dbPath;
	db.open_db();
	
	_loadDataFromDb();

func _loadDataFromDb():
	""" Load data from db """
	db.query("SELECT * FROM QuestionsChlenuvane ORDER BY RANDOM() LIMIT 1");
	
	var sentence = db.query_result[0]["Sentence"];
	var correctSentence = db.query_result[0]["CorrectSentence"];
	
	correctAnswerString = db.query_result[0]["CorrectAnswers"];
	
	var correctAnswersArray = correctAnswerString.split(", ");
	var wrongAnswersaArray = db.query_result[0]["WrongAnswers"].split(", ");
	var countAnswers = db.query_result[0]["CountAnswers"];
	
	var wrongAnswer1 = generateWrongAnswer(correctAnswersArray, wrongAnswersaArray, countAnswers);
	var wrongAnswer2 = generateWrongAnswer(correctAnswersArray, wrongAnswersaArray, countAnswers);
	var wrongAnswer3 = generateWrongAnswer(correctAnswersArray, wrongAnswersaArray, countAnswers);
	
	sentenceTextLabel.text=sentence;
	
	randomize();
	var allAnswers = [correctAnswerString, wrongAnswer1, wrongAnswer2, wrongAnswer3];
	allAnswers.shuffle();
	
	for i in range(0, allAnswers.size()):
		var currentAnswer = allAnswers[i];
		if(currentAnswer == correctAnswerString):
			correctAnswerIndex=i;
			
		answerList.add_item(currentAnswer);

func generateWrongAnswer(correctAnswersArray, wrongAnswersArray, countAnswers):
	randomize();
	# get a random amount of wrong answers between 1 and the countofanswers
	var randomAmountOfWrongAnswers = randi() % countAnswers + 1;
	
	var generatedWrongAnswerString="";
	#if the amount of wrong answers is generated to be equal to countofanswers then that means -> make a wrong answer that contains only the wrong words
	if(randomAmountOfWrongAnswers == countAnswers):
		generatedWrongAnswerString = wrongAnswersArray.join(", ");
	else: # otherwise make a wrong answer by getting wrong words (how many this time? -> randomamountofwronganswers tells us) and combining it with the rest of the right answers
		for i in range(randomAmountOfWrongAnswers):
			var currentWrongWord = wrongAnswersArray[i];
			generatedWrongAnswerString = generatedWrongAnswerString+currentWrongWord+", ";
		
		for i in range(randomAmountOfWrongAnswers, countAnswers):
			generatedWrongAnswerString=generatedWrongAnswerString+correctAnswersArray[i];
			if(i != countAnswers && i != randomAmountOfWrongAnswers):
				generatedWrongAnswerString=generatedWrongAnswerString+", ";
	return generatedWrongAnswerString;

func _on_ChooseButton_button_down():
	audioStreamPlayer2.play();
	if(!answerList.is_anything_selected()):
		return;
	
	
	""" Depending on whether the answer is correct, display a different message"""
	if(correctAnswerString == selectedAnswer):
		answerList.set_item_custom_bg_color(selectedAnswerIndex, Color.green);
		isAnswerCorrectLabel.add_color_override("default_color",Color("46e435"));
		isAnswerCorrectLabel.text="Правилен отговор!";
	else:
		answerList.set_item_custom_bg_color(selectedAnswerIndex, Color.red);
		answerList.set_item_custom_bg_color(correctAnswerIndex, Color.green);
		isAnswerCorrectLabel.add_color_override("default_color",Color("FF160C"));
		isAnswerCorrectLabel.text="Грешен отговор!";
	
	isAnswerCorrectLabel.visible=true;
	chooseButton.disabled=true;
	emit_signal("questionAnswered");

func _on_AnswerList_item_selected(index):
	audioStreamPlayer.play();
	selectedAnswer = answerList.get_item_text(index);
	selectedAnswerIndex = index;
