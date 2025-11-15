@tool
extends EditorPlugin

var MANIFEST_SETTING = "rust/manifest_path"
var CARGO_PATH_SETTING = "rust/cargo_path"

func _check_for_settings() -> bool:
	var cargo_path = ProjectSettings.get_setting("rust/cargo_path")
	var manifest_path = ProjectSettings.get_setting("rust/manifest_path")
	
	if cargo_path == null:
		push_error(
				(
					"The cargo executable is not set. Go to Editor > Editor Settings... > Rust and set Cargo Path to the absolute path to the cargo binary on your system."
				)
			)
		return false
	
	if manifest_path == null:
		push_error(
				(
					"The Cargo.toml is not set. Go to Editor > Editor Settings... > Rust and set Manifest Path to the absolute path to the cargo.toml on your system."
				)
			)
		return false
	
#	Copied from rust_tools <3
	if cargo_path.contains("/") or cargo_path.contains("\\"):
		if not FileAccess.file_exists(cargo_path):
			push_error(
				(
					"The configured cargo executable '%s' does not exist. Go to Editor > Editor Settings... > Rust and set Cargo Path to the absolute path to the cargo binary on your system."
					% [cargo_path]
				)
			)
			
			return false
	return true

func _register_settings():
	if ProjectSettings.get_setting(MANIFEST_SETTING) != null \
		and ProjectSettings.get_setting(CARGO_PATH_SETTING) != null:
		
		return
	
	ProjectSettings.set_setting(MANIFEST_SETTING, "")
	ProjectSettings.set_setting(CARGO_PATH_SETTING, "cargo") #set to value in PATH
	
	ProjectSettings.add_property_info({
		"name": MANIFEST_SETTING,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_GLOBAL_FILE,
		"hint_string": "*.toml"
	})
	
	ProjectSettings.add_property_info({
		"name": CARGO_PATH_SETTING,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_GLOBAL_FILE
	})
	
	ProjectSettings.set_as_basic(MANIFEST_SETTING, true)
	ProjectSettings.set_as_basic(CARGO_PATH_SETTING, true)
	
	ProjectSettings.save()

func _enter_tree() -> void:
	_register_settings()

func _enable_plugin() -> void:
	_register_settings()
	

func _build():
	var output = []
	var cargo_path = ProjectSettings.get_setting("rust/cargo_path")
	var manifest_path = ProjectSettings.get_setting("rust/manifest_path")

# 	if no cargo or manifest path just skip building the library
	if not _check_for_settings():
		return
	
	var exit_code = OS.execute(cargo_path, ["build", "--manifest-path", manifest_path], output, true)
	if exit_code != 0:
		for s in output:
			push_error(s)
	return exit_code == 0

func _exit_tree() -> void:
	pass
