extends Node2D

#Inicialización
func _ready():
	$Particles2D.set_emitting(true)		#Comienza a emitir las partículas
	$Explosion.play()					#Reproduce la animación de la explosión

#Procesamiento normal de nodos
func _process(delta):
	if !$Particles2D.emitting:	#Comprueba si las partículas no están emitiendo
		queue_free()			#Elimina la explosion
