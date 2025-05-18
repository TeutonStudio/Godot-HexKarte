@tool
class_name HexWelt
extends Resource

@export var _HEX_data: Dictionary[PackedInt32Array, Hex]
@export var _KANTEN_data: Dictionary[PackedInt32Array, Hex.VARIANTEN]
@export var _ECKEN_data: Dictionary[PackedInt32Array, Variant]

@export_storage var radius_welt: int = -1
@export_storage var radius_chunk: int = -1

func existiert_hex_nach_axial_global(axial: Vector2i) -> bool:
	return _HEX_data.has(PackedInt32Array([axial[0],axial[1]]))

func erhalte_hex_nach_axial_global(axial: Vector2i) -> Hex:
	return _HEX_data.get_or_add(PackedInt32Array([axial[0],axial[1]]),Hex.new(axial))

func _init(
	_radius_welt := radius_welt, _radius_chunk := radius_chunk,
) -> void: if _radius_welt != radius_welt and _radius_chunk != radius_chunk:
	radius_welt = _radius_welt; radius_chunk = _radius_chunk
	
	if _HEX_data.is_empty() or _KANTEN_data.is_empty() or _ECKEN_data.is_empty():
		HexSys.for_radial(radius_welt,func(_cr: int,_cs: int,_ci: int):
			HexSys.for_radial(radius_chunk,func(_hr: int,_hs: int,_hi: int):
				var radial_lokal := Vector3i(_hr,_hs,_hi)
				var radial_chunk := Vector3i(_cr,_cs,_ci)
				var axial_global := HexSys.erhalte_axial_global_nach_radialpaar(radial_lokal,radial_chunk,_radius_chunk)
				var hex := Hex.new(axial_global,radius_chunk)
				_HEX_data[PackedInt32Array([axial_global.x,axial_global.y])] = hex
				
				for seite: HexSys.HEX_RICHTUNG in HexSys.HEX_RICHTUNG.values():
					var kante := hex.erhalte_axial_kante(seite)
					_KANTEN_data[kante] = Hex.VARIANTEN.Meer
					for jedes: int in [(seite+3) % 6 , (seite-3) % 6]: 
						var drittes := hex.erhalte_axial_kante(jedes)
						var ecke := kante.duplicate(); ecke.append_array([drittes[2],drittes[3]])
						_ECKEN_data[ecke] = null
			)
		)
