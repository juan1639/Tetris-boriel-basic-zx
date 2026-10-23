'===========================================================================
'---  TETR1S-Clon ZX Boriel  -  Modulo: tablero.bas
'---  Tablero y pantalla: marco, fondo, handicap, lineas, marcadores y siguiente pieza
'---  (se incluye desde tetris.bas con #include, no se compila suelto)
'===========================================================================

'-------------------------------------------------------------------
SUB dibuja_ui()

    INK 5
    PLOT 15, 191
    DRAW 0, -168
    DRAW 81, 0
    DRAW 0, 168

    PLOT 127, 80
    DRAW 0, -49
    DRAW 49, 0
    DRAW 0, 49
    DRAW -49, 0

END SUB

'===================================================================
SUB dibuja_fondo()

    DIM y AS Ubyte
    DIM x AS Ubyte
    DIM fondo_grid_x AS Ubyte
    DIM fondo_grid_y AS Ubyte

    actualizar_punteros_sprites("pieza-bloque")

    FOR y = 0 TO NRO_FILAS
        FOR x = 0 TO NRO_COLUMNAS

            IF (fondo(y, x) = 0) THEN
                PRINT AT y, x + OFF_SET_X; PAPER 0; INK 1; " "

            ELSE IF (fondo(y, x) > 0) THEN
                PRINT AT y, x + OFF_SET_X; PAPER 0; INK COL_RASTRO_PIEZA; CHR$(144)

            END IF

        NEXT x
    NEXT y

END SUB

'===================================================================
SUB reset_area_juego_fondo()

    DIM y AS Ubyte
    DIM x As Ubyte

    FOR y = 0 TO NRO_FILAS
        FOR x = 0 TO NRO_COLUMNAS
            fondo(y, x) = 0
        NEXT x
    NEXT y
END SUB

'===================================================================
SUB set_handicap_game()

    DIM aleatorioX As Ubyte
    DIM aleatorioY As Ubyte

    IF (handicap > 0) THEN
        aleatorioY = INT(RND * 3)
        aleatorioX = INT(RND * (NRO_COLUMNAS + 1))
        fondo(19, aleatorioX) = 1

        aleatorioX = INT(RND * (NRO_COLUMNAS + 1))
        fondo(17 - aleatorioY, aleatorioX) = 1
    END IF

END SUB

'=======================================================================
SUB check_lineas_hechas()

    DIM y AS Ubyte
    DIM x AS Ubyte
    DIM backup_score As UInteger = score
    DIM contador_para_hacer_linea AS Ubyte
    DIM hasta_cuatro_veces AS Ubyte

    backup_score = score

    FOR y = NRO_FILAS TO 1 STEP -1

        hasta_cuatro_veces = 0

        DO
            contador_para_hacer_linea = 0

            ' El tablero tiene NRO_COLUMNAS + 1 columnas (0..9 = 10 columnas)
            FOR x = 0 TO NRO_COLUMNAS
                IF (fondo(y, x) > 0) THEN contador_para_hacer_linea = contador_para_hacer_linea + 1
            NEXT

            IF contador_para_hacer_linea > NRO_COLUMNAS THEN
                sonidoAscend(-20, -2, 2)
                score = score + 1

                IF (score MOD 10 = 0 AND score > 0) THEN nivel = nivel + 1
                IF (nivel > 33) THEN nivel = 33

                actualizar_fondo(y)
            ELSE
                hasta_cuatro_veces = 1
            END IF

        LOOP UNTIL hasta_cuatro_veces > 0

    NEXT y

    lines_same_time = score - backup_score

    IF (lines_same_time > 0) THEN
        timer_show_bonus = SHOW_BONUS_DURATION
        dibuja_bonus_lines_same_time("dibujar")
    END IF

END SUB

'=======================================================================
SUB actualizar_fondo(fila AS Ubyte)

    DIM x AS UByte
    DIM y AS UByte

    actualizar_punteros_sprites("pieza-bloque")

    ' Baja todas las filas de encima (hasta la fila 1) y vacia la fila 0.
    ' Se dibujan tambien las celdas vacias, para no dejar bloques "fantasma".
    FOR y = fila TO 1 STEP -1
        FOR x = 0 TO NRO_COLUMNAS

            fondo(y, x) = fondo(y - 1, x)

            IF (fondo(y, x) > 0) THEN
                PRINT AT y, x + OFF_SET_X; PAPER 0; INK COL_RASTRO_PIEZA; CHR$(144)
            ELSE
                PRINT AT y, x + OFF_SET_X; PAPER 0; INK 1; " "
            END IF
        NEXT x
    NEXT y

    FOR x = 0 TO NRO_COLUMNAS
        fondo(0, x) = 0
        PRINT AT 0, x + OFF_SET_X; PAPER 0; INK 1; " "
    NEXT x

END SUB

'=======================================================================
SUB dibuja_bonus_lines_same_time(borrar_dibujar As string)

    IF (borrar_dibujar = "dibujar") THEN 
        PRINT AT BONUS_LINES_SAME_TIME_Y, BONUS_LINES_SAME_TIME_X; FLASH 1; BRIGHT 1; INK 5; "+"; lines_same_time
    ELSE IF (borrar_dibujar = "borrar") THEN
        PRINT AT BONUS_LINES_SAME_TIME_Y, BONUS_LINES_SAME_TIME_X; FLASH 0; BRIGHT 1; INK 5; "   "
    END IF

END SUB

'=======================================================================
SUB dibuja_next_pieza()

    DIM a As Ubyte

    DIM y As Byte
    DIM x As Byte
    DIM bloque_y As Byte
    DIM bloque_x As Byte

    DIM col_l As Ubyte
    DIM col_b As Ubyte

    FOR a = 0 TO 6 STEP 2

        y = piezas(pieza_siguiente + 0, a)
        x = piezas(pieza_siguiente + 0, a + 1)

        bloque_y = 16 + y
        bloque_x = MARGEN_SCORES + 1 + x

        col_l = colores_piezas(INT(pieza_siguiente / 4), 1)
        col_b = colores_piezas(INT(pieza_siguiente / 4), 0)
        PRINT AT bloque_y, bloque_x + OFF_SET_X; PAPER col_l; INK col_b; CHR$(144)
    NEXT a

END SUB

'=======================================================================
SUB mostrar_marcadores()

    PRINT AT 1, MARGEN_SCORES; BRIGHT 1; PAPER 2; INK 6; "             "
    PRINT AT 2, MARGEN_SCORES; BRIGHT 1; PAPER 2; INK 6; "             "
    PRINT AT 2, MARGEN_SCORES; BRIGHT 1; PAPER 2; INK 6; " Score:  ";
    PRINT BRIGHT 1; PAPER 2; INK 7; score
    PRINT AT 3, MARGEN_SCORES; BRIGHT 1; PAPER 2; INK 6; "             "

    PRINT AT 5, MARGEN_SCORES; BRIGHT 1; PAPER 2; INK 6; "             "
    PRINT AT 6, MARGEN_SCORES; BRIGHT 1; PAPER 2; INK 6; "             "
    PRINT AT 6, MARGEN_SCORES; BRIGHT 1; PAPER 2; INK 6; " Record: ";
    PRINT BRIGHT 1; PAPER 2; INK 7;record
    PRINT AT 7, MARGEN_SCORES; BRIGHT 1; PAPER 2; INK 6; "             "

    PRINT AT 9, MARGEN_SCORES; BRIGHT 0; PAPER 1; INK 6; "             "
    PRINT AT 10, MARGEN_SCORES; BRIGHT 0; PAPER 1; INK 6; "             "
    PRINT AT 10, MARGEN_SCORES; BRIGHT 0; PAPER 1; INK 6; " Level:  ";
    PRINT BRIGHT 0; PAPER 1; INK 7; nivel
    PRINT AT 11, MARGEN_SCORES; BRIGHT 0; PAPER 1; INK 6; "             "

    PRINT AT 14, MARGEN_SCORES; BRIGHT 1; PAPER 0; INK 6; "      "
    PRINT AT 15, MARGEN_SCORES; BRIGHT 1; PAPER 0; INK 6; "      "
    PRINT AT 16, MARGEN_SCORES; BRIGHT 1; PAPER 0; INK 6; "      "
    PRINT AT 17, MARGEN_SCORES; BRIGHT 1; PAPER 0; INK 6; "      "
    PRINT AT 18, MARGEN_SCORES; BRIGHT 1; PAPER 0; INK 6; "      "
    PRINT AT 19, MARGEN_SCORES; BRIGHT 1; PAPER 0; INK 6; "      "

END SUB
