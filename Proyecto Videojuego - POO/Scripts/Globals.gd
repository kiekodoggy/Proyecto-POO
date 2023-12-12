extends Node

#Constantes
const gameStates = {							#Los estados del juego son posibles
	"Title": 1,
	"Init_Game": 10,
	"Init_Aliens": 11,
	"Init_Bases": 12, 
	"Init_Player": 13,
	"Init_SpaceShip": 14, 
	"In_Play":20,
	"Game_Over":50, 
	"Unknown":-1}
const playerStates = {							#Posibles estados del jugador
	"Alive":1, 
	"Dead":2, 
	"Dying":3}		

#Variables
var Score:int = 0 setget updateScore			#Puntuación del jugador
var HiScore:int = 0 setget updateHiScore 		#Hi-Score (no remanente desde el reinicio)
var Lives:int  = 0 setget updateLives			#Vidas del jugador a la izquierda
var Level:int = 0 setget updateLevel			#Nivel de juego (solo determina la fila inicial de alienígenas)
var LandedYPos:int = 230						#El nivel en pantalla en el que se considera que han aterrizado los extraterrestres
var AlienYShootLimit:int  =200					#El nivel en pantalla al que los extraterrestres ya no pueden disparar
var maxLevel = 15								#El nivel más alto en el que se pueden dibujar alienígenas en la pantalla
var Screen_Size:Vector2 = Vector2()				#Soporte para tamaño de pantalla
var OSScreen_Size:Vector2 = Vector2()			#Soporte de tamaño de pantalla del sistema operativo
var CurrentAlien:int							#El extranjero actualmente en proceso
var LiveAliens:int  = 0							#El numero de "alive"/visible aliens (alienigenas)
var NoOfAliens:int = 0							#El número total de extranjeros
var BaseColour = Color8(0,190,0)				#El color de las bases
var PlayerColour = Color8(0,190,0)				#El color para el jugador
var HUD:Node									#Un puntero al HUD
var gameFreeze: bool							#Una bandera para indicar que el juego debe congelarse/pausarse
var gameState = gameStates.Unknown				#El estado del juego (actual)
var playerState = playerStates.Dead				#El estado del jugador (actual)
var BonusPoints:int = 100						#Los puntos de bonificación por eliminar una ronda de alienígenas

#Actualizar la función de nivel
func updateLevel(val):							#Actualiza el valor del nivel en el HUD
	if !HUD:									#Obtiene una referencia al HUD si aún no lo hemos hecho
		 HUD = get_node("/root/Main/HUD")		#Mantiene la referencia
	Level = val									#Actualiza el nivel
	HUD.updateLevel(1,Level)					#Llama al HUD con la actualización

#Actualiza la función de puntuación
func updateScore(val):							#Actualiza el valor de la puntuación en el HUD
	if !HUD:									#Obtiene una referencia al HUD si aún no lo hemos hecho
		 HUD = get_node("/root/Main/HUD")		#Mantiene la referencia
	Score = val									#Actualiza la puntuación
	HUD.updateScore(1,Score)					#Llama al HUD con la actualización
	if Score > HiScore:							#Comprueba si tenemos un nuevo puntaje alto
		updateHiScore(Score)					#Actualiza el valor de puntuación alta

#Actualiza la función de vidas
func updateLives(val):							#Actualiza el reproductor que vive en el hud
	if !HUD:									#Obtiene una referencia al HUD si aún no lo hemos hecho
		 HUD = get_node("/root/Main/HUD")		#Mantiene la referencia
	Lives = val									#Actualiza el recuento de vidas
	HUD.updateLives(1,Lives)					#Llama al HUD con la actualización

#Actualiza la función de puntuación alta
func updateHiScore(val):						#Actualiza la puntuación alta en el hud
	if !HUD:									#Obtiene una referencia al HUD si aún no lo hemos hecho.
		 HUD = get_node("/root/Main/HUD")		#Mantiene la referencia
	HiScore = val								#Actualiza la puntuación alta
	HUD.updateScore(0,HiScore)					#Llama al HUD con la actualización
	
#Elige un número aleatorio entre valores bajos y altos (tipo: 0 = entero, 1 = float)
func getRand_Range(low,high, type):
	var rng = RandomNumberGenerator.new()		#Inicializa un generador de números aleatorios
	rng.randomize()								#Aleatoriza el resultado
	if type == 0:								#Comprueba si se solicita un número entero
		return rng.randi_range( low, high)		#Devuelve un entero aleatorio entre los dos valores especificados
	else:
		return rng.randf_range( low, high)		#Devuelve un float aleatorio entre los dos valores especificados
