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

    ret
frobenius_distance ENDP

END