## Created to be conditionally loaded to access some editor features.
extends RefCounted


## Returns the EditorInterface's [FileSystemDock] instance.
func get_file_system_dock() -> FileSystemDock:
	return EditorInterface.get_file_system_dock()
