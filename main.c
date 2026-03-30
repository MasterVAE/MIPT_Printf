extern void _my_printf(const char* format, ...);


int main()
{
    _my_printf("%o\n%d %s %x %d%%%c%b\n%d %s %x %d%%%c%b\n", -1, -1, "love", 3802, 100, 33, 127, -1, 
                                                                        "love", 3802, 100, 33, 127);

    return 0;
}
