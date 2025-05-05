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
	var welt := HexWelt.new(welt_radius,chunk_radius)
	_höhenkarte_anwenden(welt)
	_wälder_anwenden(welt)
	_manipulatoren_anwenden(welt)
	return welt


func _höhenkarte_anwenden(welt: HexWelt) -> void:
	for axial in welt.data.keys():
		var hex := welt.erhalte_hex_nach_axial_global(axial)
		var verschiebung := 15
		var chunk_radial := hex.radial_chunk
		var lokal_radial := hex.radial_lokal
		var euler_pos = HexSys.erhalte_euler_nach_axial_mit_vektor(axial)
		var rauschwert := höhenkarte.noise.get_noise_2d(euler_pos.x, euler_pos.z)
		var höhe: int = max(0,abs(rauschwert * (maximale_höhe + verschiebung)) - verschiebung)
		
		hex.höhe = höhe

func _wälder_anwenden(welt: HexWelt) -> void:
	for axial in welt.data.keys():
		var hex := welt.erhalte_hex_nach_axial_global(axial)
		var verschiebung := 15
		var chunk_radial := hex.radial_chunk
		var lokal_radial := hex.radial_lokal
		var euler_pos = HexSys.erhalte_euler_nach_axial_mit_vektor(axial)
		var rauschwert := höhenkarte.noise.get_noise_2d(euler_pos.x, euler_pos.z)
		var höhe: int = max(0,abs(rauschwert * (maximale_höhe + verschiebung)) - verschiebung)
		
		hex.natur.append(Hex.NATUR.Wald)

func _manipulatoren_anwenden(welt: HexWelt) -> void:
	for axial_global in welt.data.keys():
		var hex := welt.erhalte_hex_nach_axial_global(axial_global)
		hex.variante = Hex.VARIANTEN.Boden
	
	var fluss_hexes := erhalte_hexes(flüße,Hex.VARIANTEN.Fluß,welt)
	var weg_hexes := erhalte_hexes(wege,Hex.VARIANTEN.Weg,welt)
	
	for axial_global in fluss_hexes: if weg_hexes.has(axial_global):
		var hex := welt.erhalte_hex_nach_axial_global(axial_global)
		hex.variante = Hex.VARIANTEN.Kreuzung

static func erhalte_hexes(
	liste: Array[HexPfad], 
	variante: Hex.VARIANTEN,
	welt: HexWelt,
) -> Array[Vector2i]:
	var _hexes: Array[Vector2i] = []
	
	if not liste.is_empty(): for pfad in liste:
		pfad.vervollständige_betroffene_hex()
		
		for axial_global in pfad.betroffene: # if welt.existiert_hex_nach_axial_global(axial_global):
			var hex := welt.erhalte_hex_nach_axial_global(axial_global)
			var hex_höhe = hex.höhe
			if hex_höhe != 0: hex.variante = variante
			
			if not _hexes.has(axial_global): _hexes.append(axial_global)
	
	return _hexes
