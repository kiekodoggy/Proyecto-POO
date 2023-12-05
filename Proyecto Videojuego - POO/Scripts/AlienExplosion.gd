extends Node2D

#Inicialización
func _ready():
	$Particles2D.set_emitting(true)	#Habilita el emisor parcial
	$Explosion.play()				#reproduce la animación de la explosión

#Procesamiento normal de nodos
func _process(delta):
	if !$Particles2D.emitting and !$Explosion.playing:	#Comprueba si la animación ha terminado de reproducirse
		queue_free()	#Elimina la explosión
