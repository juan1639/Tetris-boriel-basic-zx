'---------------------------------------------------------------------------
'---                                                                     ---
'---            T E T R 1 S  -  C L O N  en ZX Basic Boriel              ---
'---                                                                     ---
'---                 Programado por: Juan Eguia, 2026                    ---
'---                                                                     ---
'===========================================================================
'---  PROGRAMA PRINCIPAL                                                 ---
'---  Compilar:  zxbc -f tap -aB tetris.bas                              ---
'---                                                                     ---
'---  Modulos:                                                           ---
'---    datos.bas      constantes, arrays y variables                    ---
'---    tablero.bas    tablero, lineas, marcadores                       ---
'---    controles.bas  teclado                                           ---
'---    pieza.bas      movimiento, rotacion y colisiones de la pieza     ---
'---    sonido.bas     efectos y musicas                                 ---
'---    graficos.bas   UDG y punteros de graficos                        ---
'===========================================================================

#include "datos.bas"

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
'---                     M O D U L O S  (SUBs)                   ---
'---                                                             ---
'-------------------------------------------------------------------
#include "tablero.bas"
#include "controles.bas"
#include "pieza.bas"
#include "sonido.bas"
#include "graficos.bas"
