package basicWindow

import "core:c"
import "core:fmt"
import "vendor:raylib"

main :: proc() {
	screenWidth: c.int = 800
	screenHeight: c.int = 450
	raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window")
	raylib.SetTargetFPS(60)

	renderCounter: uint = 0
	for !raylib.WindowShouldClose() {
		renderCounter += 1
		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.RAYWHITE)
		message := fmt.ctprint("Somehow this is this simple, render counter: ", renderCounter)
		raylib.DrawText(message, 150, 200, 20, raylib.LIGHTGRAY)
		raylib.EndDrawing()
	}

	raylib.CloseWindow()
}
