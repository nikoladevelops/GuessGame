extends Control

func _on_Timer_timeout():
	get_tree().reload_current_scene();

func startTimer():
	$Timer.start();
