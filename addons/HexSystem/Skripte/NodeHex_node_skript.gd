class_name NodeHex
extends Node

## Dies ist der Winkel der Richtung ausgehend von Linksoben
static func erhalte_winkel_nach_richtung(seite: float) -> float:
	return deg_to_rad(60 * (1 - seite))

## Dies ist die Position eines Nachbarhexes, abhängig von der Seite und dem Hexagon Radius
static func erhalte_euler_nach_seite_richtung(seite: int, hexagon_breite := 1.0) -> Vector3:
	return Vector3(1,0,0).rotated(Vector3.UP,erhalte_winkel_nach_richtung(seite)) * hexagon_breite

static func erhalte_transform_nach_richtung(
	seite: int, hexagon_breite: float, winkel_veränderung := 0.0, 
	halbe_höhe := false, verlürzt := false
) -> Transform3D: return Transform3D(
	Basis( Vector3.UP, NodeHex.erhalte_winkel_nach_richtung(seite) - deg_to_rad(winkel_veränderung) ),
	NodeHex.erhalte_euler_nach_seite_richtung(seite,hexagon_breite)*(.98 if verlürzt else 1.0) + (Vector3.UP * HexSys.erhalte_hex_radius_nach_hex_breite(hexagon_breite) / 2 if halbe_höhe else Vector3.ZERO),
)

static func erhalte_transform_nach_richtung_und_hex(seite: int, hex: Hex, hexagon_breite: float, winkel_veränderung := 0.0, halbe_höhe := false) -> Transform3D:
	return Transform3D(
		Basis( Vector3.UP, NodeHex.erhalte_winkel_nach_richtung(seite) - deg_to_rad(winkel_veränderung) ),
		NodeHex.erhalte_euler_nach_hex(hex,hexagon_breite) + (Vector3.UP * HexSys.erhalte_hex_radius_nach_hex_breite(hexagon_breite) / 2 if halbe_höhe else Vector3.ZERO),
	)
## Dies ist die Position des Hexagons
static func erhalte_euler_nach_axial_mit_vektor(
	axial: Vector2i, hexagon_breite := 1.0, 
	höhe := 0, höhenschritte := 10,
) -> Vector3: return erhalte_euler_nach_axial(axial.x,axial.y,hexagon_breite,höhe,höhenschritte)
static func erhalte_euler_nach_axial(
	linksoben: int, obenrechts: int, hexagon_breite := 1.0, 
	höhe := 0, höhenschritte := 10,
) -> Vector3: 
	var ausgabe := Vector3.ZERO
	
	ausgabe += erhalte_euler_nach_seite_richtung(HexSys.HEX_RICHTUNG.Linksoben, hexagon_breite) * linksoben
	ausgabe += erhalte_euler_nach_seite_richtung(HexSys.HEX_RICHTUNG.Rechtsoben, hexagon_breite) * obenrechts
	ausgabe += Vector3.UP * höhe / höhenschritte
	
	return ausgabe

static func erhalte_euler_nach_hex(hex: Hex, hexagon_breite := 1.0, höhenschritte := 10) -> Vector3:
	return NodeHex.erhalte_euler_nach_axial_mit_vektor(hex.axial_global,hexagon_breite,hex.höhe,höhenschritte)

static func erhalte_axial_nach_euler_mit_vektor(
	euler: Vector3, hexagon_breite := 1.0
) -> Vector2i: 
	var x_coeff := (2.0 * euler.x) / (sqrt(3.0) * hexagon_breite)
	var z_coeff := (2.0 * euler.z) / hexagon_breite
	
	var ro := int(round((x_coeff + z_coeff) / 2.0))
	var lo := int(round((x_coeff - z_coeff) / 2.0))
	
	return Vector2i(lo,ro)
