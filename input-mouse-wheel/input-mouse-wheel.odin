package inputMouseWheel

import "core:c"
import "core:fmt"
import "vendor:raylib"

main :: proc() {
	screenWidth: c.int = 800
	screenHeight: c.int = 450
	currentFps: c.int = 60

	raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - input mouse wheel")

	boxPositionX: c.int = (screenWidth / 2) - 40
	boxPositionY: c.int = screenHeight / 2.0
	speed: f32 = 10.0

	raylib.SetTargetFPS(currentFps)

	for !raylib.WindowShouldClose() {
		mouseWheel := raylib.GetMouseWheelMove()
		if mouseWheel < 0 {
			boxPositionY += c.int(mouseWheel * 6.0 * speed)
		}

		if mouseWheel > 0 {
			boxPositionY += c.int(mouseWheel * 6.0 * speed)
		}

		if boxPositionY > screenHeight {
			boxPositionY = 0
		}

		if boxPositionY < 0 {
			boxPositionY = screenHeight
		}

		if raylib.IsKeyPressed(raylib.KeyboardKey.R) {
			boxPositionY = screenHeight / 2
		}

		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.RAYWHITE)

		raylib.DrawRectangle(boxPositionX, boxPositionY, 80, 80, raylib.MAROON)

		raylib.DrawText("Use mouse wheel to move the cube up and down!", 10, 10, 20, raylib.GRAY)
		raylib.DrawText(
			raylib.TextFormat("Box position Y: %03i", boxPositionY),
			10,
			40,
			20,
			raylib.LIGHTGRAY,
		)

		raylib.EndDrawing()
	}

	raylib.CloseWindow()
}
