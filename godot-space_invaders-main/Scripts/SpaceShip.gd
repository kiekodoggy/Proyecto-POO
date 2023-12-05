extends Node2D
signal removeShip()

# Declara las variables miembro aquí. Ejemplos:
var Speed = 50
var Directions = {-1: "TravelLeft",1: "TravelRight"}
var Direction: int
var Size = Vector2()
var PointValue: int

# Se llama cuando el nodo ingresa al árbol de escena por primera vez
func _ready():
	Size = $Sprite.get_texture().get_size()
	$AnimationPlayer.play(str(Directions[Direction]))
	PointValue = (getRand_Range(1,10,0)*100)
# Llamó a cada fotograma. 'delta' es el tiempo transcurrido desde el cuadro anterior
func _process(delta):
	position.x += (Speed * delta) * Direction
	if (position.x < 0 - Size.x and Direction == -1) or (position.x > Globals.Screen_Size.x	+ Size.y and Direction == 1):
		_removeShip(null,false)

func _setDirection(dir,spd):
	Direction = dir
	Speed = spd

func _removeShip(obj,hit):
	emit_signal("removeShip",self,obj,hit)



#Elige un número aleatorio entre valores bajos y altos (tipo: 0 = entero, 1 = float)
func getRand_Range(low,high, type):
	var rng = RandomNumberGenerator.new()								#Inicializa un generador de números aleatorios
	rng.randomize()														#aleatoriza el resultado
	if type == 0:														#Comprueba si se solicita un número entero
		return rng.randi_range( low, high)								#devuelve un entero aleatorio entre los dos valores especificados
	else:
		return rng.randf_range( low, high)								#devuelve un float aleatorio entre los dos valores especificados


func _on_SpaceSHip_area_entered(area):
	if area.is_in_group("playerBullet"):					#Comprueba si el elemento ha sido golpeado por un alienígena
		area._removeBullet()								#siempre elimina la bala del jugador
		_removeShip(area,true)
