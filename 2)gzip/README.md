## Описание
Программа принимает 1 аргумент - имя выходного файла, на стандартный вход - байты sparse файла

## Гайд по запуску
1. gcc main.c
2. {input} | ./a.out {out-file_name} (например, gzip -cd test_file.txt.gz | ./a.out result.gz)