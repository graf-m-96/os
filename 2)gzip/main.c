#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>


int main(int argc, char* argv[]) {
    if (argc != 2) {
        printf("Программа на вход принимает 1 аргумент - имя обрабатываемого файла\n");

        return -1;
    }
    FILE* fileStream = fopen(argv[1], "w");
    int ord;
    int zeroCount = 0;
    while ((ord = getchar()) != EOF) {
        if (ord == 0) {
            zeroCount++;
        } else {
            if (zeroCount != 0) {
                fseek(fileStream, zeroCount, 1);
            }
            fwrite(&ord, 1, 1, fileStream);
            zeroCount = 0;
        }
    }

    return 0;
}
