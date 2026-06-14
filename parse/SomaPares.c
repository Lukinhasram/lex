#include <stdio.h>

int main() {
    int soma = 0;
    for (int i = 0; i <= 10; i++) {
        if (i % 2 == 0) {
            soma = soma + i;
        }
    }
    printf("%d", soma);
    return 0;
}