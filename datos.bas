'===========================================================================
'---  TETR1S-Clon ZX Boriel  -  Modulo: datos.bas
'---  Constantes, arrays (tablero, piezas, colores, velocidades) y variables globales
'---  (se incluye desde tetris.bas con #include, no se compila suelto)
'===========================================================================

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
