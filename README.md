# Printf
## Описание
Аналог функции printf стандартной библиотеки на x86-64 asm
## Компиляция и линковка
```bash
nasm -f elf64 nasm.s 
gcc main.o nasm.o -no-pie -o prog
```

## Использование
```c++
extern void _my_printf(const char* format, ...);
int main()
{
    _my_printf("printf %s %o", "working!", -19);
    return 0;
}
```
