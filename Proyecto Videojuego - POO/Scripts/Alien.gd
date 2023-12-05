extends Area2D
#Señales
signal Hit(obj)					#Indica que este extraterrestre ha sido golpeado
signal ReqDirChange				#Solicita un cambio de dirección global para el grupo alienígena
signal Landed					#Indica que los extraterrestres han aterrizado

#Precargar escenas
var oBullet = preload("res://Scenes/AlienBullet.tscn")	#Precarga la escena de bala para este alienígena en la instancia

#Variables
var Size = Vector2()									#Un marcador de posición para el tamaño de este objeto alienígena
var OK_To_Shoot											#Indica que este extraterrestre está bien para disparar
var ShootDirection = 1									#Un indicador de dirección para la bala alienígena (posibles cambios de dirección)
var BulletSpeed = 125									#La velocidad de la bala (cuando se utiliza)
var AlienType											#Este "type" extraterrestre
var PointValue = 10										#Este valor de puntos alienígenas
var XMoveStep = 1										#Este alienígena x incremento de movimiento
var YMoveStep = 8										#Este incremento de movimiento y alienígenas
var AnimBase											#Este cuadro de animación base extraterrestre
var AlienMinX											#Esta posición x mínima de los alienígenas en la pantalla antes de un cambio de dirección
var AlienMaxX											#Esto muestra la posición x máxima en la pantalla antes de un cambio de dirección.
var Points = [10,20,30]									#Los valores de puntos para cada tipo de alienígena

#Inicialización
func _ready():
	AlienMinX = Globals.Screen_Size.x * 0.05 			# 5% del ancho de la pantalla
	AlienMaxX = Globals.Screen_Size.x * 0.95 			# 95% del ancho de la pantalla
	Size = $AnimatedSprite.frames.get_frame("default",0).get_size()	#Obtén el tamaño de este sprite alienigena
	PointValue = Points[AlienType-1]					#asigna este valor de puntos alienigenas
	add_to_group("alien")								#añade este alienígena al grupo "alien"

#Establece la posición del extraterrestre en la pantalla
func SetPosition(pos,type):
	position = pos										#Establece la posición del alienígena.
	AlienType = type									#Establece el tipo de alienígena
	SetAnim(AlienType)									#configura los fotogramas de animación del extraterrestre según el tipo

#Mueve al extraterrestre
func Move(dir,drop,noofaliens):
	if noofaliens <=5:									#Si el número total de alienígenas es inferior a 5, aumenta la tasa de movimiento
		position.x += (XMoveStep * (5-noofaliens)+1)  * dir #Mueve al alienígena en la posición actual (velocidad ajustada)
	else:
		position.x += XMoveStep  * dir					#Mueve al alienígena en la dirección actual (velocidad normal)

	if position.x <= AlienMinX or position.x >= AlienMaxX: 	#Comprueba si el alienígena ha alcanzado un límite de pantalla
		emit_signal("ReqDirChange")							#Solicita al grupo que cambie de dirección
	if drop:												#Comprueba si se ha solicitado al extranjero que abandone una fila
		position.y += YMoveStep								#Mueve al extraterrestre hacia abajo
		if position.y > Globals.LandedYPos:					#Comprueba si el extraterrestre ha aterrizado
			emit_signal("Landed")							#indica a la función principal que los extraterrestres han aterrizado
	SetAnim(AlienType)										#Actualiza el cuadro de animación

#Establece el cuadro de animación para el extraterrestre
func SetAnim(type):
	AnimBase = $AnimatedSprite.get_frame()					#Obtiene el cuadro de animación actual
	if AnimBase & 1:										#Comprueba si este es el segundo fotograma de la animación.
		$AnimatedSprite.set_frame((type -1)*2)				#Establece el cuadro de animación en el primer cuadro para este tipo de alienígena
	else:	
		$AnimatedSprite.set_frame(((type -1)*2)+1)			#Establece el cuadro de animación en el segundo cuadro para este tipo de alienígena

#Maneja al alienígena que está siendo golpeado
func _on_Alien_area_entered(area):
	if area.is_in_group("playerBullet") and visible:		#Si el alienígena es visible y es alcanzado por la bala del jugador
		emit_signal("Hit",self)								#Indica que este extraterrestre ha sido golpeado
		area._removeBullet()								#Elimina la bala de los jugadores
		
#Genera una bala alienígena
func spawnBullet(parent,AlienBulletType) -> void:
	var oNewBullet = oBullet.instance()						#Instancia de una nueva bala alienígena
	oNewBullet.position.x = position.x + 1					#Establece la posición a la de este alienígena
	oNewBullet.position.y = position.y - (Size.y/2)			#Establece la posición a la de este alienígena.
	oNewBullet._setDirection(ShootDirection,BulletSpeed)	#Establece la dirección y velocidad de viaje de la bala.
	oNewBullet.BulletType = AlienBulletType					#Establece el tipo de bala en una bala alienígena
	oNewBullet.connect("removeBullet", parent, "_on_RemoveBullet")	#Conecta la señal de eliminación de bala
	oNewBullet.add_to_group("alienBullet")					#Agrega la bala al alienBullet group
	parent.add_child(oNewBullet)							#Añade la bala al nodo padre de este alienígena
