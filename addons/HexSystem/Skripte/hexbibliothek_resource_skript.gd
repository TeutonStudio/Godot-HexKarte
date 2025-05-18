@tool
class_name HexBibliothek
extends Resource

@export var material: StandardMaterial3D:
	set(wert): material = wert; for jedes: HexagonMasche in data: jedes.masche.surface_set_material(0,wert)
@export var hexagon_breite := 2.0

@export var data: Array[HexagonMasche]

func finde_masche(
	art: HexagonMasche.ART,
	richtungen: Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN],
	fehler_asugabe: Variant = "",
) -> HexagonMasche:
	var alle_richtungen := erhalte_alle_rotationen(richtungen)
	
	for jedes: HexagonMasche in data: if jedes.art == art:
		var masche_richtungen := jedes.erhalte_richtungen()
		for hex_richtungen: Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN] in alle_richtungen:
			if art == HexagonMasche.ART.Seite or art == HexagonMasche.ART.Untergrund:
				if hex_richtungen[HexSys.HEX_RICHTUNG.Oben] == masche_richtungen.get(HexSys.HEX_RICHTUNG.Oben):
					return jedes
			elif hex_richtungen == masche_richtungen: return jedes
	
	var protokoll: Dictionary[String, String] = {}
	for seite: int in richtungen.keys():
		var schlüssel = HexSys.HEX_RICHTUNG.keys()[seite]
		var wert = Hex.VARIANTEN.keys()[richtungen.get(seite)]
		protokoll[schlüssel] = wert
	push_warning(["Keine Masche für ",protokoll," bei ",fehler_asugabe])
	return null

#@export_group("Ebene")
#@export var ebene_gras: Mesh
#@export var ebene_wasser: Mesh
#@export_subgroup("Küste")
#@export var küste_0: Mesh
#@export var küste_1: Mesh
#@export var küste_2: Mesh
#@export var küste_3: Mesh
#@export var küste_4: Mesh
#@export_subgroup("Fluß")
#@export var fluß_a: Mesh
#@export var fluß_b: Mesh
#@export var fluß_c: Mesh
#@export var fluß_d: Mesh
#@export var fluß_e: Mesh
#@export var fluß_f: Mesh
#@export var fluß_g: Mesh
#@export var fluß_h: Mesh
#@export var fluß_i: Mesh
#@export var fluß_j: Mesh
#@export var fluß_k: Mesh
#@export var fluß_l: Mesh
#@export var fluß_m: Mesh
#@export_subgroup("Wege")
#@export var weg_a: Mesh
#@export var weg_b: Mesh
#@export var weg_c: Mesh
#@export var weg_d: Mesh
#@export var weg_e: Mesh
#@export var weg_f: Mesh
#@export var weg_g: Mesh
#@export var weg_h: Mesh
#@export var weg_i: Mesh
#@export var weg_j: Mesh
#@export var weg_k: Mesh
#@export var weg_l: Mesh
#@export var weg_m: Mesh
#@export_subgroup("Kreuzungen")
#@export var fluß_weg: Mesh
#@export var weg_fluß: Mesh

#static func erhalte_küste_liste() -> PackedStringArray:
	#var ausgabe: PackedStringArray = []
	#for i in 5: ausgabe.append("küste_" + str(i))
	#return ausgabe
#
#static func erhalte_fluß_liste() -> PackedStringArray:
	#var ausgabe: PackedStringArray = []
	#for buchstabe in BUCHSTABEN_LISTE: ausgabe.append("fluß_" + buchstabe)
	#return ausgabe
#
#static func erhalte_weg_liste() -> PackedStringArray:
	#var ausgabe: PackedStringArray = []
	#for buchstabe in BUCHSTABEN_LISTE: ausgabe.append("weg_" + buchstabe)
	#return ausgabe
#
#const BUCHSTABEN_LISTE := ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m"]

## Rotiert eine Liste von Richtungen um eine gegebene Anzahl von Schritten.
static func rotiere(
	arg: Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN], 
	rotation: HexSys.HEX_RICHTUNG
) -> Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN]:
	var ausgabe: Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN] = {}
	for idx in HexSys.HEX_RICHTUNG.size(): 
		var rotierter_idx := (36+idx-rotation) % 6
		ausgabe[idx] = arg.get(rotierter_idx, Hex.VARIANTEN.Boden)
	return ausgabe

## Gibt alle möglichen Rotationen einer Richtungsliste zurück.
static func erhalte_alle_rotationen(
	arg: Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN]
) -> Array[Dictionary]:
	var ausgabe: Array[Dictionary] = []
	for seite in 6: ausgabe.append(rotiere(arg, seite))
	return ausgabe

#static func erhalte_richtungen_nach_buchstabe(
	#buchstabe: StringName, 
	#variante: Hex.VARIANTEN,
	#boden := Hex.VARIANTEN.Boden,
#) -> Array[Dictionary]:
	#var base_directions: Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN] = {
		#HexSys.HEX_RICHTUNG.Linksoben: 		boden,
		#HexSys.HEX_RICHTUNG.Oben: 			boden,
		#HexSys.HEX_RICHTUNG.Rechtsoben: 	boden,
		#HexSys.HEX_RICHTUNG.Rechtsunten: 	boden,
		#HexSys.HEX_RICHTUNG.Unten: 			boden,
		#HexSys.HEX_RICHTUNG.Linksunten: 	boden,
	#}
	#
	#match buchstabe:
		#"a":
			#base_directions[HexSys.HEX_RICHTUNG.Oben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Unten] = variante
		#"b":
			#base_directions[HexSys.HEX_RICHTUNG.Linksoben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Unten] = variante
		#"c":
			#base_directions[HexSys.HEX_RICHTUNG.Unten] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Linksunten] = variante
		#"d":
			#base_directions[HexSys.HEX_RICHTUNG.Linksoben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Rechtsoben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Unten] = variante
		#"e":
			#base_directions[HexSys.HEX_RICHTUNG.Linksoben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Oben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Unten] = variante
		#"f":
			#base_directions[HexSys.HEX_RICHTUNG.Oben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Rechtsoben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Unten] = variante
		#"g":
			#base_directions[HexSys.HEX_RICHTUNG.Rechtsunten] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Unten] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Linksunten] = variante
		#"h":
			#base_directions[HexSys.HEX_RICHTUNG.Oben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Rechtsunten] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Unten] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Linksunten] = variante
		#"i":
			#base_directions[HexSys.HEX_RICHTUNG.Linksoben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Rechtsoben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Rechtsunten] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Linksunten] = variante
		#"j":
			#base_directions[HexSys.HEX_RICHTUNG.Oben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Rechtsoben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Rechtsunten] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Unten] = variante
		#"k":
			#base_directions[HexSys.HEX_RICHTUNG.Linksoben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Rechtsoben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Rechtsunten] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Unten] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Linksunten] = variante
		#"l":
			#base_directions[HexSys.HEX_RICHTUNG.Linksoben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Oben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Rechtsoben] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Rechtsunten] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Unten] = variante
			#base_directions[HexSys.HEX_RICHTUNG.Linksunten] = variante
		#"m":
			#base_directions[HexSys.HEX_RICHTUNG.Unten] = variante
	#return erhalte_alle_rotationen(base_directions)



#@export_group("Seiten")
#@export var seite_gras: Mesh
#@export var seite_gras_untergrund: Mesh
#@export_subgroup("Fluß")
#@export var seite_fluß: Mesh
#@export var seite_fluß_untergrund: Mesh
#@export_subgroup("Wege")
#@export var seite_weg: Mesh
#@export var seite_weg_untergrund: Mesh
#
#@export_group("Umgebung")
#@export_subgroup("Wald")
#@export var natur_wald_1: Mesh
#@export var natur_wald_2: Mesh
#@export var natur_wald_3: Mesh
#@export var natur_lichtung: Mesh
#@export_subgroup("Gebirge")
