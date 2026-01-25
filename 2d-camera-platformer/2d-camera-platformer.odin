package twodCameraPlatformer

import "core:c"
import "core:c/libc"
import "core:fmt"
import "vendor:raylib"

G :: 400
PLAYER_JUMP_SPEED: f32 : 350
PLAYER_MOVEMENT_SPEED: f32 : 200

screenWidth: c.int : 800
screenHeight: c.int : 450

Player :: struct {
	position: raylib.Vector2,
	speed:    f32,
	canJump:  bool,
}

EnvItem :: struct {
	rect:     raylib.Rectangle,
	blocking: bool,
	color:    raylib.Color,
}

CameraOptions :: enum u8 {
	Center,
	CenterInsideMap,
	CenterSmoothFollow,
	EvenOutOnLanding,
	PlayerBoundPush,
}

evenOutSpeed: f32 = 700
eveningOut: bool = false
eveningOutTarget: f32

updatePlayer :: proc(player: ^Player, envItems: ^[5]EnvItem, delta: f32) {
	if raylib.IsKeyDown(.LEFT) {
		player.position.x -= PLAYER_MOVEMENT_SPEED * delta
	}
	if raylib.IsKeyDown(.RIGHT) {
		player.position.x += PLAYER_MOVEMENT_SPEED * delta
	}
	if raylib.IsKeyDown(.SPACE) && player.canJump {
		player.speed -= PLAYER_JUMP_SPEED
		player.canJump = false
	}

	hitObstacle := false

	for i := 0; i < len(envItems); i += 1 {
		item := envItems[i]
		playerPosition := player.position

		if item.blocking &&
		   item.rect.x <= playerPosition.x &&
		   item.rect.x + item.rect.width >= playerPosition.x &&
		   item.rect.y >= playerPosition.y &&
		   item.rect.y <= playerPosition.y + player.speed * delta {
			hitObstacle = true
			player.speed = 0
			player.position.y = item.rect.y
			break
		}
	}

	if !hitObstacle {
		player.position.y += player.speed * delta
		player.speed += G * delta
		player.canJump = false
	} else {
		player.canJump = true
	}
}

updateCameraCenter :: proc(camera: ^raylib.Camera2D, player: ^Player) {
	camera.offset = {f32(screenWidth / 2), f32(screenHeight / 2)}
	camera.target = player.position
}

updateCameraCenterInsideMap :: proc(
	camera: ^raylib.Camera2D,
	player: ^Player,
	envItems: ^[5]EnvItem,
) {
	updateCameraCenter(camera, player)
	minX: f32 = 1000
	minY: f32 = 1000
	maxX: f32 = -1000
	maxY: f32 = -1000

	for item in envItems {
		minX = libc.fminf(item.rect.x, minX)
		maxX = libc.fmaxf(item.rect.x + item.rect.width, maxX)
		minY = libc.fminf(item.rect.y, minY)
		maxY = libc.fmaxf(item.rect.y + item.rect.height, maxY)
	}

	max: raylib.Vector2 = raylib.GetWorldToScreen2D({maxX, maxY}, camera^)
	min: raylib.Vector2 = raylib.GetWorldToScreen2D({minX, minY}, camera^)

	if max.x < f32(screenWidth) {
		camera.offset.x = f32(screenWidth) - (max.x - f32(screenWidth / 2))
	}
	if max.y < f32(screenHeight) {
		camera.offset.y = f32(screenHeight) - (max.y - f32(screenHeight / 2))
	}
	if min.x > 0 {
		camera.offset.x = f32(screenWidth / 2) - min.x
	}
	if min.y > 0 {
		camera.offset.y = f32(screenHeight / 2) - min.y
	}
}

updateCameraCenteSmoothFollow :: proc(camera: ^raylib.Camera2D, player: ^Player, delta: f32) {
	minSpeed: f32 : 30
	minEffectLength: f32 : 10
	fractionSpeed: f32 : 0.8

	camera.offset = {f32(screenWidth / 2), f32(screenHeight / 2)}
	diff: raylib.Vector2 = player.position - camera.target
	length: f32 = raylib.Vector2Length(diff)

	if length > minEffectLength {
		speed: f32 = libc.fmaxf(fractionSpeed * length, minSpeed)
		camera.target = camera.target + (diff * (speed * delta / length))
	}
}

updateCameraEvenOnLanding :: proc(camera: ^raylib.Camera2D, player: ^Player, delta: f32) {
	camera.offset = {f32(screenWidth / 2), f32(screenHeight / 2)}
	camera.target.x = player.position.x

	if !eveningOut {
		if player.canJump && player.speed == 0 && player.position.y != camera.target.y {
			eveningOut = true
			eveningOutTarget = player.position.y
		}
		return
	}

	if !(eveningOutTarget > camera.target.y) {
		camera.target.y -= evenOutSpeed * delta
		if camera.target.y < eveningOutTarget {
			camera.target.y = eveningOutTarget
			eveningOut = false
		}
		return
	}

	camera.target.y += evenOutSpeed * delta
	if camera.target.y > eveningOutTarget {
		camera.target.y = eveningOutTarget
		eveningOut = false
	}
}

updateCameraPlayerBoundsPush :: proc(camera: ^raylib.Camera2D, player: ^Player) {
	bbox: raylib.Vector2 : {0.2, 0.2}

	bboxWorldMin: raylib.Vector2 = raylib.GetScreenToWorld2D(
		{(1 - bbox.x) * 0.5 * f32(screenWidth), (1 - bbox.y) * 0.5 * f32(screenHeight)},
		camera^,
	)
	bboxWorldMax: raylib.Vector2 = raylib.GetScreenToWorld2D(
		{(1 + bbox.x) * 0.5 * f32(screenWidth), (1 + bbox.y) * 0.5 * f32(screenHeight)},
		camera^,
	)
	camera.offset = {(1 - bbox.x) * 0.5 * f32(screenWidth), (1 - bbox.y) * 0.5 * f32(screenHeight)}

	if (player.position.x < bboxWorldMin.x) {
		camera.target.x = player.position.x
	}
	if (player.position.y < bboxWorldMin.y) {
		camera.target.y = player.position.y
	}
	if (player.position.x > bboxWorldMax.x) {
		camera.target.x = bboxWorldMin.x + (player.position.x - bboxWorldMax.x)
	}
	if (player.position.y > bboxWorldMax.y) {
		camera.target.y = bboxWorldMin.y + (player.position.y - bboxWorldMax.y)
	}
}

getNextCameraOption :: proc(current: CameraOptions) -> CameraOptions {
	if current == .PlayerBoundPush {
		return .Center
	}
	if current == .Center {
		return .CenterInsideMap
	}
	if current == .CenterInsideMap {
		return .CenterSmoothFollow
	}
	if current == .CenterSmoothFollow {
		return .EvenOutOnLanding
	}
	if current == .EvenOutOnLanding {
		return .PlayerBoundPush
	}
	return .Center
}

main :: proc() {
	raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera platformer")

	player: Player = {
		position = {400, 280},
		speed    = 0,
		canJump  = false,
	}
	envItems: [5]EnvItem = {
		{rect = {0, 0, 1000, 400}, blocking = false, color = raylib.LIGHTGRAY},
		{rect = {0, 400, 1000, 200}, blocking = true, color = raylib.GRAY},
		{rect = {300, 200, 400, 10}, blocking = true, color = raylib.GRAY},
		{rect = {250, 300, 100, 10}, blocking = true, color = raylib.GRAY},
		{rect = {650, 300, 100, 10}, blocking = true, color = raylib.GRAY},
	}

	camera: raylib.Camera2D = {
		target   = player.position,
		offset   = {f32(screenWidth / 2), f32(screenHeight / 2)},
		rotation = 0,
		zoom     = 1,
	}

	currentCamera: CameraOptions = .Center

	cameraDescriptions: [5]cstring = {
		"Follow player center",
		"Follow player center, but clamp to map edges",
		"Follow player center; smoothed",
		"Follow player center horizontally; update player center vertically after landing",
		"Player push camera on getting too close to screen edge",
	}

	raylib.SetTargetFPS(60)

	for !raylib.WindowShouldClose() {


		delta := raylib.GetFrameTime()
		updatePlayer(&player, &envItems, delta)

		camera.zoom += raylib.GetMouseWheelMove() * 0.05

		if camera.zoom > 3 {
			camera.zoom = 3
		} else if camera.zoom < 0.25 {
			camera.zoom = 0.25
		}

		if raylib.IsKeyPressed(.R) {
			camera.zoom = 1
			player.position = {400, 280}
		}

		if raylib.IsKeyPressed(.C) {
			currentCamera = getNextCameraOption(currentCamera)
		}

		switch currentCamera {
		case .Center:
			updateCameraCenter(&camera, &player)
		case .CenterInsideMap:
			updateCameraCenterInsideMap(&camera, &player, &envItems)
		case .CenterSmoothFollow:
			updateCameraCenteSmoothFollow(&camera, &player, delta)
		case .EvenOutOnLanding:
			updateCameraEvenOnLanding(&camera, &player, delta)
		case .PlayerBoundPush:
			updateCameraPlayerBoundsPush(&camera, &player)
		}

		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.RAYWHITE)

		raylib.BeginMode2D(camera)
		for item in envItems {
			raylib.DrawRectangleRec(item.rect, item.color)
		}
		playerRect: raylib.Rectangle = {player.position.x - 20, player.position.y - 40, 40, 40}
		raylib.DrawRectangleRec(playerRect, raylib.RED)

		raylib.DrawCircleV(player.position, 5, raylib.GOLD)
		raylib.EndMode2D()

		raylib.DrawText("Controls:", 20, 20, 10, raylib.BLACK)
		raylib.DrawText("- Right/Left to move", 40, 40, 10, raylib.DARKGRAY)
		raylib.DrawText("- Space to jump", 40, 60, 10, raylib.DARKGRAY)
		raylib.DrawText(
			"- Mouse Wheel to Zoom in-out, R to reset zoom",
			40,
			80,
			10,
			raylib.DARKGRAY,
		)
		raylib.DrawText("- C to change camera mode", 40, 100, 10, raylib.DARKGRAY)
		raylib.DrawText("Current camera mode:", 20, 120, 10, raylib.BLACK)
		raylib.DrawText(cameraDescriptions[currentCamera], 40, 140, 10, raylib.DARKGRAY)

		raylib.EndDrawing()
	}

	raylib.CloseWindow()
}
