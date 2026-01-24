package deltaTime

import "core:c"
import "core:fmt"
import "vendor:raylib"

main :: proc() {
	screenWidth: c.int = 800
	screenHeight: c.int = 450
	currentFps: c.int = 60

	raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - delta time")

	deltaCircle: raylib.Vector2 = {0, f32(screenHeight / 3.0)}
	frameCircle: raylib.Vector2 = {0, f32(screenHeight) * f32(2.0 / 3.0)}
	speed: f32 = 10.0
	circleRadius: f32 = 32.0

	raylib.SetTargetFPS(currentFps)

	for !raylib.WindowShouldClose() {
		mouseWheel := raylib.GetMouseWheelMove()
		if mouseWheel != 0 {
			currentFps += c.int(mouseWheel)
			if currentFps < 0 {
				currentFps = 0
			}
			raylib.SetTargetFPS(currentFps)
		}


		deltaCircle.x += raylib.GetFrameTime() * 6.0 * speed
		frameCircle.x += 0.1 * speed

		if deltaCircle.x > f32(screenWidth) {
			deltaCircle.x = 0
		}
		if frameCircle.x > f32(screenWidth) {
			frameCircle.x = 0
		}

		if raylib.IsKeyPressed(raylib.KeyboardKey.R) {
			deltaCircle.x = 0
			frameCircle.x = 0
		}

		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.RAYWHITE)

		raylib.DrawCircleV(deltaCircle, circleRadius, raylib.BLUE)
		raylib.DrawCircleV(frameCircle, circleRadius, raylib.RED)


		fpsText: cstring = ""
		if currentFps <= 0 {
			fpsText = raylib.TextFormat("FPS: unlimited (%i)", raylib.GetFPS())
		} else {
			fpsText = raylib.TextFormat("FPS: %i (target: %i)", raylib.GetFPS(), currentFps)
		}
		raylib.DrawText(fpsText, 10, 10, 20, raylib.DARKGRAY)
		raylib.DrawText(
			raylib.TextFormat("Frame time: %02.02f ms", raylib.GetFrameTime()),
			10,
			30,
			20,
			raylib.DARKGRAY,
		)
		raylib.DrawText(
			"Use the scroll wheel to change the fps limit, r to reset",
			10,
			50,
			20,
			raylib.DARKGRAY,
		)

		// Draw the text above the circles
		raylib.DrawText("FUNC: x += GetFrameTime()*speed", 10, 90, 20, raylib.BLUE)
		raylib.DrawText("FUNC: x += speed", 10, 240, 20, raylib.RED)

		raylib.EndDrawing()
	}

	raylib.CloseWindow()
}
