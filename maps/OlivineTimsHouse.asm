const_value set 2
	const OLIVINETIMSHOUSE_TIM

OlivineTimsHouse_MapScriptHeader:
.MapTriggers:
	db 0

.MapCallbacks:
	db 0

Tim:
	faceplayer
	opentext
	trade $2
	waitbutton
	closetext
	end

OlivineTimsHouse_MapEventHeader:
	; filler
	db 0, 0

.Warps:
	db 2
	warp_def $7, $2, 3, OLIVINE_CITY
	warp_def $7, $3, 3, OLIVINE_CITY

.XYTriggers:
	db 0

.Signposts:
	db 0

.PersonEvents:
	db 1
	person_event SPRITE_FISHING_GURU, 3, 2, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, (1 << 3) | PAL_OW_RED, PERSONTYPE_SCRIPT, 0, Tim, -1
