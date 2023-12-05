extends Node2D

#Constantes
const baseElementWidth = 8							#el ancho del elemento base
const baseElementHeight = 8							#la altura del elemento base
const baseElementRows = 3							#el número de filas en una base
const baseElementCols = 4							#el número de columnas en una base
const upDir = 0										#Constante de dirección ascendente
const downDir = 1									#dirección descendente constante

#Precargar escenas
var obaseElement = preload("res://Scenes/baseElement.tscn")		#Precargar la escena del elemento base

#Variables
var baseStructure = [1,0,10,11,10,0,10,0,10,2,12,0]	#Esta es la construcción base por tipo de elemento
var Parent = self									#Un puntero a este nodo

#Inicialización
func _ready():
	createBase()									#Crea una base

#Procesamiento normal de nodos
func _process(delta):
	if get_child_count() == 0:						#Comprueba si se eliminan todos los elementos
		queue_free()								#quitar la base

#crear una estructura base de subelementos
func createBase():
	for rows in range(baseElementRows):				#Bucle para el número de filas en una estructura base
		for cols in range(baseElementCols):			#Bucle para el número de columnas en una estructura base
			var oNew_baseElement = obaseElement.instance()												#Instancia de un nuevo elemento base
			oNew_baseElement.name = "BaseElement_" + str(rows).pad_zeros(2) + str(cols).pad_zeros(2)	#Establece el nombre del elemento en la calle según su posición en la base.
			oNew_baseElement.position.x =  (cols * baseElementWidth)									#Establece la posición del elemento x
			oNew_baseElement.position.y = (rows * baseElementHeight)									#Establece la posición del elemento y
			oNew_baseElement.elemType = baseStructure[(rows* baseElementCols) + cols]					#Establece el tipo de elemento
			oNew_baseElement.connect("neighbourHit", self, "_on_neighbourHit")							#Conecta la señal de golpe del vecino de los elementos a esta base
			oNew_baseElement.connect("destroyBase", self, "_destroy")									#Conecta los elementos que destruyen la señal de la base a esta base
			Parent.add_child(oNew_baseElement)															#Agrega el elemento a esta base como hijo
			add_to_group("Base")																				#Añade esta base al grupo Base

#Esta función destruirá esta instancia base y llamará a la función de destroy para todos los elementos dentro de ella
func _destroy():
	for baseElement in self.get_children():			#Recorre todos los subelementos de esta base
		baseElement._destroy()						#destruir los subelementos
	queue_free()									#destruir esta base

#Esta función encontrará el vecino vertical del elemento que llama y
#Llama a la función de golpe externo dentro de él para avanzar el estado de la animación..
func _on_neighbourHit(element,dir):
	var rw = int(element.name.substr(12,2))			#Obtiene la fila del elemento que ha sido golpeado
	var nextElement									#Un puntero al siguiente elemento
	var nen											#El nombre del siguiente elemento
	if rw > 0 and dir == upDir:						#El vecino esta arriba
		nen = "BaseElement_" + str(rw -1).pad_zeros(2) + element.name.substr(14,2) #Calcular el nombre del elemento vecino.
		if has_node(nen):							#Comprueba si el vecino existe
			nextElement = get_node(nen)				#Obtener un puntero al elemento vecino
			nextElement.externalHit()				#Indica que el vecino también debe ser golpeado
	if rw < baseElementRows and dir == downDir:		#El vecino esta abajo
		nen = "BaseElement_" + str(rw +1).pad_zeros(2) + element.name.substr(14,2) #Calcular el nombre del elemento vecino.
		if has_node(nen):							#Comprueba si el vecino existe
			nextElement = get_node(nen)				#Obtiene un puntero al elemento vecino
			nextElement.externalHit()				#Indica que el vecino también debe ser golpeado
