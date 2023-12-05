extends Node2D

#Señales
signal removeBullet(bullet)		#Señala cuándo se debe retirar la bala de la piscina

#Variables
var Speed						#La velocidad de la bala
var Direction = 1				#La dirección de la bala
var BulletType = 1				#El tipo de bala
var Size = Vector2()			#El tamaño del sprite de bala

#Inicialización
func _ready():
	Size = $Sprite.get_texture().get_size()		#Establece el tamaño del objeto de bala

#Procesamiento normal de nodos
func _process(delta):
	position.y += (Speed * delta) * Direction	#Actualiza la posición de la bala
	if (position.y < 0 - Size.y and Direction == -1) or (position.y > Globals.Screen_Size.y	+ Size.y and Direction == 1):	#Comprueba si la bala está fuera de la pantalla
		_removeBullet()							#quita la bala

#Establecer la dirección de la bala
func _setDirection(dir,spd):
	Direction = dir				#Establece la dirección de la bala
	Speed = spd					#Establece la velocidad de la bala

#Saca la bala de la piscina
func _removeBullet():
	emit_signal("removeBullet",self)	#Señala que la bala debe ser retirada de la piscina

