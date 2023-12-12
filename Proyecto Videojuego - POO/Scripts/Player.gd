extends Area2D

#Señales
signal Hit(obj)				#Señal cuando el jugador ha sido golpeado

#Constantes
const cPlayerBullet = 1		#Constante de bala del jugador

#Precargar escenas
var oBullet = preload("res://Scenes/PlayerBullet.tscn")	#Precarga la escena de la bala del jugador

#Variables
var Move_Speed = 100						#Velocidad de movimiento del jugador
var Screen_Size								#Referencia de tamaño de pantalla
var Player_Size								#Referencia de tamaño del jugador
var OK_To_Shoot								#OK para disparar la bandera
var ShootDirection = -1						#Dirección de disparo
var BulletSpeed = 250						#Velocidad de bala del jugador
var PlayerBullets							#Número de balas de jugador
var PlayerMaxBullets = 1					#Número máximo de balas de jugador
var pressed = {}							#Variable de teclas presionadas
var startPos:Vector2 = Vector2(112,242)		#Posición inicial del jugador

#Inicialización
func _ready():
	Screen_Size = get_viewport_rect().size			#Obtiene el tamaño de la pantalla
	Player_Size = $Sprite.get_texture().get_size()	#Obtiene el tamaño del sprite del jugador
	PlayerBullets = 0								#Restablece el número de balas del jugador
	OK_To_Shoot = true								#Permite al jugador disparar
	$Shoot_Delay.stop()								#Detiene el temporizador de retraso entre disparos
	$Sprite.modulate = Globals.PlayerColour			#Establece el color del reproductor
	position = startPos								#Establece la posición del jugador
	
#Procesamiento normal de nodos
func _process(delta):
	if !Globals.gameFreeze:							#Comprueba que el juego no esté congelado
		var Velocity = Vector2() 					# El vector de movimiento del jugador
		if Input.is_action_pressed("ui_right"):		#Comprueba si se mueve hacia la derecha
			Velocity.x += 1							#Establece la velocidad de movimiento hacia la derecha
		if Input.is_action_pressed("ui_left"):		#Comprueba movimiento hacia la izquierda
			Velocity.x -= 1							#Establece la velocidad de movimiento hacia la izquierda
		if is_action_just_pressed("ui_select") and (PlayerBullets<PlayerMaxBullets) and OK_To_Shoot: #Verifica si presionó fuego, no se alcanzó el máximo de balas y está bien disparar
			OK_To_Shoot = false						#No OK para configurar para disparar
			_spawnBullet()							#Genera una nueva bala
			$Shoot_Delay.start()					#Inicia el temporizador de retraso entre disparos
			$Shoot.play()							#Reproduce el sonido del disparo
		if Velocity.length() > 0:					#Comprueba si el jugador se está moviendo
			Velocity = Velocity.normalized() * Move_Speed	#Calcula el movimiento en función de la velocidad
		_updatePosition(Velocity * delta)			#Actualiza la posición del jugador según el tiempo transcurrido

#Actualiza la posición del jugador
func _updatePosition(movement):
	position += movement							#Actualiza la posicion
	position.x = (clamp(position.x, 0 + (Player_Size.x/2), Globals.Screen_Size.x -(Player_Size.x/2))) 	#Mantiene la posición x a los límites de la pantalla
	position.y = (clamp(position.y, 0, Globals.Screen_Size.y))											#Mantiene la posición y a los límites de la pantalla

#Temporizador de retardo entre disparos
func _on_Shoot_Delay_timeout():
	OK_To_Shoot = true								#Permite al jugador disparar una vez más
	$Shoot_Delay.stop()								#Detiene el temporizador de retraso entre disparos

#Genera una nueva bala
func _spawnBullet():
	var Parent = get_parent()						#Obtiene una referencia al padre de este nodo
	var oNewBullet = oBullet.instance()				#Crea una nueva instancia de bala
	oNewBullet.position.x = position.x 				#Establece la posición de bala x a la del jugador
	oNewBullet.position.y = position.y - (Player_Size.y/2)	#Establece la posición de la bala Y a la del jugador
	oNewBullet._setDirection(ShootDirection,BulletSpeed)	#Establece la velocidad y dirección de la bala
	oNewBullet.BulletType = cPlayerBullet			#Establece el tipo de bala al del jugador.
	oNewBullet.connect("removeBullet", self, "_on_removeBullet")	#Conecta la señal de eliminación de bala a este nodo
	oNewBullet.add_to_group("playerBullet")			#Agrega la bala al grupo de balas de reproducción
	Parent.add_child(oNewBullet)					#Agrega la bala como hijo del padre de este nodo
	PlayerBullets += 1								#Incrementa el número de balas  existentes

#Quitar función de bala
func _on_removeBullet(bullet):
	if PlayerBullets > 0 and bullet != null: 		#Si el número de balas > 0 y esta bala todavía existe
		PlayerBullets -= 1							#Disminuye el número de balas existentes
		bullet.queue_free()							#Quita la bala

#Manejar al jugador siendo golpeado
func _on_Player_area_entered(area):
	if (area.is_in_group("alienBullet") or area.is_in_group("alien")):	#Comprueba si un alienígena o bala alienígena ha golpeado al jugador
		emit_signal("Hit",self)											#Señal de que el jugador ha sido golpeado
		for ab in get_tree().get_nodes_in_group("alienBullet"):			#Recorre todas las balas alienígenas
			ab._removeBullet()											#Quita la bala
		get_tree().get_root().get_node("Main/Aliens").AliensCanShoot = false	#Desactiva la capacidad de los alienígenas para disparar

#Esta función verificará si se presionó previamente una acción; de lo contrario, devolverá verdadero. Esto evita disparos continuos
func is_action_just_pressed(action):
	if Input.is_action_pressed(action):							#Comprueba si se pulsa la tecla específica
		if not pressed.has(action) or not pressed[action]:		#Si la tecla no ha sido pulsada previamente
			pressed[action] = true								#Registra la pulsación de tecla en una matriz para futuras comprobaciones
			return true											#Devuelve verdadero, esta es la primera vez que se presiona la tecla
	else:
		pressed[action] = false									#La tecla ya no se presiona, elimina la pulsación de tecla de la matriz
	return false												#Devuelve falso, la tecla no ha sido presionada

