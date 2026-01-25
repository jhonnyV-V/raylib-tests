package inputMouse

import "core:c"
import "core:fmt"
import "vendor:raylib"

main :: proc() {
	screenWidth: c.int = 800
	screenHeight: c.int = 450
	currentFps: c.int = 60

	ballPosition: raylib.Vector2 = {-100, -100}
	ballColor: raylib.Color = raylib.DARKBLUE

	raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - input mouse")
	raylib.SetTargetFPS(currentFps)

	for !raylib.WindowShouldClose() {
		if raylib.IsKeyPressed(raylib.KeyboardKey.H) {
			if raylib.IsCursorHidden() {
				raylib.ShowCursor()
			} else {
				raylib.HideCursor()
			}
		}

		ballPosition = raylib.GetMousePosition()

		if raylib.IsMouseButtonPressed(raylib.MouseButton.LEFT) {
			ballColor = raylib.MAROON
		} else if raylib.IsMouseButtonPressed(raylib.MouseButton.MIDDLE) {
			ballColor = raylib.LIME
		} else if raylib.IsMouseButtonPressed(raylib.MouseButton.RIGHT) {
			ballColor = raylib.DARKBLUE
		} else if raylib.IsMouseButtonPressed(raylib.MouseButton.SIDE) {
			ballColor = raylib.PURPLE
		} else if raylib.IsMouseButtonPressed(raylib.MouseButton.EXTRA) {
			ballColor = raylib.YELLOW
		} else if raylib.IsMouseButtonPressed(raylib.MouseButton.FORWARD) {
			ballColor = raylib.ORANGE
		} else if raylib.IsMouseButtonPressed(raylib.MouseButton.BACK) {
			ballColor = raylib.BEIGE
		}

		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.RAYWHITE)

		raylib.DrawCircleV(ballPosition, 40, ballColor)
		raylib.DrawText(
			"move ball with mouse and click mouse button to change color",
			10,
			10,
			20,
			raylib.DARKGRAY,
		)
		raylib.DrawText("Press 'H' to toggle cursor visibility", 10, 30, 20, raylib.DARKGRAY)

		if raylib.IsCursorHidden() {
			raylib.DrawText("CURSOR HIDDEN", 20, 60, 20, raylib.RED)
		} else {
			raylib.DrawText("CURSOR VISIBLE", 20, 60, 20, raylib.LIME)
		}

		raylib.EndDrawing()
	}

	raylib.CloseWindow()
}
