class_name HexGlobus
extends NodeHex


@export_group("Weltdaten")
@export var erzeuge := false
@export var erzeuger: HexWeltErzeuger
@export var hex_bibliothek: HexBibliothek
@export_storage var _chunk_data: Dictionary[Vector3i, MeshInstance3D]
@export_storage var _natur_data: Dictionary[Vector3i, MeshInstance3D]
@export_storage var _data_nord: HexWelt
@export_storage var _data_süd: HexWelt
