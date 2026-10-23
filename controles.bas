'===========================================================================
'---  TETR1S-Clon ZX Boriel  -  Modulo: controles.bas
'---  Lectura del teclado (puertos) con autorepeticion lateral y rotacion por pulsacion
'---  (se incluye desde tetris.bas con #include, no se compila suelto)
'===========================================================================

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
