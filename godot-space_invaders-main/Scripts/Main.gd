extends Node

#Precargar escenas
var oExplosion = preload("res://Scenes/PlayerExplosion.tscn")				#Precarga la escena de explosión del jugador
var oSpaceShip = preload("res://Scenes/SpaceShip.tscn")						#Precarga la escena de la nave espacial
var oSpaceShipExplosion = preload("res://Scenes/SpaceShipExplosion.tscn")	#Precarga la escena de la explosión de la nave espacial
var oPlayer = preload("res://Scenes/Player.tscn")							#Precarga la escena del jugador

#Variables
var Player: Node						#Una referencia al jugador
var MinSpaceShipDelay: float = 10		#El retraso mínimo antes de que se genere una nueva nave espacial
var MaxSpaceShipDelay: float = 25		#El retraso máximo antes de que se genere una nueva nave espacial
var SpaceShipYPosition: int = 24		#La posición Y de la nave espacial cuando se genera

#Inicialización
func _ready():
	Globals.Screen_Size = Vector2(get_viewport().size.x,get_viewport().size.y) 	#Obtiene el tamaño de la pantalla
	Globals.OSScreen_Size = OS.get_screen_size()								#Obtiene el tamaño de la pantalla del sistema operativo
	OS.set_window_position(Globals.OSScreen_Size*0.5 - Globals.Screen_Size*0.5)	#Establece la posición de la ventana
	Globals.gameState = Globals.gameStates.Title								#Establece el estado inicial del juego para mostrar el título
	Globals.HUD = $HUD															#Crea una referencia al HUD

#Procesamiento normal de nodos
func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):							#Compruebe si se ha pulsado la tecla Escape
		get_tree().quit()											#Si es así sal del juego
	match Globals.gameState:										#Evalua el estado del juego
		Globals.gameStates.Title:									#gamestates = gamestates.title
			$Aliens.DestroyAll()									#Destruye a todos los alienígenas
			$Bases.DestroyAll()										#Destruye todas las bases
			Globals.HUD.showTitle(true)								#Muestra la página de título en el HUD
			
			if Input.is_key_pressed(KEY_ENTER):						#Comprueba si se ha pulsado la tecla ENTER
				Globals.HUD.showTitle(false)						#Oculta la página de título en el HUD
				Globals.gameState = Globals.gameStates.Init_Game	#Establece el estado del juego para inicializar el juego.
				$inicio.play()
		Globals.gameStates.Init_Game: 								#Game state = Initialise Game
			_init_game()											#Llama a la función de inicialización
			Globals.gameState = Globals.gameStates.Init_Bases		#Establece el estado del juego para inicializar las bases.
			
		Globals.gameStates.Init_Aliens:								#Game state = Initialise Aliens
			$Aliens.AliensInitialised = false						#Borra la bandera inicializada de los alienígenas.
			$Bases.basesCreated = false								#Limpia la bandera de bases creadas
			$Aliens.InitialiseAliens()								#Inicializar a los extraterrestres
			$SpaceShipTimer.start(getRand_Range(MinSpaceShipDelay,MaxSpaceShipDelay,1)) #Iniciar el cronómetro de la nave espacial extraterrestre
			Globals.gameState = Globals.gameStates.Init_Bases		#Establece el estado del juego para inicializar las bases.

		Globals.gameStates.Init_Bases:								#Game state = Initialise bases
			$Bases.createBases()									#Crea las bases
			if !self.has_node("Player"):							#Verifica si un jugador no sale.
				Globals.gameState = Globals.gameStates.Init_Player	#Establece el estado del juego para inicializar al jugador
			else:
				Globals.gameState = Globals.gameStates.Init_SpaceShip	#Establece el estado del juego para inicializar la nave espacial
				
		Globals.gameStates.Init_Player:								#Game state = Initialise player
			Player = oPlayer.instance()								#Crea una nueva instancia de jugador
			Player.name = "Player"									#Nombra al jugador
			Player.connect("Hit", self,"_on_playerHit")				#Conecta la señal de reproducción a este nodo
			Player.add_to_group("player")							#Agrega el jugador al grupo de jugadores
			self.add_child(Player)									#Agrega el jugador a este nodo
			Globals.HUD.showMessage("Get Ready",2)					#Muestra un mensaje de preparación en el hud
			Globals.playerState = Globals.playerStates.Alive		#Establece el estado de los jugadores en vivo
			Globals.gameState = Globals.gameStates.Init_SpaceShip	#Establece el estado del juego para iniciar la nave espacial
			
		Globals.gameStates.Init_SpaceShip:							#Game state = Initialise spaceship
			if !Globals.gameFreeze:									#Comprueba si el juego no está congelado
				$SpaceShipTimer.start(getRand_Range(MinSpaceShipDelay,MaxSpaceShipDelay,1)) #Inicia el cronómetro de la nave espacial extraterrestre 
				Globals.gameState = Globals.gameStates.In_Play		#Establece el estado del juego en juego

		Globals.gameStates.Game_Over:								#Game state = Game over
			if !Globals.gameFreeze:									#Comprueba si el juego no está congelado
				Globals.gameState = Globals.gameStates.Title		#Establece el estado del juego en la pantalla de título

#Inicializa la función del juego
func _init_game():
	Globals.Lives = 2							#Establece la vida de los jugadores
	Globals.Level = 1							#Establece el nivel inicial
	Globals.Score = 0							#Limpia la puntuación
	Globals.HiScore = 10000						#Establece un valor inicial de puntuación alta
	$Aliens.MaxAlienBullets = 3					#Establece el número inicial de balas alienígenas.
	$Aliens.Generate_Aliens()					#Genera los extraterrestres
	if !$Aliens.get_signal_connection_list("allAliensDestroyed"):	#Si todos los alienígenas destruidos no están conectados actualmente
		$Aliens.connect("allAliensDestroyed", self, "_on_allAliensDestroyed")	#Conecta la señal de todos los alienígenas destruidos a este nodo.
	$Aliens.AliensInitialised = false			#Borra la bandera inicializada de los alienígenas.
	$Bases.basesCreated = false					#Limpia la bandera de bases creadas

#Inicializar función alienígena
func _init_Aliens():
	$Aliens.AliensInitialised = false			#Borra la bandera inicializada de los alienígenas.
	$Bases.basesCreated = false					#Limpia la bandera de bases creadas
	$Aliens.InitialiseAliens()					#Inicializar a los extraterrestres
	$SpaceShipTimer.start(getRand_Range(MinSpaceShipDelay,MaxSpaceShipDelay,1)) #Inicia el cronómetro de la nave espacial extraterrestre

#Todos los extraterrestres destruyeron la función
func _on_allAliensDestroyed():
	if Globals.gameState == Globals.gameStates.In_Play:		#Comprueba que el juego se está reproduciendo
		Globals.Score += Globals.BonusPoints				#Añade puntos de bonificación por matar una ola de alienígenas
		Globals.Level += 1									#Incrementa el nivel
		$Aliens.MaxAlienBullets = clamp((int(Globals.Level / 5)+3),3,10)	#Añade otra bala alienígena por cada 10 niveles
		Globals.gameState = Globals.gameStates.Init_Aliens	#Establece el estado del juego para inicializar alienígenas
		Globals.HUD.showMessage("Wave Clear, Get Ready!",2)	#Muestra un mensaje de preparación en el hud

#Los extraterrestres han aterrizado en función
func _AliensHaveLanded():
	if Globals.gameState == Globals.gameStates.In_Play:		#Comprueba que el juego se está reproduciendo
		Globals.HUD.showMessage("Aliens Have Landed, Game Over!",10)	#Muestra un mensaje de finalización del juego
		Globals.gameState = Globals.gameStates.Game_Over				#Establece el estado del juego en fin del juego
		Globals.playerState = Globals.playerStates.Dead					#Establece el estado del jugador a muerto

#El jugador ha sido golpeado funcion
func _on_playerHit(player):
	if Globals.gameState == Globals.gameStates.In_Play:		#Comprueba que el juego se está reproduciendo.
		var playerBullets = get_tree().get_nodes_in_group("playerBullet")	#Obtiene una referencia a las balas de cualquier jugador.
		for b in playerBullets:								#Recorre las balas
			b.queue_free()									#Elimina la bala
		var oNew_PlayerExplosion = oExplosion.instance()	#crea una instancia de explosión
		oNew_PlayerExplosion.position = player.position		#Establece la posición de la explosión a la del jugador
		oNew_PlayerExplosion.name = player.name + "_Explosion"				#Nombra el nodo de explosión
		oNew_PlayerExplosion.connect("playerReset",self,"_on_playerReset")	#Conecta la señal de reinicio del reproductor a este nodo
		self.add_child(oNew_PlayerExplosion)								#Agrega la instancia de explosión a este nodo
		player.queue_free()									#elimina el nodo del reproductor
		Globals.playerState = Globals.playerStates.Dying	#Establece el estado del jugador en morir

#Función de reinicio del jugador (llamada por una explosión del jugador)
func _on_playerReset(explosion):
		if Globals.Lives > 0:									#Verifica si el jugador tiene vidas restantes
			Globals.Lives -=1									#Disminuye el número de vidas restantes
			Globals.gameState = Globals.gameStates.Init_Player	#Establece el estado del juego para inicializar al jugador
		else:
			Globals.Lives -=1									#Disminuye el número de vidas restantes
			Globals.HUD.showMessage("Game Over",10)				#Muestra un mensaje de finalización del juego en el hud
			Globals.gameState = Globals.gameStates.Game_Over	#Establece el estado del juego en fin del juego
			Globals.playerState = Globals.playerStates.Dead		#Establece el estado del jugador a muerto
				
#Elije un número aleatorio entre valores bajos y altos (tipo: 0 = entero, 1 = float)
func getRand_Range(low,high, type):
	var rng = RandomNumberGenerator.new()			#Inicializa un generador de números aleatorios
	rng.randomize()									#aleatoriza el resultado
	if type == 0:									#Comprueba si se solicita un número entero
		return rng.randi_range( low, high)			#Devuelve un entero aleatorio entre los dos valores especificados
	else:
		return rng.randf_range( low, high)			#Devuelve un float aleatorio entre los dos valores especificados

#Genera una función de nave espacial
func spawnSpaceShip(dir):
	if $Aliens.AliveAliens > 5:						#Comprueba que hay al menos 6 alienígenas vivos
		var oNew_SpaceShip = oSpaceShip.instance()	#Crea una nueva instancia de nave espacial
		if dir == -1:								#Consulta la solicitud de dirección
			oNew_SpaceShip.position = Vector2(Globals.Screen_Size.x + 16, SpaceShipYPosition)	#Establece la posición inicial de la nave espacial fuera de la pantalla a la derecha
		else:
			oNew_SpaceShip.position = Vector2(0 - 16, SpaceShipYPosition) 						#Establece la posición inicial de la nave espacial fuera de la pantalla a la izquierda
		oNew_SpaceShip.Direction = dir				#Establece la dirección de la nave espacial
		oNew_SpaceShip.name = "SpaceShip"			#Nombra la instancia de la nave espacial
		oNew_SpaceShip.connect("removeShip",self,"_on_SpaceShipRemove")							#Conecta la señal de eliminación del barco a este nodo
		self.add_child(oNew_SpaceShip)				#Agrega la nave espacial para ser hijo de este nodo.

#Eliminar la función de nave espacial		
func _on_SpaceShipRemove(ship: Node, bulletObj: Node, hit: bool):
	if hit:									#Comprueba si el barco fue alcanzado
		Globals.Score += ship.PointValue	#Incrementa la puntuación por el valor de puntos de la nave espacial.
		bulletObj._removeBullet()			#Quita la bala
		var oNew_SpaceShipExplosion = oSpaceShipExplosion.instance()			#Crea una instancia de explosión de nave espacial
		oNew_SpaceShipExplosion.position = ship.position						#Establece la posición de la explosión en la de la nave espacial
		oNew_SpaceShipExplosion.name = ship.name + "_Explosion"					#Nombra la instancia de explosión
		self.add_child(oNew_SpaceShipExplosion)									#Nombra la instancia de explosióNombra la instancia de explosión
	ship.queue_free()						#Quita la nave espacial
	$SpaceShipTimer.start(getRand_Range(MinSpaceShipDelay,MaxSpaceShipDelay,1)) #Inicia el cronómetro de la nave espacial extraterrestre
	
	#Temporizador de nave espacial
func _on_SpaceShipTimer_timeout():
	var rnd = getRand_Range(-1,1,0)		#Obtener un número aleatorio entre -1 y 1
	if rnd != 0:						#Comprueba que el número no sea 0
		spawnSpaceShip(rnd)				#Genera una nueva nave espacial
	else:
		$SpaceShipTimer.start(getRand_Range(MinSpaceShipDelay,MaxSpaceShipDelay,1)) #Inicia el cronómetro de la nave espacial extraterrestre
