@tool
class_name HexagonSeite
extends HexagonMasche

func _init() -> void:
	self.art = HexagonMasche.ART.Seite

@export_enum("Kante","Untergrund") var variante: int:
	set(wert): 
		if wert == 0: self.art = HexagonMasche.ART.Seite
		else: self.art = HexagonMasche.ART.Untergrund
	get: return 0 if self.art == HexagonMasche.ART.Seite else 1
