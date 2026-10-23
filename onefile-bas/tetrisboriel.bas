'---------------------------------------------------------------------------
'---                                                                     ---
'---            T E T R 1 S  -  C L O N  en ZX Basic Boriel              ---
'---                                                                     ---
'---                 Programado por: Juan Eguia, 2026                    ---
'---                                                                     ---
'===========================================================================
'---                       C O N S T A N T E S                           ---
'---------------------------------------------------------------------------
CONST NRO_FILAS As Ubyte = 20
CONST NRO_COLUMNAS As Ubyte = 9

CONST OFF_SET_X As Ubyte = 2

CONST NRO_PIEZAS As Ubyte = 7
CONST NRO_ROTACIONES As Ubyte = 4

CONST PIEZA_POS_INICIAL_Y As Ubyte = 2
CONST PIEZA_POS_INICIAL_X As Ubyte = 5

CONST MARGEN_SCORES As Ubyte = 16
CONST COL_RASTRO_PIEZA As ubyte = 1

CONST BONUS_LINES_SAME_TIME_Y As Ubyte = 2
CONST BONUS_LINES_SAME_TIME_X As Ubyte = MARGEN_SCORES - 3

CONST SHOW_BONUS_DURATION As Ubyte = 99

' --- Velocidad (todo en FOTOGRAMAS: el Spectrum va a 50 fotogramas/seg) ---
' El bucle principal espera 1 fotograma por vuelta (HALT), asi la velocidad
' ya no depende de lo que tarde el codigo en ejecutarse.
CONST LATERAL_RETARDO_INICIAL As Ubyte = 12  ' al mantener O/P: espera antes de repetir
CONST LATERAL_REPETIR As Ubyte = 5           ' luego, 1 casilla cada N fotogramas
CONST ABAJO_REPETIR As Ubyte = 3             ' tecla A: 1 casilla cada N fotogramas

' --- Arranque suave ---
' Al empezar la partida se suman RALENTIZACION_INICIAL fotogramas extra a la
' caida. Cada PIEZAS_POR_PASO piezas colocadas se quita 1 fotograma, hasta
' llegar a la velocidad normal de la tabla (50 + 40 = 90 al principio).
CONST RALENTIZACION_INICIAL As Ubyte = 40
CONST PIEZAS_POR_PASO As Ubyte = 1

'===========================================================================
'---                        ARRAY (AREA DE JUEGO)
'---------------------------------------------------------------------------
DIM fondo(NRO_FILAS, NRO_COLUMNAS) As Ubyte => { _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}, _
{0,0,0,0,0,0,0,0,0,0}}

'===========================================================================
'---                        Relativo a la PIEZA
'---------------------------------------------------------------------------
DIM piezaY As Ubyte = PIEZA_POS_INICIAL_Y
DIM piezaX As Ubyte = PIEZA_POS_INICIAL_X
DIM rotacion As Ubyte = 0
DIM rotar_liberado As Ubyte = 0   ' 1 = la tecla de rotar se ha soltado (evita rotar sin parar)

'-----------------------------------------------------------------------
'---                      Resto de variables                         ---
'-----------------------------------------------------------------------
DIM a, b, c AS Byte
DIM ciclos AS Ubyte = 0
DIM gameover As Ubyte = 0
DIM salir AS Ubyte = 0
DIM rejugar As Ubyte = 0

DIM nivel As Ubyte = 1
DIM record AS Uinteger = 123
DIM score AS Uinteger = 0
DIM lines_same_time As UInteger = 0
DIM handicap As Ubyte = 0

DIM pieza_actual AS Ubyte = 0
DIM pieza_siguiente AS Ubyte = 0
DIM sortear_next_pieza AS Ubyte = 0
DIM timer_show_bonus As Ubyte = 0
DIM tiempo AS Ubyte = 0

DIM abajo_auto As Ubyte = 0
DIM control_abajo AS Ubyte = 0
DIM control_izquierda AS Ubyte = 0
DIM control_derecha AS Ubyte = 0
DIM control_rotar AS Ubyte = 0

DIM tecla As string

DIM lateral_dir As Ubyte = 0       ' 0 = nada, 1 = derecha, 2 = izquierda
DIM lateral_espera As Ubyte = 0    ' fotogramas hasta el siguiente paso lateral
DIM abajo_espera As Ubyte = 0      ' fotogramas hasta el siguiente paso abajo

DIM ralentizacion As Ubyte = RALENTIZACION_INICIAL  ' fotogramas extra de caida
DIM contador_piezas As Ubyte = 0

DIM flag_play_init_music As Ubyte = 0

DIM spritesPtr As UInteger = 0

'====================================================================================
'---                  A R R A Y  -  P I E Z A S  (Y ROTACIONES)                   ---
'------------------------------------------------------------------------------------
DIM piezas(27, 7) As Byte => { _
{0,0,0,-1,-1,-1,1,0}, _
{0,0,0,-1,-1,0,-1,1}, _
{0,0,0,-1,-1,-1,1,0}, _
{0,0,0,-1,-1,0,-1,1}, _
{0,0,0,-1,1,-1,-1,0}, _
{0,0,0,1,-1,-1,-1,0}, _
{0,0,0,-1,1,-1,-1,0}, _
{0,0,0,1,-1,-1,-1,0}, _
{0,0,0,-1,0,-2,1,0}, _
{0,0,-1,0,1,0,1,-1}, _
{0,0,0,-1,0,-2,-1,-2}, _
{0,0,0,-1,1,-1,2,-1}, _
{0,0,1,0,1,-1,1,-2}, _
{0,0,0,-1,-1,-1,-2,-1}, _
{0,0,0,-1,0,-2,1,-2}, _
{0,0,0,-1,1,0,2,0}, _
{0,0,0,-1,1,-1,1,0}, _
{0,0,0,-1,1,-1,1,0}, _
{0,0,0,-1,1,-1,1,0}, _
{0,0,0,-1,1,-1,1,0}, _
{0,0,-1,0,1,0,2,0}, _
{0,0,0,-1,0,-2,0,-3}, _
{0,0,-1,0,1,0,2,0}, _
{0,0,0,-1,0,-2,0,-3}, _
{0,0,0,-1,-1,0,1,0}, _
{0,0,0,-1,0,-2,-1,-1}, _
{0,0,-1,0,1,0,0,1}, _
{0,0,0,-1,0,-2,1,-1}}

'---------------------------------------------------------------
'-------------------   Colores bloques piezas  -----------------
'---------------------------------------------------------------
DIM colores_piezas(6, 1) As Ubyte => {{3, 2}, {6, 4}, {5, 1}, {6, 4}, {1, 5}, {5, 1}, {6, 4}}

'---------------------------------------------------------------
'-----------------   Array VEL-caer-piezas  --------------------
'---------------------------------------------------------------
' Fotogramas que tarda la pieza en bajar 1 casilla segun el nivel
' (50 = 1 segundo). Subir estos valores = juego mas lento.
DIM tiempo_cae_pieza_nivel(33) As Ubyte => { _
    50, 50, 45, 40, 36, 32, 29, 26, 23, 21, _
    19, 17, 15, 14, 13, 12, 11, 10,  9,  8, _
     8,  7,  7,  6,  6,  5,  5,  4,  4,  3, _
     3,  3,  2,  2}

'===============================================================
'-----------------   Declaracion de funciones   ----------------
'---------------------------------------------------------------
DECLARE FUNCTION check_colision_pieza() As Ubyte

'===============================================================
'--------                                               --------
'--------            INICIALIZACION GENERAL             --------
'--------                                               --------
'---------------------------------------------------------------
BORDER 0
PAPER 1
BRIGHT 1
INK 7

start_game:
CLS

rejugar = 0
salir = 0
gameover = 0
handicap = 0
ciclos = 0
nivel = 1
score = 0
sortear_next_pieza = 0
tiempo = 0
flag_play_init_music = 0
rotar_liberado = 0
timer_show_bonus = 0
lateral_dir = 0
abajo_espera = 0
ralentizacion = RALENTIZACION_INICIAL
contador_piezas = 0

reset_area_juego_fondo()

PRINT AT 2, 4; BRIGHT 1; PAPER 7;  INK 2; " TETR1S-Clon ZX Boriel "
PRINT AT 1, 4; BRIGHT 1; PAPER 7;  INK 2; "                       "
PRINT AT 3, 4; BRIGHT 1; PAPER 7;  INK 2; "                       "
PRINT AT 5, 4; PAPER 6; INK 4; "    SELECT GAME TYPE:  "
PRINT AT 6, 4; PAPER 6; INK 1; " 1. Normal (selected)  "
PRINT AT 7, 4; PAPER 6; INK 1; " 2. Handicap           "
PRINT AT 10, 8; INK 5; " O .... Left "
PRINT AT 12, 8; INK 5; " P .... Right "
PRINT AT 14, 8; INK 5; " A .... Down "
PRINT AT 16, 8; INK 5; " Spc .. Rotate "
PRINT AT 19, 1; INK 4; "Programmed by Juan Eguia, 2026"
PRINT AT 21, 6; FLASH 1; INK 7; " Space bar to play "

'============================================================
'--------                                            --------
'--------        B U C L E   P R E J U E G O         --------
'--------                                            --------
'============================================================
DO
    tecla = ""
    tecla = INKEY$

    IF (tecla = "2") THEN
        handicap = 1
        PRINT AT 6, 4; PAPER 6; INK 1; " 1. Normal             "
        PRINT AT 7, 4; PAPER 6; INK 1; " 2. Handicap (selected)"
        sonidoAscend(-20, -2, 1)
    ELSE IF (tecla = "1") THEN
        handicap = 0
        PRINT AT 6, 4; PAPER 6; INK 1; " 1. Normal (selected)  "
        PRINT AT 7, 4; PAPER 6; INK 1; " 2. Handicap           "
        sonidoAscend(-20, -2, 1)
    END IF

LOOP UNTIL tecla = CHR$(32)

CLS
dibuja_ui()

'============================================================
'--------               SORTEAR PIEZA                --------
'------------------------------------------------------------
pieza_siguiente = INT(RND * NRO_PIEZAS) * NRO_ROTACIONES

DO
    check_lineas_hechas()

    pieza_actual = pieza_siguiente
    pieza_siguiente = INT(RND * NRO_PIEZAS) * NRO_ROTACIONES
    sortear_next_pieza = 0

    ' Arranque suave: con cada pieza colocada se reduce la ralentizacion
    IF (flag_play_init_music > 0 AND ralentizacion > 0) THEN
        contador_piezas = contador_piezas + 1
        IF (contador_piezas >= PIEZAS_POR_PASO) THEN
            contador_piezas = 0
            ralentizacion = ralentizacion - 1
        END IF
    END IF

    IF (flag_play_init_music = 0) THEN set_handicap_game()

    dibuja_fondo()
    mostrar_marcadores()
    dibuja_next_pieza()
    
    IF (flag_play_init_music = 0) THEN
        flag_play_init_music = 1
        PRINT AT 12, 3; PAPER 0; INK 7; " Ready! "
        musics("tetris", 1)
        PRINT AT 12, 3; PAPER 0; INK 7; "        "
    END IF

    piezaY = PIEZA_POS_INICIAL_Y
    piezaX = PIEZA_POS_INICIAL_X
    rotacion = 0
    tiempo = 0

    ' Si la pieza nueva ya no cabe -> Game Over; si cabe, se dibuja
    IF (check_colision_pieza() > 0) THEN
        gameover = 1
    ELSE
        dibujar_pieza()
    END IF

    '============================================================
    '--------                                            --------
    '--------      B U C L E   P R I N C I P A L         --------
    '--------                                            --------
    '============================================================
    IF (gameover = 0) THEN
        DO
            tecla = ""
            tecla = INKEY$

            ' Esperar al siguiente fotograma (1/50 seg): marca el ritmo del juego
            Asm
                halt
            End Asm

            caer_pieza_timer()
            leer_teclado_controles()
            'cambio_pieza_manual_pruebas()
            logica_pieza()

        LOOP UNTIL gameover > 0 OR salir > 0 OR sortear_next_pieza > 0 OR tecla = CHR$(13)
    END IF

LOOP UNTIL salir > 0 OR gameover > 0 OR tecla = CHR$(13)

'============================================================
'--------      B U C L E   G A M E  O V E R          --------
'============================================================
dibuja_fondo()
mostrar_marcadores()

PRINT AT 10, 1; PAPER 0; INK 2; "            "
PRINT AT 11, 1; PAPER 0; INK 2; " Game  Over "
PRINT AT 12, 1; PAPER 0; INK 2; "            "

musics("game-over", 1)

IF (score > record) THEN
    PRINT AT 21, 5; FLASH 1; PAPER 0; INK 4; " Congrats! New Record! "
    record = score
    musics("fanfarria-victoria", 1)
END IF

PRINT AT 16, 5; PAPER 0; INK 7; "                     "
PRINT AT 17, 5; PAPER 0; INK 7; " ENTER -> Play again "
PRINT AT 18, 5; PAPER 0; INK 7; "                     "

'-------------------------------------------------------
DO
    tecla = ""
    tecla = INKEY$

    IF (tecla = CHR$(13)) THEN rejugar = 1

    

    ciclos = ciclos + 1
    IF ciclos >= 254 THEN ciclos = 0

LOOP UNTIL salir > 0 OR tecla = CHR$(13)

IF (rejugar > 0) THEN GOTO start_game

'===================================================================
'---                   F I N   P R O G R A M A                   ---
'===================================================================
'salir
PAUSE 0
STOP

'===================================================================
'---                                                             ---
'---                          S U B S                            ---
'---                                                             ---
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

'===================================================================
SUB leer_teclado_controles()

    control_abajo = 0
    control_derecha = 0
    control_izquierda = 0
    control_rotar = 0

    ' Rotar solo al PULSAR (flanco): hay que soltar Espacio para volver a rotar
    If (In($7FFE) & 1) = 0 Then
        If (rotar_liberado > 0) Then
            rotar_liberado = 0
            control_rotar = 1
            RETURN
        End If
    Else
        rotar_liberado = 1
    End If

    ' 3. LEER FILA DE TECLAS: A, S, D, F, G  (Puerto $FDFE)
    ' Si el bit 0 del puerto está a 0, significa que se pulsa la 'A'
    ' Baja 1 casilla al pulsar y luego 1 cada ABAJO_REPETIR fotogramas.
    If (In($FDFE) & 1) = 0 Then
        If (abajo_espera = 0) Then
            control_abajo = 1
            abajo_espera = ABAJO_REPETIR
        End If
        abajo_espera = abajo_espera - 1
        lateral_dir = 0
        RETURN
    Else
        abajo_espera = 0
    End If

    ' 4. LEER FILA DE TECLAS: P, O, I, U, Y  (Puerto $DFFE)
    ' Si el bit 0 del puerto está a 0, se pulsa 'P' (Derecha)
    ' Si el bit 1 del puerto está a 0, se pulsa 'O' (Izquierda)
    ' Al pulsar se mueve 1 casilla; si se mantiene, espera
    ' LATERAL_RETARDO_INICIAL y despues repite cada LATERAL_REPETIR.
    DIM dir As Ubyte = 0
    If (In($DFFE) & 1) = 0 Then
        dir = 1
    ElseIf (In($DFFE) & 2) = 0 Then
        dir = 2
    End If

    If (dir = 0) Then
        lateral_dir = 0
        RETURN
    End If

    If (dir <> lateral_dir) Then
        ' Pulsacion nueva: mover ya
        lateral_dir = dir
        lateral_espera = LATERAL_RETARDO_INICIAL
    Else
        lateral_espera = lateral_espera - 1
        If (lateral_espera > 0) Then RETURN
        lateral_espera = LATERAL_REPETIR
    End If

    If (dir = 1) Then
        control_derecha = 1
    Else
        control_izquierda = 1
    End If

END SUB

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

'============================================================================
' S P R I T E S  (dibujados con SevenuP y exportados a bytes asm)
'----------------------------------------------------------------------------
Asm
    _pieza_bloque:
        DEFB	  0,126,126,126,126,126,126,  0
	    DEFB	128,192,224,240,248,252,254,255
End Asm

