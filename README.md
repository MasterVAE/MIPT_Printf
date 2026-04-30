# Printf
## Описание
Аналог функции printf стандартной библиотеки на x86-64 asm
## Использование
'''c
extern void _my_printf(const char* format, ...);
int main()
{
    _my_printf("printf %s %o", "working!", -19);
    return 0;
}
'''
