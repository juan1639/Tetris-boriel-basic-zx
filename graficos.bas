'===========================================================================
'---  TETR1S-Clon ZX Boriel  -  Modulo: graficos.bas
'---  UDG del bloque (SevenuP) y puntero de graficos de usuario
'---  (se incluye desde tetris.bas con #include, no se compila suelto)
'===========================================================================

'=======================================================================
SUB actualizar_punteros_sprites(spriteId as string)

    IF (spriteId = "pieza-bloque") THEN

        Asm
            ld de, _pieza_bloque
            ld (_spritesPtr), de
        End Asm
    
    END IF

    POKE UInteger 23675, spritesPtr

END SUB

'============================================================================
' S P R I T E S  (dibujados con SevenuP y exportados a bytes asm)
'----------------------------------------------------------------------------
Asm
    _pieza_bloque:
        DEFB	  0,126,126,126,126,126,126,  0
	    DEFB	128,192,224,240,248,252,254,255
End Asm
