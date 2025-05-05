@tool
class_name HexWelt
extends Resource

@export var data: Dictionary[Vector2i, Hex]

@export_storage var radius_welt: int = -1
@export_storage var radius_chunk: int = -1

func existiert_hex_nach_axial_global(axial: Vector2i) -> bool:
	return data.has(axial)

func erhalte_hex_nach_axial_global(axial: Vector2i) -> Hex:
	return data[axial]

func _init(
	_radius_welt := radius_welt, _radius_chunk := radius_chunk,
) -> void: if _radius_welt != radius_welt and _radius_chunk != radius_chunk:
	radius_welt = _radius_welt; radius_chunk = _radius_chunk
	
	HexSys.for_radial(radius_welt,func(_cr: int,_cs: int,_ci: int):
		HexSys.for_radial(radius_chunk,func(_hr: int,_hs: int,_hi: int):
			var radial_lokal := Vector3i(_hr,_hs,_hi)
			var radial_chunk := Vector3i(_cr,_cs,_ci)
			var axial_global := HexSys.erhalte_axial_global_nach_radialpaar(radial_lokal,radial_chunk,_radius_chunk)
			var hex := Hex.new(axial_global,radius_chunk)
			data[axial_global] = hex
		)
	)
