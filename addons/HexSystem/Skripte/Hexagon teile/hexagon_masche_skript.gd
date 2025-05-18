@tool
class_name HexagonMasche
extends Resource

enum ART {
	Natur,
	Ebene,
	Seite,
	Untergrund,
}

@export_storage var art: HexagonMasche.ART:
	set(wert): art = wert; self.notify_property_list_changed()
@export var masche: Mesh

@export_storage var _seiten: Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN] = {}
#@export var linksoben: Hex.VARIANTEN
#@export var oben: Hex.VARIANTEN
#@export var rechtsoben: Hex.VARIANTEN
#@export var linksunten: Hex.VARIANTEN
#@export var unten: Hex.VARIANTEN
#@export var rechtsunten: Hex.VARIANTEN

#region

#func _init() -> void:
		#linksoben = Hex.VARIANTEN.Meer
		#oben = Hex.VARIANTEN.Meer
		#rechtsoben = Hex.VARIANTEN.Meer
		#linksunten = Hex.VARIANTEN.Meer
		#unten = Hex.VARIANTEN.Meer
		#rechtsunten = Hex.VARIANTEN.Meer

func _get_property_list() -> Array[Dictionary]:
	var ausgabe: Array[Dictionary] = []
	
	var ist_ebene := art == HexagonMasche.ART.Ebene
	var ist_seite := art == HexagonMasche.ART.Seite or art == HexagonMasche.ART.Untergrund
	
	if ist_ebene: for seite: String in HexSys.HEX_RICHTUNG.keys(): 
		_erzeuge_eintrag(ausgabe,seite.to_lower())
	if ist_seite: _erzeuge_eintrag(ausgabe,"nebenan")
	
	return ausgabe

func _erzeuge_eintrag(
	ausgabe: Array[Dictionary], 
	name: String
) -> void: ausgabe.append_array([{
	"name": "filter/" + name,
	"type": TYPE_INT,
	"hint": PROPERTY_HINT_ENUM,
	"hint_string": ",".join(Hex.VARIANTEN.keys()),
}])

func _set(eigenschaft: StringName, wert: Variant) -> bool:
	var struktur := eigenschaft.split("/")
	
	if struktur[0] == "filter":
		var schlüssel := struktur[1]
		
		if schlüssel == "linksoben":
			_seiten[HexSys.HEX_RICHTUNG.Linksoben] = wert
			return true
		if schlüssel == "rechtsoben":
			_seiten[HexSys.HEX_RICHTUNG.Rechtsoben] = wert
			return true
		if schlüssel == "linksunten":
			_seiten[HexSys.HEX_RICHTUNG.Linksunten] = wert
			return true
		if schlüssel == "rechtsunten":
			_seiten[HexSys.HEX_RICHTUNG.Rechtsunten] = wert
			return true
		if schlüssel == "oben":
			_seiten[HexSys.HEX_RICHTUNG.Oben] = wert
			return true
		if schlüssel == "unten":
			_seiten[HexSys.HEX_RICHTUNG.Unten] = wert
			return true
		
		if schlüssel == "nebenan": 
			_seiten[HexSys.HEX_RICHTUNG.Oben] = wert
			return true
	
	return false

func _get(eigenschaft: StringName) -> Variant:
	var struktur := eigenschaft.split("/")
	
	if struktur[0] == "filter":
		var schlüssel := struktur[1]
		
		if schlüssel == "linksoben":
			return _seiten.get_or_add(HexSys.HEX_RICHTUNG.Linksoben,Hex.VARIANTEN.Meer)
		if schlüssel == "rechtsoben":
			return _seiten.get_or_add(HexSys.HEX_RICHTUNG.Rechtsoben,Hex.VARIANTEN.Meer)
		if schlüssel == "linksunten":
			return _seiten.get_or_add(HexSys.HEX_RICHTUNG.Linksunten,Hex.VARIANTEN.Meer)
		if schlüssel == "rechtsunten":
			return _seiten.get_or_add(HexSys.HEX_RICHTUNG.Rechtsunten,Hex.VARIANTEN.Meer)
		if schlüssel == "oben":
			return _seiten.get_or_add(HexSys.HEX_RICHTUNG.Oben,Hex.VARIANTEN.Meer)
		if schlüssel == "unten":
			return _seiten.get_or_add(HexSys.HEX_RICHTUNG.Unten,Hex.VARIANTEN.Meer)
		
		if schlüssel == "nebenan": 
			return _seiten.get_or_add(HexSys.HEX_RICHTUNG.Oben,Hex.VARIANTEN.Meer)
	
	return

#endregion

func erhalte_richtungen() -> Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN]:
	if art == HexagonMasche.ART.Ebene:
		return {
			HexSys.HEX_RICHTUNG.Linksoben: get("filter/linksoben"),
			HexSys.HEX_RICHTUNG.Rechtsoben: get("filter/rechtsoben"),
			HexSys.HEX_RICHTUNG.Linksunten: get("filter/linksunten"),
			HexSys.HEX_RICHTUNG.Rechtsunten: get("filter/rechtsunten"),
			HexSys.HEX_RICHTUNG.Oben: get("filter/oben"),
			HexSys.HEX_RICHTUNG.Unten: get("filter/unten"),
		}
	if art == HexagonMasche.ART.Seite or art == HexagonMasche.ART.Untergrund: 
		return {
			HexSys.HEX_RICHTUNG.Oben: get("filter/nebenan"),
		}
	
	return {}

func ist_teil(richtungen: Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN]) -> bool:
	var ausgabe := false
	
	for idx: HexSys.HEX_RICHTUNG in HexSys.HEX_RICHTUNG.keys():
		if _ist_gleich(HexBibliothek.rotiere(erhalte_richtungen(),idx),richtungen): 
			ausgabe = true
	
	return ausgabe

func _ist_gleich(
	richtungen1: Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN],
	richtungen2: Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN],
) -> bool:
	var ausgabe := true
	
	for idx: HexSys.HEX_RICHTUNG in HexSys.HEX_RICHTUNG.values():
		if richtungen1[idx] == -1: continue
		if richtungen2[idx] == -1: continue
		ausgabe = ausgabe and richtungen1[idx] == richtungen2[idx]
	
	return ausgabe

func erhalte_rotationswinkel(richtungen: Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN]) -> float:
	var drehung: int
	
	for idx: HexSys.HEX_RICHTUNG in HexSys.HEX_RICHTUNG.values():
		if _ist_gleich(HexBibliothek.rotiere(erhalte_richtungen(),idx+3),richtungen): 
			drehung = idx
	
	return NodeHex.erhalte_winkel_nach_richtung(drehung)

#static func _rotiere(
	#argument: Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN], 
	#rotation: HexSys.HEX_RICHTUNG,
#) -> Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN]:
	#var ausgabe: Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN] = {}
	#for idx in HexSys.HEX_RICHTUNG.size(): 
		#var rotierter_idx := (36 + idx - rotation) % 6
		#ausgabe[idx] = argument[rotierter_idx]
	#return ausgabe

## Gibt alle möglichen Rotationen einer Richtungsliste zurück.
func erhalte_alle_rotationen(
	arg: Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN] = erhalte_richtungen(),
) -> Array[Dictionary]:
	var ausgabe: Array[Dictionary] = []
	for seite in 6: ausgabe.append(HexBibliothek.rotiere(arg, seite))
	return ausgabe
