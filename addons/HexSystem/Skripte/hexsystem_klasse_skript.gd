class_name HexSys

enum POLE {
	Nordpol,
	Südpol,
}
enum HEX_RICHTUNG {
	Linksoben, Oben, Rechtsoben, 
	Rechtsunten, Unten, Linksunten, 
}
enum KUBIAL_RICHTUNG {
	Obenhinten,
	Untenhinten,
	Vorne,
}

#region Axial

static func erhalte_axial_richtung(seite: int) -> Vector2i: 
	var ausgabe := Vector2i.ZERO
	match (36 + seite) % HEX_RICHTUNG.size():
										HEX_RICHTUNG.Linksoben: 
											ausgabe = Vector2i(1, 0)
										HEX_RICHTUNG.Oben: 
											ausgabe = Vector2i(1, 1)
										HEX_RICHTUNG.Rechtsoben: 
											ausgabe = Vector2i(0, 1)
										
										HEX_RICHTUNG.Rechtsunten: 
											ausgabe = Vector2i(-1, 0)
										HEX_RICHTUNG.Unten: 
											ausgabe = Vector2i(-1, -1)
										HEX_RICHTUNG.Linksunten: 
											ausgabe = Vector2i(0, -1)
	return ausgabe

static func erhalte_richtung_nach_axial(linksoben: int, obenrechts: int) -> HexSys.HEX_RICHTUNG: 
	return erhalte_richtung_nach_axial_mit_vektor(Vector2i(linksoben,obenrechts))
static func erhalte_richtung_nach_axial_mit_vektor(axial: Vector2i) -> HexSys.HEX_RICHTUNG: 
	match axial:
		Vector2i(1, 0): return HEX_RICHTUNG.Linksoben
		Vector2i(1, 1): return HEX_RICHTUNG.Oben
		Vector2i(0, 1): return HEX_RICHTUNG.Rechtsoben
		
		Vector2i(-1, 0): return HEX_RICHTUNG.Rechtsunten
		Vector2i(-1, -1): return HEX_RICHTUNG.Unten
		Vector2i(0, -1): return HEX_RICHTUNG.Linksunten
	return -1

# #region Global & Lokal Koordinaten

### Axiale Koordinaten aus Euler-Koordinaten berechnen
#static func erhalte_axial_nach_euler_mit_vektor(
	#euler: Vector3, hexagon_radius := 1.0
#) -> Vector2i:
	## Basisvektoren für die axialen Richtungen
	#var basis_linksoben := erhalte_euler_nach_seite_richtung(HEX_RICHTUNG.Linksoben, 1.0)
	#var basis_rechtsoben := erhalte_euler_nach_seite_richtung(HEX_RICHTUNG.Rechtsoben, 1.0)
	#
	## Ignoriere die y-Komponente (Höhe), da axiale Koordinaten nur die xz-Ebene betreffen
	#var pos_2d := Vector2(euler.x, euler.z)
	#var basis_linksoben_2d := Vector2(basis_linksoben.x, basis_linksoben.z) * hexagon_radius
	#var basis_rechtsoben_2d := Vector2(basis_rechtsoben.x, basis_rechtsoben.z) * hexagon_radius
	#
	## Löse das lineare Gleichungssystem, um die Koeffizienten (linksoben, obenrechts) zu finden
	## pos_2d = linksoben * basis_linksoben_2d + obenrechts * basis_rechtsoben_2d
	#var det := basis_linksoben_2d.x * basis_rechtsoben_2d.y - basis_rechtsoben_2d.x * basis_linksoben_2d.y
	#if abs(det) < 0.0001:
		#return Vector2i.ZERO  # Vermeide Division durch Null
	#
	#var linksoben := roundi(
		#(pos_2d.x * basis_rechtsoben_2d.y - pos_2d.y * basis_rechtsoben_2d.x) / det
	#)
	#var obenrechts := roundi(
		#(pos_2d.y * basis_linksoben_2d.x - pos_2d.x * basis_linksoben_2d.y) / det
	#)
	#
	#return Vector2i(linksoben, obenrechts)

#region Global & Lokal Koordinaten

## Errechnet axial Koordinaten aus radial Koordinaten
static func erhalte_axial_nach_radial_mit_vektor(radial: Vector3i) -> Vector2i:
	return erhalte_axial_nach_radial(radial.x, radial.y, radial.z)
static func erhalte_axial_nach_radial(radius: int, seite: HEX_RICHTUNG, interpoliert: int) -> Vector2i:
	var ausgabe := Vector2i.ZERO
	
	ausgabe += erhalte_axial_richtung(seite) * radius
	ausgabe += erhalte_axial_richtung(seite + 2) * interpoliert
	
	return ausgabe

## Errechnet axial Koordinaten aus kubial Koordinaten
static func erhalte_axial_nach_kubial_mit_vektor(kubial: Vector3i) -> Vector2i:
	return erhalte_axial_nach_kubial(kubial.x,kubial.y,kubial.z)
static func erhalte_axial_nach_kubial(
	obenhinten: int, hintenunten: int, vorne: int,
) -> Vector2i:
	var ausgabe := Vector2i.ZERO
	push_warning(warning)
	# TODO 
	return ausgabe

## Errechnet axial Koordinaten aus gradial Koordinaten
static func erhalte_axial_nach_gradiale_mit_vektor(
	gradiale: Vector2) -> Vector2i: return HexSys.erhalte_axial_nach_gradiale(gradiale.x,gradiale.y)
static func erhalte_axial_nach_gradiale(
	breitengrad: float, längengrad: float
) -> Vector2i: return Vector2i.ZERO # TODO

#endregion
#region Chunk Koordinaten

## Errechnet die globale axial Koordinate des Mittelpunkts aus der axial Chunk Koordinate
static func erhalte_axial_nach_chunk_axial_mit_vektor(
	axial: Vector2i, radius_chunk: int,
) -> Vector2i: return erhalte_axial_nach_chunk_axial(axial.x,axial.y,radius_chunk)
static func erhalte_axial_nach_chunk_axial(
	linksoben: int, obenrechts: int, radius_chunk: int
) -> Vector2i: 
	var lo := HexSys.erhalte_axial_nach_radial(2 * radius_chunk + 1, 0, radius_chunk)
	var ro := HexSys.erhalte_axial_nach_radial(2 * radius_chunk + 1, 2, radius_chunk)
	return lo * linksoben + ro * obenrechts

## Errechnet die axial CHunk Koordinate aus der globalen axial Koordinate
static func erhalte_axial_chunk_nach_axial_global_mit_vektor(
	axial: Vector2i, chunk_radius: int
) -> Vector2i: return erhalte_axial_chunk_nach_axial_global(axial.x,axial.y,chunk_radius)
static func erhalte_axial_chunk_nach_axial_global(
	linksoben: int, obenrechts: int, chunk_radius: int
) -> Vector2i:
	# Konvertiere axiale Koordinaten in radiale Koordinaten
	var radial := HexSys.erhalte_radial_nach_axial(linksoben, obenrechts)
	
	# Berechne die Chunk-Koordinaten durch Skalierung
	var chunk_factor := 2 * chunk_radius + 1
	var chunk_radius_scaled := radial.x / chunk_factor
	var chunk_interpoliert_scaled := radial.z / chunk_factor
	
	# Runde auf die nächste Ganzzahl, um die Chunk-Position zu bestimmen
	var chunk_radius_rounded := roundi(chunk_radius_scaled)
	var chunk_interpoliert_rounded := roundi(chunk_interpoliert_scaled)
	
	# Konvertiere zurück in axiale Koordinaten
	return HexSys.erhalte_axial_nach_radial(
		chunk_radius_rounded, 
		radial.y as HexSys.HEX_RICHTUNG, 
		chunk_interpoliert_rounded
	)

static func erhalte_axial_lokal_nach_axial_global_mit_vektor(
	axial: Vector2i, chunk_radius
) -> Vector2i: return erhalte_axial_lokal_nach_axial_global(axial.x,axial.y,chunk_radius)
static func erhalte_axial_lokal_nach_axial_global(
	linksoben: int, obenrechts: int, chunk_radius: int
) -> Vector2i:
	var axial_chunk := HexSys.erhalte_axial_chunk_nach_axial_global(linksoben,obenrechts,chunk_radius)
	return Vector2i(linksoben, obenrechts) - axial_chunk

## Errechnet die axial CHunk Koordinate aus der globalen axial Koordinate
static func erhalte_axial_chunk_nach_gradial_mit_vektor(
	gradial: Vector2, chunk_radius: int
) -> Vector2i: return erhalte_axial_chunk_nach_gradial(gradial.x,gradial.y,chunk_radius)
static func erhalte_axial_chunk_nach_gradial(
	linksoben: int, obenrechts: int, chunk_radius: int
) -> Vector2i:
	# Konvertiere axiale Koordinaten in radiale Koordinaten
	var radial := HexSys.erhalte_radial_nach_axial(linksoben, obenrechts)
	
	# Berechne die Chunk-Koordinaten durch Skalierung
	var chunk_factor := 2 * chunk_radius + 1
	var chunk_radius_scaled := radial.x / chunk_factor
	var chunk_interpoliert_scaled := radial.z / chunk_factor
	
	# Runde auf die nächste Ganzzahl, um die Chunk-Position zu bestimmen
	var chunk_radius_rounded := roundi(chunk_radius_scaled)
	var chunk_interpoliert_rounded := roundi(chunk_interpoliert_scaled)
	
	# Konvertiere zurück in axiale Koordinaten
	return HexSys.erhalte_axial_nach_radial(
		chunk_radius_rounded, 
		radial.y as HexSys.HEX_RICHTUNG, 
		chunk_interpoliert_rounded
	)

#region Axial global

static func erhalte_axial_global_nach_axialpaar(
	axial_lokal: Vector2i, axial_chunk: Vector2i, 
	radius_chunk: int,
) -> Vector2i: return axial_lokal + HexSys.erhalte_axial_nach_chunk_axial_mit_vektor(axial_chunk,radius_chunk)

static func erhalte_axial_global_nach_radialpaar(
	radial_lokal: Vector3i, radial_chunk: Vector3i, 
	radius_chunk: int,
) -> Vector2i: 
	var chunk_position := HexSys.erhalte_axial_nach_chunk_radial_mit_vektor(radial_chunk, radius_chunk)
	var lokale_position := HexSys.erhalte_axial_nach_radial_mit_vektor(radial_lokal)
	return chunk_position + lokale_position

static func erhalte_axial_global_nach_kubialpaar(
	kubial_lokal: Vector3i, kubial_chunk: Vector3i, 
	radius_chunk: int,
) -> Vector2i: 
	var chunk_position := HexSys.erhalte_axial_nach_chunk_kubial_mit_vektor(kubial_chunk, radius_chunk)
	var lokale_position := HexSys.erhalte_axial_nach_kubial_mit_vektor(kubial_lokal)
	return chunk_position + lokale_position

#endregion

static func erhalte_axial_nach_chunk_radial_mit_vektor(
	radial: Vector3i, radius_chunk: int,
) -> Vector2i:
	return erhalte_axial_nach_chunk_radial(radial.x, radial.y, radial.z, radius_chunk)
static func erhalte_axial_nach_chunk_radial(
	radius: int, seite: HexSys.HEX_RICHTUNG, interpoliert: int,
	radius_chunk: int,
) -> Vector2i:
	var ausgabe := Vector2i.ZERO
	
	ausgabe += erhalte_axial_nach_radial(2 * radius_chunk + 1, seite, radius_chunk) * radius
	ausgabe += erhalte_axial_nach_radial(2 * radius_chunk + 1, seite + 2, radius_chunk) * interpoliert
	
	return ausgabe

static func erhalte_axial_nach_chunk_kubial_mit_vektor(
	kubial: Vector3i, radius_chunk: int,
) -> Vector2i:
	return erhalte_axial_nach_chunk_kubial(kubial.x, kubial.y, kubial.z, radius_chunk)
static func erhalte_axial_nach_chunk_kubial(
	obenhinten: int, hintenunten: int, vorne: int,
	radius_chunk: int,
) -> Vector2i:
	var axial := HexSys.erhalte_axial_nach_kubial(obenhinten,hintenunten,vorne)
	return HexSys.erhalte_axial_nach_chunk_axial_mit_vektor(axial,radius_chunk)

#endregion
#endregion
#region Radial

#static func erhalte_radial_nach_euler_mit_vektor(euler: Vector3) -> Vector3i:
	#var axial := HexSys.erhalte_axial_nach_euler_mit_vektor(euler)
	#return HexSys.erhalte_radial_nach_axial_mit_vektor(axial)

static func erhalte_radial_nach_axial_mit_vektor(axial: Vector2i) -> Vector3i:
	return erhalte_radial_nach_axial(axial.x, axial.y)
static func erhalte_radial_nach_axial(linksoben: int, obenrechts: int) -> Vector3i:
	var ausgabe := Vector3i.ZERO
	
	# Sonderfall: Ursprung (0, 0)
	if linksoben == 0 and obenrechts == 0:
		return Vector3i(0, 0, 0)
	
	# Initialer Radius: Maximum der absoluten Kubialkoordinaten
	var radius: int = max(abs(linksoben), abs(obenrechts))
	var axial := Vector2i(linksoben, obenrechts)
	var best_seite := 0
	var best_interpoliert := 0
	var min_abstand := INF
	
	# Teste jede Richtung (seite)
	for seite in HEX_RICHTUNG.values():
		# Berechne die Kubialkoordinaten für den Radius in dieser Richtung
		var axial_richtung := erhalte_axial_richtung(seite) * radius
		var rest := axial - axial_richtung
		
		# Berechne den Interpolationsfaktor entlang seite+2
		var richtung_2 := erhalte_axial_richtung((seite + 2) % 6)
		var interpoliert := 0
		
		# Berechne den Skalarprojektionsfaktor für die Richtung seite+2
		if richtung_2 != Vector2i.ZERO:
			var dot_product := rest.x * richtung_2.x + rest.y * richtung_2.y
			var magnitude := richtung_2.x * richtung_2.x + richtung_2.y * richtung_2.y
			if magnitude != 0:
				interpoliert = roundi(float(dot_product) / magnitude)
		
		# Berechne die resultierenden Kubialkoordinaten
		var test_axial := axial_richtung + richtung_2 * interpoliert
		var abstand := (axial - test_axial).length_squared()
		
		# Aktualisiere, wenn der Abstand kleiner ist
		if abstand < min_abstand:
			min_abstand = abstand
			best_seite = seite
			best_interpoliert = interpoliert
			ausgabe = Vector3i(radius, seite, interpoliert)
	
	# Falls der Abstand nicht null ist, versuche einen kleineren Radius
	if min_abstand > 0:
		var smaller_radius := radius - 1
		if smaller_radius >= 0:
			var smaller_result := erhalte_radial_nach_axial(linksoben, obenrechts)
			if (erhalte_axial_nach_radial(smaller_result.x, smaller_result.y, smaller_result.z) - axial).length_squared() < min_abstand:
				ausgabe = smaller_result
	
	return ausgabe

static func erhalte_radial_nach_kubial_mit_vektor(kubial: Vector3i) -> Vector3i:
	return erhalte_radial_nach_kubial(kubial.x,kubial.y,kubial.z)
static func erhalte_radial_nach_kubial(
	obenhinten: int, hintenunten: int, vorne: int
) -> Vector3i: 
	var ausgabe := Vector3i.ZERO
	# TODO
	push_warning("Radial aus kubial ist nicht Implementiert")
	return ausgabe

static func erhalte_radial_nach_axial_von_mit_vektor(nach_axial: Vector2i, von_axial: Vector2i) -> Vector3i:
	return erhalte_radial_nach_axial_mit_vektor(nach_axial - von_axial)
static func erhalte_radial_nach_axial_von(
	nach_linksoben: int, nach_obenrechts: int, 
	von_linksoben: int, von_obenrechts: int,
) -> Vector3i: return erhalte_radial_nach_axial(
	nach_linksoben - von_linksoben, 
	nach_obenrechts - von_obenrechts, )

static func erhalte_radial_nach_gradiale_mit_vektor(
	gradiale: Vector2) -> Vector2i: return HexSys.erhalte_radial_nach_gradiale(gradiale.x,gradiale.y)
static func erhalte_radial_nach_gradiale(
	breitengrad: float, längengrad: float
) -> Vector2i: return Vector2i.ZERO # TODO


#endregion
#region Kubial

const warning := "Kubiale Koordinaten sind noch nicht implementiert"

## Kubial nach Radial Konvertierung
static func erhalte_kubial_nach_radial_mit_vektor(
	radial: Vector3i
) -> Vector3i: return erhalte_kubial_nach_radial(radial.x,radial.y,radial.z)
static func erhalte_kubial_nach_radial(
	radius: int, seite: HexSys.HEX_RICHTUNG, vorne: int
) -> Vector3i: 
	var ausgabe := Vector3i.ZERO
	push_warning(warning)
	return ausgabe

# Ergänzte Methode für Kubial-Koordinaten
static func erhalte_kubial_nach_axial_mit_vektor(axial: Vector2i) -> Vector3i:
	return erhalte_kubial_nach_axial(axial.x, axial.y)
static func erhalte_kubial_nach_axial(linksoben: int, obenrechts: int) -> Vector3i:
	return Vector3i(linksoben, -obenrechts, -linksoben-obenrechts)

#endregion
#region Gradiale

# Ermittelt den Pol aus gradial Koordinaten
static func erhalte_pol_nach_breitengrad_mit_vektor(gradial: Vector2) -> HexSys.POLE:
	return HexSys.erhalte_pol_nach_breitengrad(gradial.x)
static func erhalte_pol_nach_breitengrad(breitengrad: float) -> HexSys.POLE:
	return HexSys.POLE.Nordpol if breitengrad >= 0 else HexSys.POLE.Südpol

static func erhalte_gradiale_nach_axial_mit_vektor(
	pol: POLE, axial: Vector2i
)  -> Vector2: return HexSys.erhalte_gradiale_nach_axial(pol,axial.x,axial.y)
static func erhalte_gradiale_nach_axial(
	pol: POLE, linksoben: int, obenrechts: int
) -> Vector2: # return Vector2.ZERO # TODO
	var q := float(linksoben)
	var r := float(obenrechts)
	var u := q
	var v := r
	var quadrat_summe := linksoben ** 2 + obenrechts ** 2
	var plus := quadrat_summe + 1
	var minus := quadrat_summe - 1
	#var wert := linksoben ** 2 + obenrechts ** 2 + 1.0
	#var denom := u * u + v * v + 1.0
	var temp_x := 2.0 * u / plus
	var temp_y := 2.0 * v / plus
	var temp_z := minus / plus
	var x := temp_x
	var y := temp_y
	var z := -temp_z if pol == POLE.Nordpol else temp_z
	var breitengrad := asin(z) * 180.0 / PI
	var längengrad := atan2(y, x) * 180.0 / PI
	if pol == POLE.Südpol: pass
		#längengrad = (längengrad + 180.0) % 360.0 - 180.0
	return Vector2(breitengrad, längengrad)

static func erhalte_gradiale_nach_radial_mit_vektor(
	pol: POLE, radial: Vector3i
)  -> Vector2: return HexSys.erhalte_gradiale_nach_radial(pol,radial.x,radial.y,radial.z)
static func erhalte_gradiale_nach_radial(
	pol: POLE, radius: int, seite: HexSys.HEX_RICHTUNG, interpoliert: int,
) -> Vector2: return Vector2.ZERO # TODO

static func erhalte_gradiale_nach_kubial_mit_vektor(
	pol: POLE, kubial: Vector3i
)  -> Vector2: return HexSys.erhalte_gradiale_nach_kubial(pol,kubial.x,kubial.y,kubial.z)
static func erhalte_gradiale_nach_kubial(
	pol: POLE, obenhinten: int, hintenunten: int, vorne: int
) -> Vector2: return Vector2.ZERO # TODO

#endregion
#region Sonstiges

static func for_radial(
	radius: int,
	arg: Callable,
) -> void:
	for r in radius + 1: if r == 0: arg.call(0, 0, 0)
	else: for s in 6: for i in r: arg.call(r, s, i)

static func erhalte_hex_radius_nach_hex_breite(hex_breite: float) -> float:
	return hex_breite / (sqrt(2) * sqrt(1-cos(deg_to_rad(120))))

static func erhalte_hex_breite_nach_hex_redius(hex_radius: float) -> float:
	return hex_radius * sqrt(2) * sqrt(1-cos(deg_to_rad(120)))

static func erhalte_hex_varianten_richtungen(
	hex_welt: HexWelt,
	axial_global: Vector2i,
) -> Array[HexSys.HEX_RICHTUNG]:
	var variante = hex_welt.erhalte_variante_nach_axial_global(axial_global)
	var richtungen: Array[HexSys.HEX_RICHTUNG] = []
	for richtung in HexSys.HEX_RICHTUNG.values():
		var nachbar_axial_global = axial_global + HexSys.erhalte_axial_richtung(richtung)
		if hex_welt.existiert_hex_nach_axial_global(nachbar_axial_global):
			var nachbar_hex := hex_welt.erhalte_hex_nach_axial_global(nachbar_axial_global)
			#var nachbar_variante := nachbar_hex.variante
			#var gleiche_hex_variante: bool = nachbar_variante == variante
			#var kreuzungs_hex_variante: bool = nachbar_variante == Hex.VARIANTEN.Kreuzung
			#if gleiche_hex_variante or kreuzungs_hex_variante:  # Weg oder Fluss+Weg
				#richtungen.append(richtung)
	return richtungen

static func erhalte_erstes(
	richtungen: Dictionary[HexSys.HEX_RICHTUNG,Hex.VARIANTEN]
) -> HexSys.HEX_RICHTUNG:
	var liste := []
	for jedes in richtungen: if richtungen[jedes] != Hex.VARIANTEN.Boden:
		liste.append(jedes)
	liste.sort()
	if liste.is_empty(): return 0
	if liste[0] == 0: 
		var idx = -1
		var wert = liste[idx] + 1
		if wert != 6: return liste[0]
		while liste[idx] == wert - 1:
			wert = liste[idx]
			idx -= 1
		return wert
	else: return liste[0]

static func _erhalte_letztes(liste: Array[HexSys.HEX_RICHTUNG]) -> HexSys.HEX_RICHTUNG:
	# TODO
	return -1

#endregion
