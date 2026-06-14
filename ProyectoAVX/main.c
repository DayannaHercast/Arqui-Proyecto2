#include <stdio.h>
#include <string.h>

extern double frobenius_distance(double* A, double* B);

int main(void) {
	// Alineación de matrices
    __declspec(align(32)) double A[12];
    __declspec(align(32)) double B[12];

	// Inicializar matrices con ceros
    memset(A, 0, sizeof(A));
    memset(B, 0, sizeof(B));


    printf("=== Distancia de Frobenius – Proyecto 2 IC-3101 ===\n");

    printf("\nIngrese los valores de la matriz A (fila por fila):\n");
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++) {
            printf("  A[%d][%d]: ", i, j);
            scanf_s("%lf", &A[i * 3 + j]);
        }

    printf("\nIngrese los valores de la matriz B (fila por fila):\n");
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++) {
            printf("  B[%d][%d]: ", i, j);
            scanf_s("%lf", &B[i * 3 + j]);
        }

	//Llamada a la función de distancia de Frobenius
    double resultado = frobenius_distance(A, B);

    printf("\nd(A, B) = ||A - B||_F = %.3f\n", resultado);

    return 0;

}