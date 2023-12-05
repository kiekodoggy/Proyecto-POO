extends Area2D

#Señales
signal gameOver											#Indica que se solicita el fin del juego
signal neighbourHit										#Indica que solicitamos que el elemento vecino reciba daño
signal destroyBase										#Indica que toda la base debe ser destruida.

#Constantes
const upDir = 0											#Una constante de dirección ascendente
const downDir = 1										#Una constante de dirección descendente

#Variables
var state 												#utilizado para la animación de la salud
var elemType											#utilizado para la selección de animación, elementos 1->3 selección normal, 11-13 volteados
var elemFrames = 3										#el número de fotogramas de animación
var anim												#el cuadro de animación actual (comprende el estado base + el contador de animación)
var flipped												#usado para indicar que este sprite está volteado en el eje y (reflejado en x)
var spr : Sprite 										#un puntero al nodo sprite

#Configuración de elementos
func _ready():
	spr = $Sprite										#Obtiene una referencia al nodo sprite
	state = 0 											#establece la base en plena salud (0 = completo 0 + (elemFrames - 1) = destruido)
	if elemType >= 10:									#Si el tipo de elemento es> 10, este es un elemento invertido
		flipped = true									#establece la bandera volteada
		anim = (elemType - 10) * elemFrames				#calcula el cuadro de animación actual requerido de la hoja de sprites
	else:
		flipped = false									#borra la bandera volteada
		anim = elemType * elemFrames 					#calcula el cuadro de animación actual requerido de la hoja de sprites
	setAnim(anim+state)									#establece el cuadro de animación real del sprite
	spr.flip_h = flipped								#si es necesario, voltea el sprite
	spr.modulate = Globals.BaseColour

#El elemento ha sido golpeado
func _on_baseElement_area_entered(area):
	if area.is_in_group("alien"):						#Comprueba si el elemento ha sido golpeado por un alienígena
		emit_signal("destroyBase")						#solicita fin del juego
	else:
		area._removeBullet() 							#quita la bala
		state += 1 										#avanza la animacion
		if state < elemFrames:							#comprueba si hemos llegado al final de la animación del elemento base
			setAnim(anim+state)							#establece el estado de la animación
		else:
			if area.is_in_group("playerBullet"):		#comprueba si una bala del jugador ha alcanzado la base
				emit_signal("neighbourHit",self,upDir)	#Solicita daño del elemento encima de este
			else:
				emit_signal("neighbourHit",self,downDir)#solicita daño del elemento debajo de este
			queue_free() 								#elimina este elemento base

#Establece el marco de animación del sprite
func setAnim(anim):
	spr.set_frame(anim)									#Establece el cuadro de animación del sprite

#Destruye este elemento de la base
func _destroy():
	queue_free()										#Destruye este elemento

#Gestiona una solicitud para dañar esta base desde otro elemento
func externalHit():
		state += 1										#Avanza en el estado de salud
		if state < elemFrames:							#Comprueba si estamos en daño máximo
			setAnim(anim+state)							#establece el marco de animación
		else:
			queue_free() 								#retira el elemento base ya que se ha recibido el daño máximo
	
