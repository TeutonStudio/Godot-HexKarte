@tool
class_name GebäudeBibliothek
extends Resource

@export var gebäude: Dictionary[String,PackedScene]


func erhalte_gebäude_liste() -> PackedStringArray:
	return PackedStringArray(gebäude.keys())
