extends "res://Scenes/RemindRule/RemindRule.gd"

func _ready():
	$RichTextLabel.text="Избери правописно правило:";

func _loadDataFromDb():
	""" Load data from db """
	db.query("SELECT * FROM WritingRules");
	for dict in db.query_result:
		ruleList.add_item(dict["Name"]);

func _on_RuleList_item_selected(index):
	audioStreamPlayer.play();
	
	var currentSelectedGrammarRuleName = ruleList.get_item_text(index);
	var currentGrammarRuleDetails = db.query("SELECT * FROM WritingRules WHERE Name="+"'"+currentSelectedGrammarRuleName+"'");
	descriptionTextEdit.text = db.query_result[0]["Description"];
