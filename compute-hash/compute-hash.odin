package computeHash

import "core:c"
import "core:fmt"
import "vendor:libc"
import "vendor:raylib"


main :: proc() {
	screenWidth: c.int = 800
	screenHeight: c.int = 450
	raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - compute hash")

	// char; textInput[96] = "The quick brown fox jumps over the lazy dog."
	textInput: cstring = "The quick brown fox jumps over the lazy dog."
	textBoxEditMode := false
	btnComputeHashes := false

	// Data hash values
	hashCRC32: c.uint = 0
	hashMD5: [^]c.uint = {}
	hashSHA1: [^]c.uint = {}

	// Base64 encoded data
	base64Text: [^]byte = {}
	base64TextSize: c.int = 0

	raylib.SetTargetFPS(60)

	textBoxPosition: raylib.Rectangle = {40, 26, 720, 32}
	buttonPosition: raylib.Rectangle = {40, 26 + 78, 720, 32}

	for !raylib.WindowShouldClose() {

		if btnComputeHashes {
			textInputLen := c.int(len(textInput))
			base64Text = raylib.EncodeDataBase64(rawptr(&textInput), textInputLen, &base64TextSize)

			hashCRC32 = raylib.ComputeCRC32(rawptr(&textInput), textInputLen)
			hashMD5 = raylib.ComputeMD5(rawptr(&textInput), textInputLen)
			hashSHA1 = raylib.ComputeSHA1(rawptr(&textInput), textInputLen)

		}

		raylib.BeginDrawing()
		raylib.ClearBackground(raylib.RAYWHITE)

		raylib.GuiSetStyle(.DEFAULT, c.int(raylib.GuiDefaultProperty.TEXT_SIZE), 20)
		raylib.GuiSetStyle(.DEFAULT, c.int(raylib.GuiDefaultProperty.TEXT_SPACING), 2)
		raylib.GuiLabel(textBoxPosition, "INPUT DATA (TEXT):")

		raylib.GuiSetStyle(.DEFAULT, c.int(raylib.GuiDefaultProperty.TEXT_SIZE), 10)
		raylib.GuiSetStyle(.DEFAULT, c.int(raylib.GuiDefaultProperty.TEXT_SPACING), 1)

		if raylib.GuiTextBox(textBoxPosition, textInput, 95, textBoxEditMode) {
			textBoxEditMode = !textBoxEditMode
		}
		btnComputeHashes = raylib.GuiButton(buttonPosition, "COMPUTE INPUT DATA HASHES")

		raylib.GuiSetStyle(.DEFAULT, c.int(raylib.GuiDefaultProperty.TEXT_SIZE), 20)
		raylib.GuiSetStyle(.DEFAULT, c.int(raylib.GuiDefaultProperty.TEXT_SPACING), 2)

		raylib.GuiLabel({40, 160, 720, 32}, "INPUT DATA HASH VALUES:")

		raylib.GuiSetStyle(.DEFAULT, c.int(raylib.GuiDefaultProperty.TEXT_SIZE), 10)
		raylib.GuiSetStyle(.DEFAULT, c.int(raylib.GuiDefaultProperty.TEXT_SPACING), 1)

		raylib.GuiSetStyle(.TEXTBOX, c.int(raylib.GuiTextBoxProperty.TEXT_READONLY), 1)
		raylib.GuiLabel({40, 200, 120, 32}, "CRC32 [32 bit]:")

		raylib.GuiTextBox(
			{40 + 120, 200, 720 - 120, 32},
			getDataAsHexText(&hashCRC32, 1),
			120,
			false,
		)
		raylib.GuiLabel({40, 200 + 36, 120, 32}, "MD5 [128 bit]:")
		raylib.GuiTextBox(
			{40 + 120, 200 + 36, 720 - 120, 32},
			getDataAsHexText(hashMD5, 4),
			120,
			false,
		)
		raylib.GuiLabel({40, 200 + 36 * 2, 120, 32}, "SHA1 [160 bit]:")
		raylib.GuiTextBox(
			{40 + 120, 200 + 36 * 2, 720 - 120, 32},
			getDataAsHexText(hashSHA1, 5),
			120,
			false,
		)

		raylib.GuiSetState(c.int(raylib.GuiState.STATE_FOCUSED))
		raylib.GuiLabel({40, 200 + 36 * 5 - 30, 320, 32}, "BONUS - BAS64 ENCODED STRING:")
		raylib.GuiSetState(c.int(raylib.GuiState.STATE_NORMAL))
		raylib.GuiLabel({40, 200 + 36 * 5, 120, 32}, "BASE64 ENCODING:")
		raylib.GuiTextBox({40 + 120, 200 + 36 * 5, 720 - 120, 32}, cstring(base64Text), 120, false)
		raylib.GuiSetStyle(.TEXTBOX, c.int(raylib.GuiTextBoxProperty.TEXT_READONLY), 0)


		raylib.EndDrawing()
	}

	raylib.MemFree(rawptr(&base64Text))

	raylib.CloseWindow()
}

getDataAsHexText :: proc(data: [^]c.uint, dataSize: c.int) -> cstring {
	text: [^]byte = {}

	if data != nil && (dataSize > 0) && (dataSize < ((128 / 8) - 1)) {
		for i := 0; c.int(i) < dataSize; i += 1 {
			raylib.TextCopy(text[i * 8:], raylib.TextFormat("%08X", data[i]))
		}
	} else {
		raylib.TextCopy(text[:], "00000000")
	}

	return cstring(text)
}
