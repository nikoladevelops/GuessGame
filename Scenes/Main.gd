extends Control

func _on_Timer_timeout():
	get_tree().reload_current_scene();

func _on_GuessAuthor_questionAnswered():
	$Timer.start();

func _on_GuessGenre_questionAnswered():
	$Timer.start();
	
func _on_GuessThemes_questionAnswered():
	$Timer.start();
	
func _on_GuessComposition_questionAnswered():
	$Timer.start();

func _on_QuestionChlenuvane_questionAnswered():
	$Timer.start();
