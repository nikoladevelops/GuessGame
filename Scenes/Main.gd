extends Control

func _on_GuessGenre_questionAnswered():
	$Timer.start();

func _on_Timer_timeout():
	$GuessGenre.get_tree().reload_current_scene();