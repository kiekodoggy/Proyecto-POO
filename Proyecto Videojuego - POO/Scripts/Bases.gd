extends Node

#Precargar escenas
var obase = preload("res://Scenes/Base.tscn")	#Precarga la escena base

#Variables
var Parent = self								#Una referencia a este nodo
var numBases = 4								#El número total de bases
var baseXStart = 16								#La posición X inicial de la primera base
var baseYStart = 215							#La posición Y inicial de la primera base
var baseXSpace = 56								#El espaciado X de las bases
var basesCreated = false						#Bandera de bases creadas

#Crea las bases
func createBases():
	for i in range(numBases):										#Recorre todas las bases para crear
		var oNew_base = obase.instance()							#Instancia de una base
		oNew_base.name = "Base_" + str(i)							#Nombra la base
		oNew_base.position.x =  (baseXStart + (i * baseXSpace))		#Establece la posición base X
		oNew_base.position.y = (baseYStart)							#Establece la posición Y de la base
		oNew_base.add_to_group("Bases")										#Agrega la base al grupo Bases
		Parent.add_child(oNew_base)									#Agrega la base como hijo de este nodo
	basesCreated = true												#Indica que las bases han sido creadas

#Recrea las bases
func reCreateBases():
	if !basesCreated:							#Comprueba si las bases aún no han sido creadas
		for base in self.get_children():		#Primer bucle a través de las bases existentes
			base._destroy()						#Destruye la base
		createBases()							#Crea nuevas bases

#Destruye todas las bases
func DestroyAll():
		for base in self.get_children():		#Recorre todas las bases
			base._destroy()						#Destruye la base
