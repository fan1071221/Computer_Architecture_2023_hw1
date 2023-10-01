#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct {
    uint64_t value;
    uint16_t leading_zeros;
} Number;

int compare(const void *a, const void *b) {
    return ((Number *)a)->leading_zeros - ((Number *)b)->leading_zeros;
}

void count_leading_zeros_and_sort(Number *numbers, int size) {
    for(int i = 0; i < size; i++) {
        uint64_t x = numbers[i].value;
        x |= (x >> 1);
        x |= (x >> 2);
        x |= (x >> 4);
        x |= (x >> 8);
        x |= (x >> 16);
        x |= (x >> 32);

        x -= ((x >> 1) & 0x5555555555555555 );
        x = ((x >> 2) & 0x3333333333333333) + (x & 0x3333333333333333);
        x = ((x >> 4) + x) & 0x0f0f0f0f0f0f0f0f;
        x += (x >> 8);
        x += (x >> 16);
        x += (x >> 32);

        numbers[i].leading_zeros = (64 - (x & 0x7f));
    }
    
    qsort(numbers, size, sizeof(Number), compare);
}

int main() {
    uint64_t array[] = {16, 33, 1, 0, 8};
    int size = sizeof(array) / sizeof(array[0]);
    Number *numbers = (Number *)malloc(size * sizeof(Number));

    for(int i = 0; i < size; i++) {
        numbers[i].value = array[i];
    }

    count_leading_zeros_and_sort(numbers, size);

    printf("Sorted array based on leading zeros:\n");
    for(int i = 0; i < size; i++) {
        printf("Value: %llu, Leading zeros: %u\n", numbers[i].value, numbers[i].leading_zeros);
    }

    free(numbers);
    return 0;
}
