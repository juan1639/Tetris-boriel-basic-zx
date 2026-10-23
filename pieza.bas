'===========================================================================
'---  TETR1S-Clon ZX Boriel  -  Modulo: pieza.bas
'---  Pieza que cae: mover, rotar, colisiones, caida por tiempo, borrar/dibujar y dejar rastro
'---  (se incluye desde tetris.bas con #include, no se compila suelto)
'===========================================================================

'===================================================================
SUB logica_pieza()

    DIM old_y AS Ubyte
    DIM old_x AS Ubyte
    DIM old_rot AS Ubyte

    ' Guardamos el estado ANTES de mover/rotar, para poder borrar la pieza
    ' exactamente donde estaba y con la rotacion que tenia.
    old_y = piezaY
    old_x = piezaX
    old_rot = rotacion

    '----------------------------------------------
    mover_pieza()

    IF (sortear_next_pieza > 0) THEN
        ' La pieza ha tocado fondo: se borra la posicion vieja (por si en este
        ' mismo frame se movio de lado) y se deja el rastro.
        borrar_pieza(old_y, old_x, old_rot)
        dejar_rastro()
        RETURN
    END IF

    rotar_pieza()

    ' Solo se redibuja si algo ha cambiado: 1) borrar TODA la pieza vieja,
    ' 2) dibujar TODA la pieza nueva. Asi nunca se pisan bloques recien pintados.
    IF (piezaY <> old_y OR piezaX <> old_x OR rotacion <> old_rot) THEN
        borrar_pieza(old_y, old_x, old_rot)
        dibujar_pieza()
    END IF

    IF (rotacion <> old_rot) THEN
        sonidoAscend(-24, -8, 4)
    ELSE IF (piezaX <> old_x OR control_abajo > 0) THEN
        sonidoAscend(-50, -46, 4)
    END IF

END SUB

'=======================================================================
SUB borrar_pieza(py AS Ubyte, px AS Ubyte, rot AS Ubyte)

    DIM a AS Ubyte
    DIM x AS Byte
    DIM y AS Byte

    FOR a = 0 TO 6 STEP 2
        y = piezas(pieza_actual + rot, a)
        x = piezas(pieza_actual + rot, a + 1)
        PRINT AT py + y, px + x + OFF_SET_X; PAPER 0; INK 1; " "
    NEXT a

END SUB

'=======================================================================
SUB dibujar_pieza()

    DIM a AS Ubyte
    DIM x AS Byte
    DIM y AS Byte
    DIM col_l As Ubyte
    DIM col_b As Ubyte

    actualizar_punteros_sprites("pieza-bloque")

    col_l = colores_piezas(INT(pieza_actual / 4), 1)
    col_b = colores_piezas(INT(pieza_actual / 4), 0)

    FOR a = 0 TO 6 STEP 2
        y = piezas(pieza_actual + rotacion, a)
        x = piezas(pieza_actual + rotacion, a + 1)
        PRINT AT piezaY + y, piezaX + x + OFF_SET_X; PAPER col_l; INK col_b; CHR$(144)
    NEXT a

END SUB

'=======================================================================
SUB mover_pieza()

    '----------------------- IZQUIERDA ----------------------
    IF (control_izquierda > 0) THEN
        piezaX = piezaX - 1
        IF (check_colision_pieza() > 0) THEN piezaX = piezaX + 1
    END IF

    '----------------------- DERECHA ------------------------
    IF (control_derecha > 0) THEN
        piezaX = piezaX + 1
        IF (check_colision_pieza() > 0) THEN piezaX = piezaX - 1
    END IF

    ' (Ya no hay RETURN aqui: aunque se mueva de lado, la caida automatica
    '  se sigue aplicando. Antes, manteniendo O/P pulsada la pieza no caia.)

    '-------------------------- ABAJO ----------------------
    IF (control_abajo > 0 OR abajo_auto > 0) THEN

        piezaY = piezaY + 1

        IF (check_colision_pieza() > 0) THEN

            piezaY = piezaY - 1

            IF (piezaY <= PIEZA_POS_INICIAL_Y + 1) THEN
                gameover = 1
            END IF

            sortear_next_pieza = 1
        END IF

    END IF

END SUB

'=======================================================================
SUB rotar_pieza()

    DIM backup_rotacion As Ubyte

    IF (control_rotar > 0) THEN

        backup_rotacion = rotacion
        rotacion = rotacion + 1

        IF (rotacion >= NRO_ROTACIONES) THEN rotacion = 0

        IF (check_colision_pieza() > 0) THEN rotacion = backup_rotacion
        ' (el borrado/dibujado lo hace logica_pieza)
    END IF

END SUB

'=======================================================================
FUNCTION check_colision_pieza()

    DIM a AS Ubyte
    DIM by AS Integer
    DIM bx AS Integer

    FOR a = 0 TO 6 STEP 2

        ' Se calcula con signo (Integer) para que el "< 0" funcione de verdad
        by = piezaY
        by = by + piezas(pieza_actual + rotacion, a)
        bx = piezaX
        bx = bx + piezas(pieza_actual + rotacion, a + 1)

        ' Limites area de juego:
        IF (bx > NRO_COLUMNAS OR bx < 0 OR by > NRO_FILAS OR by < 0) THEN
            RETURN 1
        END IF

        'Colision con rastros piezas:
        IF (fondo(by, bx) > 0) THEN
            RETURN 1
        END IF

    NEXT a

    RETURN 0

END FUNCTION

'=======================================================================
SUB caer_pieza_timer()

    tiempo = tiempo + 1

    IF (tiempo >= tiempo_cae_pieza_nivel(nivel) + ralentizacion) THEN
        abajo_auto = 1
        tiempo = 0
    ELSE
        abajo_auto = 0
    END IF

    IF (timer_show_bonus > 0) THEN timer_show_bonus = timer_show_bonus - 1
    IF (timer_show_bonus = 1) THEN dibuja_bonus_lines_same_time("borrar")

    ciclos = ciclos + 1
    IF ciclos >= 254 THEN ciclos = 0

END SUB

'=======================================================================
SUB dejar_rastro()

    DIM a AS Ubyte
    DIM x AS Byte
    DIM y AS Byte

    actualizar_punteros_sprites("pieza-bloque")

    FOR a = 0 TO 6 STEP 2
        y = piezas(pieza_actual + rotacion, a)
        x = piezas(pieza_actual + rotacion, a + 1)

        fondo(piezaY + y, piezaX + x) = INT(pieza_actual / 4) + 1

        PRINT AT piezaY + y, piezaX + x + OFF_SET_X; PAPER 0; INK COL_RASTRO_PIEZA; CHR$(144)
    NEXT a

END SUB

'=======================================================================
SUB cambio_pieza_manual_pruebas()

    DIM a As Ubyte
    DIM y As Byte
    DIM x As Byte

    IF (tecla = "9") THEN

        FOR a = 0 TO 6 STEP 2
            y = piezas(pieza_actual + rotacion, a)
            x = piezas(pieza_actual + rotacion, a + 1)
            PRINT AT piezaY + y, piezaX + x + OFF_SET_X; PAPER 0; INK 3; " "
        NEXT a

        pieza_actual = INT(RND * NRO_PIEZAS) * NRO_ROTACIONES
        BEEP 0.2, -9
    END IF

END SUB
