extends Node2D

#Señales
signal playerReset			#Señal de cuándo se debe reiniciar el reproductor

#Initialisation
func _ready():
	$Particles2D.set_emitting(true)		#Comienzan a emitir las partículas
	$Explosion.play()					#Reproduce la animación de la explosión

#Procesamiento normal de nodos
func _process(delta):
	if !$Particles2D.emitting and !$Explosion.playing:	#Comprueba si las partículas no se emiten y la animación se ha detenido
		emit_signal("playerReset",self)					#Señal de que el reproductor ahora debe reiniciarse
		queue_free()									#elimina la explosión
