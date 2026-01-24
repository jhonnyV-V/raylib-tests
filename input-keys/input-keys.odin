package inputKeys

import "core:c"
import "core:fmt"
import "vendor:raylib"


main :: proc() {
	screenWidth: c.int = 800
	screenHeight: c.int = 450
	currentFps: c.int = 60

	speed: f32 = 100
	sprintSpeedBoost: f32 = 40
	currentSpeed: f32 = speed

	circleRadius: f32 = 32.0
	deltaCircle: raylib.Vector2 = {
		f32(screenWidth / 2.0) - circleRadius,
		f32(screenHeight / 2.0) - circleRadius,
	}

	raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - input keys")

	raylib.SetTargetFPS(currentFps)

	for !raylib.WindowShouldClose() {

		if raylib.IsKeyUp(raylib.KeyboardKey.LEFT_SHIFT) {
			currentSpeed = speed
		}
		if raylib.IsKeyDown(raylib.KeyboardKey.LEFT_SHIFT) {
			currentSpeed = speed + sprintSpeedBoost
		}

		if raylib.IsKeyDown(raylib.KeyboardKey.UP) {
			deltaCircle.y += raylib.GetFrameTime() * 6.0 * currentSpeed * -1
		}
		if raylib.IsKeyDown(raylib.KeyboardKey.DOWN) {
			deltaCircle.y += raylib.GetFrameTime() * 6.0 * currentSpeed
		}
		if raylib.IsKeyDown(raylib.KeyboardKey.LEFT) {
			deltaCircle.x += raylib.GetFrameTime() * 6.0 * currentSpeed * -1
		}
		if raylib.IsKeyDown(raylib.KeyboardKey.RIGHT) {
			deltaCircle.x += raylib.GetFrameTime() * 6.0 * currentSpeed
		}

		if deltaCircle.y < 0 {
			deltaCircle.y = f32(screenHeight)
		}
		if deltaCircle.y > f32(screenHeight) {
			deltaCircle.y = 0
		}
		if deltaCircle.x < 0 {
			deltaCircle.x = f32(screenWidth)
		}
		if deltaCircle.x > f32(screenWidth) {
			deltaCircle.x = 0
		}

		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.RAYWHITE)

		raylib.DrawText(
			"move the ball with arrow keys and shift to sprint",
			10,
			10,
			20,
			raylib.DARKGRAY,
		)

		raylib.DrawCircleV(deltaCircle, circleRadius, raylib.MAROON)

		raylib.EndDrawing()
	}

	raylib.CloseWindow()
}
