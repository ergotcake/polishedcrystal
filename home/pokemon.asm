DrawBattleHPBar:: ; 3750
; Draw an HP bar d tiles long at hl
; Fill it up to e pixels

	push hl
	push de
	push bc

; Place 'HP:'
	ld a, "<HP1>"
	ld [hli], a
	inc a ; ld a, "<HP2>"
	ld [hli], a

; Draw a template
	push hl
	inc a ; ld a, "<NOHP>" ; empty bar
.template
	ld [hli], a
	dec d
	jr nz, .template
	ld a, "<HPEND>" ; bar end cap
	ld [hl], a
	pop hl

; Safety check # pixels
	ld a, e
	and a
	jr nz, .fill
	ld a, c
	and a
	jr z, .done
	ld e, 1

.fill
; Keep drawing tiles until pixel length is reached
	ld a, e
	sub TILE_WIDTH
	jr c, .lastbar

	ld e, a
	ld a, "<FULLHP>"
	ld [hli], a
	ld a, e
	and a
	jr z, .done
	jr .fill

.lastbar
	ld a, "<NOHP>"
	add e
	ld [hl], a

.done
	pop bc
	pop de
	pop hl
	ret
; 3786

PrepMonFrontpic:: ; 3786
	ld a, $1
	ld [wBoxAlignment], a

_PrepMonFrontpic:: ; 378b
	ld a, [wCurPartySpecies]
	and a
	jr z, .not_pokemon

	push hl
	ld de, vTiles2
	predef GetFrontpic
	pop hl
	xor a
	ld [hGraphicStartTile], a
	lb bc, 7, 7
	predef PlaceGraphic
	xor a
	ld [wBoxAlignment], a
	ret

.not_pokemon
	xor a
	ld [wBoxAlignment], a
	inc a
	ld [wCurPartySpecies], a
	ret
; 37b6

PrintLevel:: ; 382d
; Print wTempMonLevel at hl

	ld a, [wTempMonLevel]
	ld [hl], "<LV>"
	inc hl

; How many digits?
	ld c, 2
	cp 100
	jr c, Print8BitNumRightAlign

; 3-digit numbers overwrite the :L.
	dec hl
	inc c
	; fallthrough

Print8BitNumRightAlign:: ; 3842
	ld [wd265], a
	ld de, wd265
	ld b, PRINTNUM_LEFTALIGN | 1
	jp PrintNum
; 384d

GetBaseData:: ; 3856
	push bc
	push de
	push hl
	ld a, [hROMBank]
	push af
	ld a, BANK(BaseData)
	rst Bankswitch

; Egg doesn't have BaseData
	ld a, [wCurSpecies]
	cp EGG
	jr z, .egg

; Get BaseData
	dec a
	ld bc, BASEMON_STRUCT_LENGTH
	ld hl, BaseData
	rst AddNTimes
	ld de, wCurBaseData
	ld bc, BASEMON_STRUCT_LENGTH
	rst CopyBytes
	jr .end

.egg
;; Sprite dimensions
	ld a, $55 ; 5x5
	ld [wBasePicSize], a

.end
	pop af
	rst Bankswitch
	pop hl
	pop de
	pop bc
	ret
; 389c

GetNature::
; 'b' contains the target Nature to check
; returns nature in b
	ld a, [wInitialOptions]
	bit NATURES_OPT, a
	jr z, .no_nature
	ld a, b
	and NATURE_MASK
	; assume nature is 0-24
	ld b, a
	ret

.no_nature:
	ld b, NO_NATURE
	ret

GetLeadAbility::
; Returns ability of lead mon unless it's an Egg. Used for field
; abilities
	ld a, [wPartyMon1IsEgg]
	and IS_EGG_MASK
	xor IS_EGG_MASK
	ret z
	ld a, [wPartyMon1Species]
	inc a
	ret z
	dec a
	ret z
	push bc
	push de
	push hl
	ld c, a
	ld a, [wPartyMon1Ability]
	ld b, a
	call GetAbility
	ld a, b
	pop hl
	pop de
	pop bc
	ret

GetAbility::
; 'b' contains the target ability to check
; 'c' contains the target species
; returns ability in b
; preserves curspecies and base data
	anonbankpush BaseData

.Function:
	ld a, [wInitialOptions]
	and ABILITIES_OPTMASK
	jr z, .got_ability

	push hl
	push bc
	ld hl, BASEMON_ABILITIES
	ld b, 0
	ld a, BASEMON_STRUCT_LENGTH
	dec c
	rst AddNTimes
	pop bc
	push bc
	ld a, b
	and ABILITY_MASK
	cp ABILITY_1
	jr z, .got_ability_ptr
	inc hl
	cp ABILITY_2
	jr z, .got_ability_ptr
	inc hl
.got_ability_ptr
	ld a, [hl]
	pop bc
	pop hl
.got_ability
	ld b, a
	ret

GetCurNick:: ; 389c
	ld a, [wCurPartyMon]
	ld hl, wPartyMonNicknames

GetNick:: ; 38a2
; Get nickname a from list hl.
	push hl
	push bc
	call SkipNames
	ld de, wStringBuffer1
	push de
	ld bc, PKMN_NAME_LENGTH
	rst CopyBytes
	pop de
	pop bc
	pop hl
	ret
; 38bb
