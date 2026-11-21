extends Node2D

const WORLD_SIZE := Vector2(1600, 1000)
const PLAYER_SPEED := 260.0
const INTERACTION_DISTANCE := 100.0

var player_position := Vector2(800, 500)
var xp := 0
var completed_stations: Array[int] = []
var active_station := -1

var stations := [
	{
		"name": "HARDWARE FORGE",
		"position": Vector2(350, 300),
		"color": Color("#e9a23b"),
		"title": "کارگاه سخت‌افزار",
		"lesson": "سخت‌افزار شامل قطعات فیزیکی رایانه است؛ مانند CPU، RAM، مادربرد و حافظه."
	},
	{
		"name": "OS ARCHIVE",
		"position": Vector2(800, 230),
		"color": Color("#56a8e8"),
		"title": "آرشیو سیستم‌عامل",
		"lesson": "سیستم‌عامل منابع رایانه را مدیریت می‌کند و ارتباط میان کاربر و سخت‌افزار را برقرار می‌سازد."
	},
	{
		"name": "NETWORK DOCK",
		"position": Vector2(1250, 350),
		"color": Color("#51d6b0"),
		"title": "بندر شبکه",
		"lesson": "شبکه امکان ارتباط دستگاه‌ها را فراهم می‌کند. IP و پروتکل‌ها از مفاهیم مهم شبکه هستند."
	},
	{
		"name": "CODE GARDEN",
		"position": Vector2(450, 750),
		"color": Color("#bd83ef"),
		"title": "باغ برنامه‌نویسی",
		"lesson": "برنامه‌نویسی یعنی تبدیل یک مسئله به دستورهای منطقی که رایانه بتواند آن‌ها را اجرا کند."
	},
	{
		"name": "AI OBSERVATORY",
		"position": Vector2(1200, 750),
		"color": Color("#ef789c"),
		"title": "رصدخانه هوش مصنوعی",
		"lesson": "هوش مصنوعی از داده‌ها برای تشخیص الگوها، یادگیری و انجام وظایف هوشمند استفاده می‌کند."
	}
]

func _ready() -> void:
	get_window().title = "VEXORIS"
	queue_redraw()

func _process(delta: float) -> void:
	if active_station != -1:
		queue_redraw()
		return

	var direction := Vector2.ZERO

	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1

	if direction.length() > 0:
		player_position += direction.normalized() * PLAYER_SPEED * delta

	player_position.x = clampf(player_position.x, 30, WORLD_SIZE.x - 30)
	player_position.y = clampf(player_position.y, 30, WORLD_SIZE.y - 30)

	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E and active_station == -1:
			interact()
		elif event.keycode == KEY_ESCAPE:
			active_station = -1

func interact() -> void:
	var nearest := -1
	var shortest := INTERACTION_DISTANCE

	for i in range(stations.size()):
		var distance: float = player_position.distance_to(
			stations[i]["position"]
		)
		if distance < shortest:
			shortest = distance
			nearest = i

	if nearest != -1:
		active_station = nearest

		if not completed_stations.has(nearest):
			completed_stations.append(nearest)
			xp += 100

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(960, 540)), Color("#101925"))

	draw_world()
	draw_stations()
	draw_player()
	draw_hud()

	if active_station != -1:
		draw_lesson_panel()

func draw_world() -> void:
	for x in range(0, 961, 50):
		draw_line(
			Vector2(x, 0),
			Vector2(x, 540),
			Color("#26394a"),
			1.0
		)

	for y in range(0, 541, 50):
		draw_line(
			Vector2(0, y),
			Vector2(960, y),
			Color("#26394a"),
			1.0
		)

	draw_rect(
		Rect2(Vector2(40, 80), Vector2(880, 420)),
		Color("#182735"),
		false,
		3.0
	)

func world_to_screen(world_position: Vector2) -> Vector2:
	return world_position - player_position + Vector2(480, 270)

func draw_stations() -> void:
	for i in range(stations.size()):
		var station: Dictionary = stations[i]
		var screen_position := world_to_screen(station["position"])
		var color: Color = station["color"]

		if screen_position.x < -100 or screen_position.x > 1060:
			continue
		if screen_position.y < -100 or screen_position.y > 640:
			continue

		draw_circle(screen_position, 38, color.darkened(0.65))
		draw_arc(screen_position, 42, 0, TAU, 48, color, 3.0)
		draw_circle(screen_position, 17, color)

		if completed_stations.has(i):
			draw_circle(
				screen_position + Vector2(25, -25),
				9,
				Color("#75f5a5")
			)

		draw_string(
			ThemeDB.fallback_font,
			screen_position + Vector2(-75, 65),
			station["name"],
			HORIZONTAL_ALIGNMENT_CENTER,
			150,
			12,
			Color.WHITE
		)

func draw_player() -> void:
	var screen_position := Vector2(480, 270)

	draw_circle(screen_position, 23, Color("#d9e9f5"))
	draw_circle(screen_position, 15, Color("#58b9ed"))
	draw_circle(screen_position + Vector2(5, -4), 5, Color.WHITE)

func draw_hud() -> void:
	draw_rect(Rect2(0, 0, 960, 55), Color("#10131d"))

	draw_string(
		ThemeDB.fallback_font,
		Vector2(25, 35),
		"VEXORIS",
		HORIZONTAL_ALIGNMENT_LEFT,
		200,
		25,
		Color("#75e5ff")
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(750, 34),
		"XP: " + str(xp),
		HORIZONTAL_ALIGNMENT_LEFT,
		150,
		20,
		Color("#f5d36b")
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(25, 520),
		"WASD / ARROWS: MOVE     E: INTERACT",
		HORIZONTAL_ALIGNMENT_LEFT,
		500,
		15,
		Color("#c4d3e0")
	)

func draw_lesson_panel() -> void:
	draw_rect(
		Rect2(Vector2(170, 115), Vector2(620, 310)),
		Color("#101c2b")
	)

	draw_rect(
		Rect2(Vector2(170, 115), Vector2(620, 310)),
		Color("#69c9e8"),
		false,
		3.0
	)

	var station: Dictionary = stations[active_station]

	draw_string(
		ThemeDB.fallback_font,
		Vector2(205, 165),
		station["title"],
		HORIZONTAL_ALIGNMENT_LEFT,
		550,
		25,
		station["color"]
	)

	draw_multiline_string(
		ThemeDB.fallback_font,
		Vector2(205, 220),
		station["lesson"],
		HORIZONTAL_ALIGNMENT_LEFT,
		550,
		12,
		20,
		Color.WHITE
	)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(205, 375),
		"ESC: CLOSE",
		HORIZONTAL_ALIGNMENT_LEFT,
		300,
		17,
		Color("#75e5ff")
	)
