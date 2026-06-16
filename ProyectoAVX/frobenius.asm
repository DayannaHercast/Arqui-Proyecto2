.data
    ; Máscara para valor absoluto en double (64 bits):
    ; Se pone el bit de signo en 0 y el resto en 1.
    ; 7FFFFFFFFFFFFFFFh = 0 111...111 en binario (64 bits)
    sign_mask  DQ 07FFFFFFFFFFFFFFFh, 07FFFFFFFFFFFFFFFh, \
                  07FFFFFFFFFFFFFFFh, 07FFFFFFFFFFFFFFFh

.code

; Función: frobenius_distance
; Calcula d(A,B) = ||A - B||_F
; Parámetros (convención Windows x64):
;   rcx = dirección de inicio de A 
;   rdx = dirección de inicio de B 


frobenius_distance PROC

    ;Cargar matriz A en registros YMM
    ; rcx apunta al inicio de A, avanzamos de 32 en 32
    vmovapd ymm0, YMMWORD PTR [rcx]        ; A[0][0], A[0][1], A[0][2], A[1][0]
    vmovapd ymm1, YMMWORD PTR [rcx + 32]   ; A[1][1], A[1][2], A[2][0], A[2][1]
    vmovapd ymm2, YMMWORD PTR [rcx + 64]   ; A[2][2], 0.0,     0.0,     0.0

    ;Cargar matriz B en registros YMM
    vmovapd ymm3, YMMWORD PTR [rdx]        ; B[0][0], B[0][1], B[0][2], B[1][0]
    vmovapd ymm4, YMMWORD PTR [rdx + 32]   ; B[1][1], B[1][2], B[2][0], B[2][1]
    vmovapd ymm5, YMMWORD PTR [rdx + 64]   ; B[2][2], 0.0,     0.0,     0.0

    ;Resta matricial C = A - B 
    vsubpd ymm6, ymm0, ymm3    ; C[0..3]  = A[0..3]  - B[0..3]
    vsubpd ymm7, ymm1, ymm4    ; C[4..7]  = A[4..7]  - B[4..7]
    vsubpd ymm8, ymm2, ymm5    ; C[8..11] = A[8..11] - B[8..11]

    
    ; Valor absoluto con AND
    vmovapd ymm15, YMMWORD PTR [sign_mask] ; Cargar máscara de signo
 
    vandpd ymm6, ymm6, ymm15   ; |C[0..3]|
    vandpd ymm7, ymm7, ymm15   ; |C[4..7]|
    vandpd ymm8, ymm8, ymm15   ; |C[8..11]|


    ; Suma de cuadrados con vmulpd + suma acumulada, cada elemento se eleva al cuadrado y luego se suman todos.

    ; Elevar al cuadrado cada grupo (multiplicar cada elemento por sí mismo)
    vmulpd ymm6, ymm6, ymm6    ; C[0..3]^2
    vmulpd ymm7, ymm7, ymm7    ; C[4..7]^2
    vmulpd ymm8, ymm8, ymm8    ; C[8..11]^2
 
    ; Sumar los tres grupos en ymm6
    vaddpd ymm6, ymm6, ymm7    ; ymm6 = C[0..3]^2 + C[4..7]^2
    vaddpd ymm6, ymm6, ymm8    ; ymm6 = suma de los 12 elementos^2
 
    ; Reducción horizontal: sumar los 4 doubles dentro de ymm6
    ; ymm6 = [d0, d1, d2, d3]
    ; Extraer la mitad alta (d2, d3) a xmm9
    vextractf128 xmm9, ymm6, 1         ; xmm9 = [d2, d3]
    vaddpd xmm6, xmm6, xmm9            ; xmm6 = [d0+d2, d1+d3]
    vhaddpd xmm6, xmm6, xmm6           ; xmm6 = [d0+d1+d2+d3, ...]


    ; Raíz cuadrada y retorno del resultado
    ; Se usa vsqrtsd para calcular sqrt sobre un solo double.
 
    vsqrtsd xmm0, xmm6, xmm6   ; xmm0 = sqrt(suma de cuadrados)

    ret
frobenius_distance ENDP

END