'===========================================================================
'---  TETR1S-Clon ZX Boriel  -  Modulo: sonido.bas
'---  Efectos de sonido y musicas (BEEP)
'---  (se incluye desde tetris.bas con #include, no se compila suelto)
'===========================================================================

'============================================================================
SUB sonidoAscend(ini AS Byte, fin AS Byte, salto AS Byte)

    DIM c AS Byte

    FOR c = ini TO fin STEP salto
        BEEP 0.01, c
    NEXT c 

END SUB

'============================================================================
SUB musics(musica AS string, ralentizador)

    IF (musica = "back-future") THEN
        BEEP 1 * ralentizador, -8
        BEEP 1 * ralentizador, -1
        BEEP 0.5 * ralentizador, 4
        BEEP 1 * ralentizador, 2

        PAUSE 5 * ralentizador
        BEEP 0.2 * ralentizador, 1
        BEEP 0.2 * ralentizador, -1
        BEEP 0.5 * ralentizador, 1
        BEEP 0.5 * ralentizador, -1
        BEEP 0.5 * ralentizador, -3
        BEEP 1 * ralentizador, -1
    END IF

    IF (musica = "game-over") THEN
        BEEP 0.40 * ralentizador, -5
        BEEP 0.40 * ralentizador, -5
        BEEP 0.40 * ralentizador, -5
        BEEP 0.60 * ralentizador, -9
        BEEP 0.20 * ralentizador, -2
        BEEP 0.40 * ralentizador, -5
        BEEP 0.60 * ralentizador, -9
        BEEP 0.20 * ralentizador, -2
        BEEP 0.80 * ralentizador, -5

        PAUSE 10
        ' Notas agudas finales del cortocircuito
        BEEP 0.15 * ralentizador, 7
        BEEP 0.15 * ralentizador, 6
        BEEP 0.15 * ralentizador, 5
        BEEP 0.30 * ralentizador, 4
    END IF

    IF (musica = "fanfarria-victoria") THEN
        BEEP 0.10 * ralentizador, 0
        BEEP 0.10 * ralentizador, 4
        BEEP 0.10 * ralentizador, 7
        BEEP 0.20 * ralentizador, 12 
        BEEP 0.10 * ralentizador, 7
        BEEP 0.20 * ralentizador, 12

        PAUSE 5
        BEEP 0.15 * ralentizador, 12
        BEEP 0.15 * ralentizador, 11
        BEEP 0.15 * ralentizador, 10
        BEEP 0.15 * ralentizador, 9 
        BEEP 0.40 * ralentizador, 8

        PAUSE 10
        BEEP 0.15 * ralentizador, 2
        BEEP 0.15 * ralentizador, 6
        BEEP 0.15 * ralentizador, 9
        BEEP 0.30 * ralentizador, 14
        BEEP 0.40 * ralentizador, 12 
    END IF

    IF (musica = "tetris") THEN
        ' --- FRASE A1 ---
        BEEP 0.30 * ralentizador, 16  ' Mi
        BEEP 0.15 * ralentizador, 11  ' Si
        BEEP 0.15 * ralentizador, 12  ' Do
        BEEP 0.30 * ralentizador, 14  ' Re
        BEEP 0.15 * ralentizador, 12  ' Do
        BEEP 0.15 * ralentizador, 11  ' Si
        BEEP 0.30 * ralentizador, 9   ' La
        BEEP 0.15 * ralentizador, 9   ' La
        BEEP 0.15 * ralentizador, 12  ' Do
        BEEP 0.30 * ralentizador, 16  ' Mi
        BEEP 0.15 * ralentizador, 14  ' Re
        BEEP 0.15 * ralentizador, 12  ' Do
        BEEP 0.45 * ralentizador, 11  ' Si
        BEEP 0.15 * ralentizador, 12  ' Do
        BEEP 0.30 * ralentizador, 14  ' Re
        BEEP 0.30 * ralentizador, 16  ' Mi
        BEEP 0.30 * ralentizador, 12  ' Do
        BEEP 0.30 * ralentizador, 9   ' La
        BEEP 0.30 * ralentizador, 9   ' La
        
        ' --- FRASE A2 ---
        PAUSE 5 * ralentizador        ' Silencio corto de transición
        BEEP 0.45 * ralentizador, 14  ' Re
        BEEP 0.15 * ralentizador, 17  ' Fa#
        BEEP 0.30 * ralentizador, 21  ' La alto
        BEEP 0.15 * ralentizador, 19  ' Sol
        BEEP 0.15 * ralentizador, 17  ' Fa#
        BEEP 0.45 * ralentizador, 16  ' Mi
        BEEP 0.15 * ralentizador, 12  ' Do
        BEEP 0.30 * ralentizador, 16  ' Mi
        BEEP 0.15 * ralentizador, 14  ' Re
        BEEP 0.15 * ralentizador, 12  ' Do
        BEEP 0.30 * ralentizador, 11  ' Si
        BEEP 0.15 * ralentizador, 11  ' Si
        BEEP 0.15 * ralentizador, 12  ' Do
        BEEP 0.30 * ralentizador, 14  ' Re
        BEEP 0.30 * ralentizador, 16  ' Mi
        BEEP 0.30 * ralentizador, 12  ' Do
        BEEP 0.30 * ralentizador, 9   ' La
        BEEP 0.30 * ralentizador, 9   ' La
    END IF

END SUB
