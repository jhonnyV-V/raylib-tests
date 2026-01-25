package twodCamera

import "core:c"
import "core:c/libc"
import "core:fmt"
import "vendor:raylib"

MAX_BUILDINGS :: 100

main :: proc() {
	screenWidth: c.int = 800
	screenHeight: c.int = 450
	raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera")

	player: raylib.Rectangle = {
		x      = 400,
		y      = 280,
		width  = 40,
		height = 40,
	}
	buildings: [MAX_BUILDINGS]raylib.Rectangle = {}
	buildingColors: [MAX_BUILDINGS]raylib.Color = {}
	spacing: c.int = 0

	for i := 0; i < MAX_BUILDINGS; i += 1 {
		buildings[i].width = f32(raylib.GetRandomValue(50, 200))
		buildings[i].height = f32(raylib.GetRandomValue(100, 800))
		buildings[i].y = f32(screenHeight - 130) - buildings[i].height
		buildings[i].x = f32(-6000 + spacing)
		spacing += c.int(buildings[i].width)

		buildingColors[i] = raylib.Color {
			u8(raylib.GetRandomValue(200, 240)),
			u8(raylib.GetRandomValue(200, 240)),
			u8(raylib.GetRandomValue(200, 240)),
			255,
		}
	}

	camera: raylib.Camera2D = {
		target   = {player.x + 20, player.y + 20},
		offset   = {f32(screenWidth / 2), f32(screenHeight / 2)},
		rotation = 0,
		zoom     = 1,
	}

	raylib.SetTargetFPS(60)

	for !raylib.WindowShouldClose() {


		if raylib.IsKeyDown(.RIGHT) {
			player.x += 2
		} else if raylib.IsKeyDown(.LEFT) {
			player.x -= 2
		}

		camera.target = {player.x + 20, player.y + 20}

		if raylib.IsKeyDown(.A) {
			camera.rotation -= 1
		} else if raylib.IsKeyDown(.S) {
			camera.rotation += 1
		}

		if camera.rotation > 40 {
			camera.rotation = 40
		} else if camera.rotation < -40 {
			camera.rotation = -40
		}

		camera.zoom = libc.expf(libc.logf(camera.zoom) + raylib.GetMouseWheelMove() * 0.1)

		if camera.zoom > 3 {
			camera.zoom = 3
		} else if camera.zoom < 0.1 {
			camera.zoom = 0.1
		}

		if (raylib.IsKeyPressed(.R)) {
			camera.zoom = 1
			camera.rotation = 0
		}

		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.RAYWHITE)

		raylib.BeginMode2D(camera)
		raylib.DrawRectangle(-6000, 320, 13000, 8000, raylib.DARKGRAY)
		for i := 0; i < MAX_BUILDINGS; i += 1 {
			raylib.DrawRectangleRec(buildings[i], buildingColors[i])
		}
		raylib.DrawRectangleRec(player, raylib.RED)
		raylib.DrawLine(
			c.int(camera.target.x),
			-screenHeight * 10,
			c.int(camera.target.x),
			screenHeight * 10,
			raylib.GREEN,
		)
		raylib.DrawLine(
			-screenWidth * 10,
			c.int(camera.target.y),
			screenWidth * 10,
			c.int(camera.target.y),
			raylib.GREEN,
		)
		raylib.EndMode2D()

		raylib.DrawText("SCREEN AREA", 640, 10, 20, raylib.RED)

		raylib.DrawRectangle(0, 0, screenWidth, 5, raylib.RED)
		raylib.DrawRectangle(0, 5, 5, screenHeight - 10, raylib.RED)
		raylib.DrawRectangle(screenWidth - 5, 5, 5, screenHeight - 10, raylib.RED)
		raylib.DrawRectangle(0, screenHeight - 5, screenWidth, 5, raylib.RED)

		raylib.DrawRectangle(10, 10, 250, 113, raylib.Fade(raylib.SKYBLUE, 0.5))
		raylib.DrawRectangleLines(10, 10, 250, 113, raylib.BLUE)

		raylib.DrawText("Free 2D camera controls:", 20, 20, 10, raylib.BLACK)
		raylib.DrawText("- Right/Left to move player", 40, 40, 10, raylib.DARKGRAY)
		raylib.DrawText("- Mouse Wheel to Zoom in-out", 40, 60, 10, raylib.DARKGRAY)
		raylib.DrawText("- A / S to Rotate", 40, 80, 10, raylib.DARKGRAY)
		raylib.DrawText("- R to reset Zoom and Rotation", 40, 100, 10, raylib.DARKGRAY)


		raylib.EndDrawing()
	}

	raylib.CloseWindow()
}
