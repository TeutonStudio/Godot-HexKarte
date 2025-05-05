@tool
extends EditorPlugin

const NODES = [
	["HexKarte3D", "Node3D", preload("res://addons/HexSystem/Skripte/HexKarte_node_skript.gd"), preload("res://addons/HexSystem/Symbole/hex_karte.svg")],
	["HexNode3D", "Node3D", preload("res://addons/HexSystem/Manipulatoren/hex_node_skript.gd"), preload("res://addons/HexSystem/Symbole/hexagon.svg")]
]


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	for jedes in NODES:
		add_custom_type(jedes[0], jedes[1], jedes[2], jedes[3])



func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	for jedes in NODES:
		remove_custom_type(jedes[0])
