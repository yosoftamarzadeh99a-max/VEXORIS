extends RefCounted

const SAVE_PATH := "user://vexoris_progress.json"

static func save_progress(xp: int, completed: Array) -> void:
	var data := {
		"xp": xp,
		"completed_stations": completed
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		push_error("VEXORIS: Save failed")
		return

	file.store_string(JSON.stringify(data))
	file.close()

static func load_progress() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {
			"xp": 0,
			"completed_stations": []
		}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		return {
			"xp": 0,
			"completed_stations": []
		}

	var content := file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)

	if typeof(data) != TYPE_DICTIONARY:
		return {
			"xp": 0,
			"completed_stations": []
		}

	return data
