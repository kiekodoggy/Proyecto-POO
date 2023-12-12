extends Node2D
#Señales
signal removeBullet(bullet)		#Una señal para indicar que esta bala debe ser eliminada

#Variables
var Speed = 50					#La velocidad actual de la bala
var Speeds = [90,110,135,250]	#Las velocidades de bala según el tipo de bala
var Direction = 1				#La dirección actual de la bala
var BulletType = 1				#El tipo de bala actual
var BulletTypes = {				#Los tipos de bala
	"alienBulletType1": 0,
	"alienBulletType2": 1,
	"alienBulletType3": 2,
	"playerBullet":3}
var Size = Vector2()			#Un marcador de posición para el tamaño de este sprite

#Inicialización
func _ready():
	Size = $Sprite.get_texture().get_size()						#Obtiene el tamaño de este sprite
	Speed = Speeds[BulletType]									#Establece la velocidad según el tipo de bala
	$AnimationPlayer.play("alienBulletType" + str(BulletType))	#Establece la animación según el tipo de bala

#Procesamiento normal de nodos
func _process(delta):
	position.y += (Speed * delta) * Direction					#Actualiza la posición de la bala
	if (position.y < 0 - Size.y and Direction == -1) or (position.y > Globals.Screen_Size.y	+ Size.y and Direction == 1): #Comprueba si la bala está fuera de límites
		_removeBullet()											#llama a la función eliminar bala

#Establece la dirección y velocidad de la bala
func _setDirection(dir,spd):
	Direction = dir			#Establece la dirección de la bala
	Speed = spd				#Establece la velocidad de la bala

#Quitar la bala
func _removeBullet():
	emit_signal("removeBullet",self)	#Solicita que se elimine esta bala (actualiza el recuento de balas, etc.)

#Maneja esta bala impactando un objeto
func _on_Bullet_area_entered(area):
	if area.is_in_group("playerBullet"):					#comprueba si la bala ha sido alcanzada por la bala de un jugador
		match BulletType:
			BulletTypes.alienBulletType1:					#Si esto es bala tipo 1, el jugador lo destruye
				_removeBullet()
			BulletTypes.alienBulletType2:					#Si se trata de bala tipo 2, permita una posibilidad aleatoria de ser destruido por la bala del jugador
				if Globals.getRand_Range(1,10,0) <= 5:				#Comprueba si hay una probabilidad aleatoria entre 1 y 10
					_removeBullet()							#Elimina la bala alienígena si el valor es menor o igual a 5 (50/50)
			BulletTypes.alienBulletType3:					#Si se trata de bala tipo 3, permita una posibilidad aleatoria de ser destruido por la bala del jugador
				if Globals.getRand_Range(1,10,0) <= 3:				#Comprueba si hay una probabilidad aleatoria entre 1 y 10
					_removeBullet()							#Elimina la bala del jugador si el valor es menor o igual a 3 (70/30)
		area._removeBullet()								#Siempre elimina la bala del jugador
