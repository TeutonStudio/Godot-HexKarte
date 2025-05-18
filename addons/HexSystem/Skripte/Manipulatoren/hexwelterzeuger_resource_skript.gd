@tool
class_name HexWeltErzeuger
extends Resource

@export_group("Welteinstellungen")
@export var welt_radius: int = 5
@export var chunk_radius: int = 2
@export var maximale_höhe: int = 250
@export var höhenkarte: NoiseTexture2D
@export var wälder: NoiseTexture2D

@export_group("Weltmanipulatoren")
@export var flüße: Array[HexPfad] = []
@export var wege: Array[HexPfad] = []

func erzeuge_welt() -> HexWelt:
	var welt := HexWelt.new(welt_radius, chunk_radius)
	_höhenkarte_anwenden(welt)
	_setze_küsten(welt)
	#_wälder_anwenden(welt)
	#_manipulatoren_anwenden(welt)
	return welt

func _höhenkarte_anwenden(welt: HexWelt) -> void:
	for axial: PackedInt32Array in welt._HEX_data.keys():
		var hex := welt.erhalte_hex_nach_axial_global(Vector2i(axial[0],axial[1]))
		var verschiebung := 25
		var euler_pos = NodeHex.erhalte_euler_nach_axial_mit_vektor(hex.axial_global)
		var rauschwert := höhenkarte.noise.get_noise_2d(euler_pos.x, euler_pos.z)
		var höhe: int = max(0, abs(rauschwert * (maximale_höhe + verschiebung)) - verschiebung)
		
		hex.höhe = höhe
	
	# Setze Kanten mit nicht 0 Höhe auf Boden
	for kante: PackedInt32Array in welt._KANTEN_data.keys():
		var hex1 := welt.erhalte_hex_nach_axial_global(Vector2i(kante[0], kante[1]))
		var hex2 := welt.erhalte_hex_nach_axial_global(Vector2i(kante[2], kante[3]))
		if hex1.höhe != 0 or hex2.höhe != 0:
			welt._KANTEN_data[kante] = Hex.VARIANTEN.Boden
		else: welt._KANTEN_data[kante] = Hex.VARIANTEN.Meer

func _setze_küsten(welt: HexWelt) -> void:
	for kante: PackedInt32Array in welt._KANTEN_data.keys():
		var hex_kante1 := welt.erhalte_hex_nach_axial_global(Vector2i(kante[0], kante[1]))
		var hex_kante2 := welt.erhalte_hex_nach_axial_global(Vector2i(kante[2], kante[3]))
		var seite := HexSys.erhalte_richtung_nach_axial_mit_vektor(hex_kante2.axial_global - hex_kante1.axial_global)
		if seite == -1: push_error(["Hexagone nicht nebeneinander",hex_kante1.axial_global,hex_kante2.axial_global])
		
		var ecke1 := hex_kante1.axial_global + HexSys.erhalte_axial_richtung(seite + 1)
		var ecke2 := hex_kante1.axial_global + HexSys.erhalte_axial_richtung(seite - 1)
		var hex_ecke1 := welt.erhalte_hex_nach_axial_global(ecke1)
		var hex_ecke2 := welt.erhalte_hex_nach_axial_global(ecke2)#
		
		# Prüfe, ob eine Kante zwischen Meer und Boden liegt
		if hex_kante1.höhe == 0 and hex_kante2.höhe == 0:
			var ist_meer1 := hex_ecke1.höhe == 0 and hex_ecke2.höhe != 0
			var ist_meer2 := hex_ecke1.höhe != 0 and hex_ecke2.höhe == 0
			if ist_meer1 or ist_meer2: welt._KANTEN_data[kante] = Hex.VARIANTEN.Küste

func _wälder_anwenden(welt: HexWelt) -> void: if wälder:
	for axial in welt._HEX_data.keys():
		var hex := welt.erhalte_hex_nach_axial_global(axial)
		var euler_pos = NodeHex.erhalte_euler_nach_axial_mit_vektor(axial)
		var rauschwert := wälder.noise.get_noise_2d(euler_pos.x, euler_pos.z)
		
		if rauschwert > .4:
			hex.natur.append(Hex.NATUR.Wald)
			hex.natur_abgewirtschaftet = 1
			if rauschwert > .6:
				hex.natur_abgewirtschaftet = 2
				if rauschwert > .8:
					hex.natur_abgewirtschaftet = 3

func _manipulatoren_anwenden(welt: HexWelt) -> void:
	var fluss_kanten := erhalte_kanten(flüße, Hex.VARIANTEN.Fluß, welt)
	var weg_kanten := erhalte_kanten(wege, Hex.VARIANTEN.Weg, welt)
	
	# Wende Kanten-Varianten an
	for kante: PackedInt32Array in fluss_kanten:
		welt._KANTEN_data[kante] = Hex.VARIANTEN.Fluß
	for kante: PackedInt32Array in weg_kanten:
		welt._KANTEN_data[kante] = Hex.VARIANTEN.Weg

static func erhalte_kanten(
	liste: Array[HexPfad], 
	variante: Hex.VARIANTEN,
	welt: HexWelt,
) -> Array[PackedInt32Array]:
	var kanten: Array[PackedInt32Array] = []
	
	if not liste.is_empty():
		for pfad in liste:
			pfad.vervollständige_betroffene_hex()
			kanten.append_array(pfad.betroffene_kanten)
	
	return kanten
