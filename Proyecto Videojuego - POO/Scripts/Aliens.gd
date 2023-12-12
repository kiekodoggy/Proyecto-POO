extends Node

#Señales
signal allAliensDestroyed												#Señal cuando todos los alienígenas hayan sido destruidos 

#Constantes
const leftDir: int = 0
const rightDir: int = 1
const AlienTypes = {  "largeAlien":1, "mediumAlien": 2,"smallAlien" : 3}

#Precargar escenas
var oAlien = preload("res://Scenes/Alien.tscn")
var oAlienExplosion = preload("res://Scenes/AlienExplosion.tscn")

#Variables
var Parent																#Una referencia a este nodo
var FrameUpdateDelay: float = 0.05										#Retraso entre actualizaciones alienígenas<>alienígenas
var AlienMoveDelay: float = 0.015										#Retraso mínimo entre movimientos alienígenas
var CurrentAlienMoveDelay: float = 0.0									#Temporizador de movimiento alienígena actual
var CurrentUpdateDelay: float = 0.0										#Temporizador de actualización actual del "paquete"
var CurrentDirection:int												#Dirección de movimiento actual
var CurrentAlien:int													#Contador alienígena actual
var Max_Alien_Columns: int = 11										#Número de columnas alienígenas
var Max_Alien_Rows: int = 5											#Número de filas alienígenas
var Alien_Column_Space: int = 15										#Espacio entre columnas alienígenas (píxeles)
var Alien_Row_Space: int = 15											#Espacio entre filas alein (píxeles)
var AlienArry: Array													#Variable para contener instancias alienígenas
var AlienAliveArray: Array												#Variable para mantener vivos los índices alienígenas
var sndCnt: int															#Contador de clips de sonido actuales
var NoOfAliens: int														#Número total de extranjeros
var AliveAliens: int													#Número de extraterrestres vivos (visibles)
var sndPlayedThisCycle: bool											#Bandera para realizar un seguimiento de cuándo se ha reproducido el sonido por actualización
var RequestDirChange: bool												#Bandera de solicitud de cambio de dirección
var MoveInhibit: bool													#Bandera de inhibición de movimiento
var DropRow: bool														#Suelta bandera de solicitud de fila
var AliensInitialised: bool = false										#Todos los alienígenas han sido inicializados
var MaxAlienBullets: int = 3											#Establece el número máximo de balas alienígenas permitidas en la pantalla
var CurrentAlienBullets: int											#Número actual de balas alienígenas
var NextAlienBulletDelay: float											#Siguiente Tiempo de retardo de bala alienígena
export var MinAlienBulletDelay: int = 0.7								#Tiempo mínimo de retardo de bala alienígena
export var MaxAlienBulletDelay: int = 2.8								#Tiempo máximo de retardo de bala alienígena
var AlienBulletTypes: Array = [1,2,3]									#Variable de tipos de balas alienígenas en uso
var AliensCanShoot: bool = false										#Una vez que un extraterrestre alcanza un límite máximo en la pantalla, evita que los extraterrestres disparen
var levelOffset: int

#Inicialización
func _ready() -> void:
	CurrentDirection = rightDir											#Establece la dirección inicial hacia la derecha
	RequestDirChange = false											#Restablece la bandera de cambio de dirección
	DropRow = false														#Restablece la bandera de soltar una fila
	MoveInhibit = true													#Inhibe el movimiento alienígena
	AlienArry = []														#Inicializa la matriz alienígena
	Parent = self														#Crea una referencia a este nodo como padre
	
#Procesamiento normal de nodos
func _process(delta) -> void:

	if Globals.gameFreeze or Globals.gameState != Globals.gameStates.In_Play:	#Comprueba si se debe pausar el movimiento
		$Timer.stop()													#Detiene el cronómetro para la creación de viñetas.
	else:		
		if !$Timer.time_left > 0:										#Comprueba si ha transcurrido el temporizador de creación de balas
			$Timer.start(getRand_Range(1,3,1))							#Reinicia un nuevo retraso
		CurrentUpdateDelay += delta										#Actualiza el temporizador de ciclo actual
		CurrentAlienMoveDelay += delta									#Actualiza el temporizador de retardo de movimiento alienígena/alienígena
		NextAlienBulletDelay += delta									#actualiza el temporizador de retardo de la próxima bala alienígena
		if CurrentAlienMoveDelay >= AlienMoveDelay:						#Comprueba si es hora de mover al próximo alienígena
			if !MoveInhibit:											#Comprueba si se ha permitido el movimiento
				if !sndPlayedThisCycle:									#Comprueba si se ha reproducido sonido en este ciclo de actualización alienígena
					$InvSnd.get_node("InvSnd" + str(sndCnt)).play()		#Si no, reproduce el sonido alienígena actual según el contador de sonido
					sndCnt = sndCnt %4									#Envuelve el contador de sonido si es mayor que 4
					sndCnt += 1											#Incrementa el contador de sonido
					sndPlayedThisCycle = true							#Marca que el sonido alienígena se ha reproducido este ciclo
				moveAliens()											#Llama a la función "mover" de los extraterrestres
		if CurrentUpdateDelay >= FrameUpdateDelay:						#Comprueba si ha transcurrido el temporizador de ciclo actual
			CurrentUpdateDelay = 0										#Restablece el temporizador de ciclo
			MoveInhibit = false											#Vuelve a habilitar los movimientos alienígenas

#Genera los extraterrestres
func Generate_Aliens() -> void:
	var Parent = self													#Crea una referencia a este nodo como padre de los alienígenas
	var Pos = Vector2()													#Crea un vector para mantener la posición
	sndCnt = 1															#Establece el recuento de sonido en el primer clip
	sndPlayedThisCycle = false											#Restablece el sonido reproducido en esta bandera de ciclo
	CurrentAlien = 0													#Establece el alienígena actual en el primer alienígena de la matriz
	MoveInhibit = false													#Habilita el ciclo de movimiento
	if Globals.Level < Globals.maxLevel:								#Comprueba en qué nivel estamos
		levelOffset = (Globals.Level-1) * (Alien_Row_Space/2)				#Si estamos en un nivel inferior, ajuste la fila inicial alienígena según el nivel
	else:
		levelOffset = Globals.maxLevel * (Alien_Row_Space/2)	#Si estamos por encima del nivel inicial máximo, use la fila inicial máxima
	for rows in range(Max_Alien_Rows,0,-1):								#Recorre todas las filas de alienígenas comenzando desde abajo
		var AlienType													#Variable para contener el tipo de alienígena actual
		match rows:														#Hace coincidir los números de fila para obtener el tipo de alienígena correcto
			1:
				AlienType = AlienTypes.smallAlien									#Alien type = small alien
			2,3:
				AlienType = AlienTypes.mediumAlien									#Alien type = medium alien
			4,5:
				AlienType = AlienTypes.largeAlien									#Alien type = large alien
		for cols in range(Max_Alien_Columns,0,-1):						#Recorre todas las columnas de extraterrestres comenzando desde la derecha
			var oNew_Alien = oAlien.instance()							#Crea una nueva instancia alienígena
			oNew_Alien.name = "Alien_" + str(rows) + str(cols)			#Establece el nombre de la instancia según la columna/fila
			oNew_Alien.connect("Hit", self, "_on_AlienHit")				#Conecta las señales a esta instancia
			oNew_Alien.connect("ReqDirChange", self, "_on_ReqDirChange")#Conecta la solicitud de cambio de dirección a esta instancia
			oNew_Alien.connect("Landed", get_tree().get_root().get_node("Main"), "_AliensHaveLanded") 	#Conecta la señal de los extraterrestres han aterrizado al nodo principal
			Pos.x = $Alien_Start_Position.position.x + (cols * Alien_Column_Space) 						#Calcula la posición x para el alienígena actual
			Pos.y = $Alien_Start_Position.position.y + levelOffset + (rows * Alien_Row_Space)			#Calcula la posición y para el alienígena actual
			oNew_Alien.SetPosition(Pos,AlienType)						#llama a la función set position en la instancia alienígena y configure su tipo
			oNew_Alien.visible = true									#Establece la instancia alienígena visible
			Parent.add_child(oNew_Alien)								#Agrega la instancia alienígena a este nodo
			AlienArry.append(oNew_Alien)								#Agrega la instancia alienígena a la matriz alienígena
			AlienAliveArray.append(AlienArry.size())					#Actualiza la matriz alienígena viva
	NoOfAliens = AlienArry.size()										#Configura el número total de alienígenas creados
	AliveAliens = NoOfAliens											#Configura el número de extraterrestres vivos
	AliensInitialised = true											#indica que los extraterrestres han sido inicializados

#Función mover alienígenas
func moveAliens() -> void:
	var Alien															#Una referencia para contener un nodo de instancia alienígena
	if CurrentAlien >= NoOfAliens:										#Comprueba si hemos procesado a todos los extranjeros
		MoveInhibit = true												#Inhibe el movimiento de los alienígenas hasta la próxima actualización del ciclo
		CurrentAlien = 0												#Restablece el contador alienígena actual
		DropRow = false													#Restablece la solicitud de fila desplegable
		sndPlayedThisCycle = false										#Restablece el sonido reproducido en esta bandera de ciclo
		if RequestDirChange:											#comprueba si se ha solicitado un cambio de dirección durante la última actualización del ciclo
			CurrentDirection *= -1										#Invierte la dirección
			DropRow = true												#solicita a los extraterrestres que dejen caer una fila en el próximo movimiento
			RequestDirChange = false									#restablece la bandera de cambio de dirección
	while CurrentAlien < NoOfAliens and !AlienArry[CurrentAlien].visible:	#Recorre todos los extraterrestres no visibles
		CurrentAlien += 1													#incrementa el contador alienígena si no es visible
	if CurrentAlien < NoOfAliens:										#comprueba si todavía estamos dentro del límite de extraterrestres
		Alien = AlienArry[CurrentAlien]									#obtiene una referencia a la instancia alienígena actual
		Alien.Move(CurrentDirection,DropRow,AliveAliens)				#Solicita al extranjero que se mueva
		CurrentAlienMoveDelay = 0										#Restablece el retraso de moviemiento alien<>alien 
		CurrentAlien += 1												#Incrementa el contador alienígena actual
	if AliveAliens <= 0:												#Comprueba si todos los alienígenas han sido destruidos
		emit_signal("allAliensDestroyed")								#indica todos los alienígenas destruidos para restablecer el nivel, etc

#Maneja a un alienígena que está siendo golpeado:
func _on_AlienHit(Alien) -> void:
	var oNew_AlienExplosion = oAlienExplosion.instance()				#Crea una instancia de explosión alienígena
	oNew_AlienExplosion.position = Alien.position						#Establece la posición de la explosión a la del extraterrestre
	oNew_AlienExplosion.name = Alien.name + "_Explosion"				#Establece el nombre de la instancia de explosión
	Parent.add_child(oNew_AlienExplosion)								#agrega la instancia de explosión a este nodo
	Alien.visible = false												#Hace invisible el actual alienígena
	Globals.Score += Alien.PointValue									#incrementa la puntuación
	AliveAliens = AliensAlive()											#Actualiza el recuento de alienígenas vivos
	
#Maneja una solicitud de cambio de dirección desde una instancia alienígena
func _on_ReqDirChange() -> void:
	RequestDirChange = true												#Establece la bandera de cambio de dirección

#Actualiza el recuento de alienígenas vivos
func AliensAlive() -> int: 
	AlienAliveArray = []												#Limpia la matriz alienígena viva
	AliensCanShoot = true												#indica que los extraterrestres actualmente pueden disparar
	if Globals.playerState != Globals.playerStates.Alive:				#Comprueba si el jugador está vivo
		AliensCanShoot = false											#Si el jugador no está vivo, los alienígenas no pueden disparar.
	var x = 0															#Inicializa el contador alienígena vivo
	for i in range(NoOfAliens):											#Recorre todos los alienígenas
		if AlienArry[i].visible:										#Verifique la visibilidad de cada instancia en la matriz (alive)
			var alien = AlienArry[i]									#Obtiene una referencia al extraterrestre actual
			AlienAliveArray.append(i)									#Agrega el índice alienígena a la matriz viva
			x+= 1														#incrementa el contador alienígena vivo
			if alien.position.y > Globals.AlienYShootLimit:				#Comprueba si el alienígena está por debajo del límite de Y Shoot
				AliensCanShoot = false									#Desactiva a los extraterrestres para que no disparen
	return x															#Devuelve el número de extraterrestres vivos

#Inicializar los alienígenas:
func InitialiseAliens() -> void:
	var currentAlien = 0												#inicializa el contador alienígena actual
	var Pos = Vector2()													#Crea un vector2 para contener información de posición
	if Globals.Level < Globals.maxLevel:								#Comprueba en qué nivel estamos
		levelOffset = (Globals.Level-1) * (Alien_Row_Space/2)				#Si estamos en un nivel inferior, ajuste la fila inicial alienígena según el nivel
	else:
		levelOffset = Globals.maxLevel * (Alien_Row_Space/2)				#Si estamos por encima del nivel inicial máximo, use la fila inicial máxima
	for rows in range(Max_Alien_Rows,0,-1):								#Recorre todas las filas alienígenas comenzando desde abajo
		for cols in range(Max_Alien_Columns,0,-1):						#Recorre todas las columnas alienígenas comenzando desde la derecha
			Pos.x = $Alien_Start_Position.position.x + (cols * Alien_Column_Space)					#Calcula la posición x alienígena actual
			Pos.y = $Alien_Start_Position.position.y + levelOffset +  (rows * Alien_Row_Space)		#Calcula la posición actual del alienígena y
			InitialiseAlien(AlienArry[currentAlien],Pos,true)			#Inicializa el alienígena actual
			currentAlien += 1											#Incrementa el contador alienígena actual
	MoveInhibit = false													#Restablece la bandera de inhibición de movimiento
	sndCnt = 1															#Reinicializa el contador de sonido
	AliveAliens = NoOfAliens											#Restablece el número de extraterrestres vivos al número total de extraterrestres
	AliensInitialised = true											#Indica que los aliens han sido inicializados


#Inicializa el alienígena especificado
func InitialiseAlien(Alien,Pos,v) -> void:
	Alien.position = Pos												#Inicializa el alienígena especificado
	Alien.visible = v													#Establece la visibilidad alienígena
	
#Elige un número aleatorio entre valores bajos y altos (tipo: 0 = entero, 1 = float)
func getRand_Range(low,high, type):
	var rng = RandomNumberGenerator.new()								#Inicializa un generador de números aleatorios
	rng.randomize()														#Aleatoriza el resultado
	if type == 0:														#Comprueba si se solicita un número entero
		return rng.randi_range( low, high)								#Devuelve un entero aleatorio entre los dos valores especificados
	else:
		return rng.randf_range( low, high)								#Devuelve un flotante aleatorio entre los dos valores especificados

#Temporizador de disparo alienígena
func _on_Timer_timeout():
	if CurrentAlienBullets < MaxAlienBullets:							#Comprueba si tenemos capacidad para generar otra bala.
		AliensAlive()													#Actualiza el número de alienígenas vivos y si pueden disparar.
		if AliensCanShoot:												#Si los extraterrestres pueden disparar
			var AlienIdx = getRand_Range(0,AlienAliveArray.size()-1,0)	#Obtiene un índice alienígena vivo aleatorio
			var Alien = AlienArry[AlienAliveArray[AlienIdx]]			#Obtiene una referencia al extraterrestre
			var AlienBulletIdx = getRand_Range(0, AlienBulletTypes.size()-1,0)	#Obtiene el índice de un tipo de viñeta aleatorio
			var AlienBulletType = AlienBulletTypes[AlienBulletIdx]				#Obtiene el tipo de bala de la matriz de tipos
			AlienBulletTypes.remove(AlienBulletIdx)								#Elimina el tipo seleccionado de la gama de tipos disponibles
			Alien.spawnBullet(self,AlienBulletType)								#Solicita al extraterrestre que dispare con el tipo de bala seleccionado
			CurrentAlienBullets += 1											#Incrementa el número de balas alienígenas
	$Timer.start(getRand_Range(MinAlienBulletDelay,MaxAlienBulletDelay,1)) 		#Reinicia el cronómetro de disparo
	

#Quitar bala alienígena
func _on_RemoveBullet(bullet):
	AlienBulletTypes.append(bullet.BulletType)							#Restablece el tipo de bala alienígena como disponible
	CurrentAlienBullets -= 1											#Disminuye el número de balas alienígenas.
	clamp(CurrentAlienBullets,0,MaxAlienBullets)						#Asegura de que el número no se salga del rango
	bullet.queue_free()													#Destruye la bala

#Destruye a todos los alienígenas
func DestroyAll() -> void: 
	for i in range(NoOfAliens):											#Recorre todos los alienígenas
		AlienArry[i].visible = false									#Verifica la visibilidad de cada instancia en la funcion (alive)

