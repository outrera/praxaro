extends Node2D

###
# Game: 
#   -Handles high-level main game functions( change levels, spawn hero, etc )
#   -Handles hero stats: HP/MP, XP, GP, etc


onready var HUD = get_node("HUD/Frame")
onready var LifePips = HUD.get_node("LifePips")
onready var DebugOutput = HUD.get_node("DebugOutput")


export(String, FILE, "*.tscn") var hero_scene_path
export(String, FILE, "*.tscn") var DEFAULT_STARTING_LEVEL
# Reference to the hero node. Defined when hero spawns
var hero

var hero_max_life = 5 setget _set_hero_max_life
var hero_life = 5 setget _set_hero_life

# Reference to the current level scene. Defined when we set_level
var level

var debug_mode = {
	"DevMode":			false,
	"GodMode":			false,
	"GhostMode":		false,
	"HeroDebugMode":	false,
	}

var main


func set_level( level_scene=DEFAULT_STARTING_LEVEL, spawn_point=null ):
	if self.level:
		# Delete old level
		self.level.queue_free()


	# Load new level
	var lvl = load(level_scene)
	lvl = lvl.instance()
	add_child(lvl)
	self.level = lvl
	lvl.game = self
	
	# Spawn a new Hero
	spawn_hero()
	self.level.add_child( self.hero )
	if !spawn_point:
		spawn_point = self.level.DEFAULT_WARP_POINT
	self.hero.set_pos( self.level.get_node( spawn_point ).get_pos() )
	self.hero.init( self.level )

	
	
func hero_dies():
	if hero:
		announce( "you have died..." )
		hero.die()

func spawn_hero():
	var p = load( hero_scene_path )
	p = p.instance()
	self.hero = p
	hero.world = self

func announce( message ):
	DebugOutput.set_text( message )
	DebugOutput.get_node("Timer").start()

func _ready():
	for key in debug_mode:
		debug_mode[key] = DATA.get_pref( "modes", key )
	set_process_input(true)
	set_level()
	
	self.hero_max_life = self.hero_max_life
	self.hero_life = self.hero_life
	

var hero_debug_menu

func _input( event ):
	# Poll for DEBUG COMMANDS
	# F1: DevMode
	# F2: GodMode
	# F3: GhostMode
	# F4: HeroDebugMode
	# F12: Hero Puncher
	if event.type == InputEvent.KEY:
		if event.pressed and !event.is_echo():
			if event.scancode == KEY_F1:
				debug_mode.DevMode = !debug_mode.DevMode
				announce( "DevMode " + ["OFF", "ON"][ int(debug_mode.DevMode) ] )
				DATA.set_pref( "modes", "DevMode", debug_mode.DevMode )
			elif event.scancode == KEY_F2:
				if debug_mode.DevMode:
					debug_mode.GodMode = !debug_mode.GodMode
					announce( "GodMode " + ["OFF", "ON"][ int(debug_mode.GodMode) ] )
					DATA.set_pref( "modes", "GodMode", debug_mode.GodMode )
				else:
					announce( "DevMode OFF" )
			elif event.scancode == KEY_F3:
				if debug_mode.DevMode:
					debug_mode.GhostMode = !debug_mode.GhostMode
					announce( "GhostMode " + ["OFF", "ON"][ int(debug_mode.GhostMode) ] )
					DATA.set_pref( "modes", "GhostMode", debug_mode.GhostMode )
				else:
					announce( "DevMode OFF" )
			elif event.scancode == KEY_F4:
				if debug_mode.DevMode:
					debug_mode.HeroDebugMode = !debug_mode.HeroDebugMode
					announce( "Hero DebugMode " + ["OFF", "ON"][ int(debug_mode.HeroDebugMode) ] )
					if debug_mode.HeroDebugMode:
						var menu = preload("res://scenes/HeroDebugMenu/HeroDebugMenu.tscn").instance()
						HUD.add_child( menu )
						if hero:
							menu.populate_params( hero.get_debug_params() )
							menu.hero = hero
						hero_debug_menu = menu
					else:
						if hero_debug_menu:
							hero_debug_menu.queue_free()
							hero_debug_menu = null
				else:
					announce( "DevMode OFF" )

			elif event.scancode == KEY_F12:
				if debug_mode.DevMode:
					if hero:
						hero.hero_take_strike()
						announce( "Oh the indignity!" )
				else:
					announce( "DevMode OFF" )



func _set_hero_max_life( what ):
	hero_max_life = what
	LifePips.set_hero_max_life( hero_max_life )

func _set_hero_life( what ):
	hero_life = what
	LifePips.set_hero_life( hero_life )
	
	if hero_life < 0:
		hero_dies()






