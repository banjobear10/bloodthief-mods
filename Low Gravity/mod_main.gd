extends "res://addons/ModLoader/mod_node.gd"

var gravity_setting = Setting.new("Gravity Multiplier", Setting.SETTING_FLOAT, 0.3, Vector2(0, 1))

func init():
	ModLoader.mod_log(name_pretty + " mod loaded")
	
	settings = {
		"settings_page_name" = "Low Gravity",
		"settings_list" = [
			gravity_setting
		]
	}

func _process(_delta):
	if is_instance_valid(GameManager):
		var default_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
		var target_gravity = default_gravity * gravity_setting.value
		if GameManager.gravity != target_gravity:
			GameManager.gravity = target_gravity
