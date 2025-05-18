@tool
extends EditorPlugin

const NODES = [
	["NodeHex", "Node", preload("res://addons/HexSystem/Skripte/NodeHex_node_skript.gd"), null],
	["HexKarte", "NodeHex", preload("res://addons/HexSystem/Skripte/hexkarte_node_skript.gd"), null],
	["HexGlobus", "NodeHex", preload("res://addons/HexSystem/Skripte/hexglobus_node_skript.gd"), null],
	
	["HexBrille3D", "Node3D", preload("res://addons/HexSystem/Skripte/HexBrille_node_skript.gd"), null],
	["HexNode3D", "Node3D", preload("res://addons/HexSystem/Skripte/Manipulatoren/hex_node_skript.gd"), null]
]


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	for jedes in NODES:
		add_custom_type(jedes[0], jedes[1], jedes[2], jedes[3])



func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	for jedes in NODES:
		remove_custom_type(jedes[0])
