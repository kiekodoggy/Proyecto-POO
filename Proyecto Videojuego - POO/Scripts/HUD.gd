extends CanvasLayer

#Precargar escenas
var sprPlayer = preload("res://GFX/Player.png")		#Precarga el sprite del reproductor

#Variables
var players = ["HI","1UP"]					#Matriz de jugador
var livesPos = Vector2(20,251)						#Un puntero a la ubicación de la imagen en vivo de la reproducción en el HUD

#Actualizar la puntuación
func updateScore(player,val):
	var obj = get_node(players[player] + "/Score")	#Obtiene una referencia del objeto de puntuación en el HUD
	obj.text = str(val).pad_zeros(6)				#actualiza la puntuación

#actualizar las vidas			
func updateLives(player,val):
	var sprW = sprPlayer.get_width()				#Obtiene el ancho del sprite del jugador
	var ll = $BottomBar/Lives						#Obtiene una referencia al área de vidas en la barra inferior del HUD
	var lives = Globals.Lives						#Quedan las vidas actuales
	for l in range(ll.get_child_count()):			#Recorre todas las imágenes en vivo del jugador
		var life = ll.get_child(l)					#Obtiene una referencia a la imagen del jugador específico
		life.queue_free()							#elimina la imagen
	for l in range(lives):											#recorre todas las vidas del jugador
		var pos = Vector2(livesPos.x + ((sprW) *l) ,livesPos.y)		#calcula la posición de la imagen del jugador
		var spr = Sprite.new()										#crea un nuevo sprite
		spr.texture = sprPlayer										#Configura el sprite a la imagen del jugador
		spr.scale = Vector2(0.75,0.75)								#Escala la imagen
		spr.position = pos											#Establece la posición de la imagen
		spr.name = "PlayerLife" + str(l+1)							#Nombra la imagen
		spr.modulate = Globals.PlayerColour							#Establece el color de la imagen
		ll.add_child(spr)											#Agrega el sprite como hijo de la barra de vidas
	$BottomBar/LivesLeft/Lives.text = str(lives+1)					#Actualiza el texto de vidas restantes

#Esta función mostrará un mensaje al usuario e introducirá un retraso que también pausará los movimientos.
func showMessage(msg,dly):
	Globals.gameFreeze = true						#Establece la bandera de congelación del juego
	$Message/Label.text = msg						#Establece el texto del cuadro de mensaje
	$Message.visible = true							#Muestra el cuadro de mensaje
	$Message/Anim.play("showMessage")				#Reproduce la animación del mensaje del programa
	yield($Message/Anim,"animation_finished")		#Espera hasta que la animación haya terminado de reproducirse
	yield(get_tree().create_timer(dly), "timeout")	#Espera a que haya transcurrido el temporizador de retraso
	$Message/Anim.play("hideMessage")				#Reproduce la animación de ocultar mensaje
	yield($Message/Anim,"animation_finished")		#Espera hasta que la animación haya terminado de reproducirse
	$Message.visible = false						#Oculta el cuadro de mensaje
	Globals.gameFreeze = false						#Descongela el juego

#Esta función mostrará/ocultará una página de título.
func showTitle(val):
	$TitleBox.visible = val							#Establece la visibilidad del cuadro de título

#Esta función actualizará la visualización del nivel
func updateLevel(player,val):
	$Level/Level.text = str(val)					#Establece el texto del nivel en el valor requerido
