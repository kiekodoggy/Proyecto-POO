extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	$final.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_botonReintentar_pressed():
	get_tree().change_scene("res://Escenas/Main.tscn")


func _on_botonSalir_pressed():
		get_tree().change_scene("res://Escenas/1bienvenida.tscn")

