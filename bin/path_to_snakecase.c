#include <ctype.h>
#include <stdio.h>

/**
 * reset first to 1, so 'my/Func' give my_func, and not
 * my__func
 */
#define PUT_UNDERSCORE() do {			\
		putchar('_');			\
		first = 1;			\
	} while (0)

int main(int ac, char **av)
{
	const char *str = av[1];
	int first = 1;

	for (const char *c_ptr = str; *c_ptr; ++c_ptr) {
		char c = *c_ptr;

		if (c_ptr == str && c == '/') {
			continue;
		}
		if (c == '{' || c == '}') {
			continue;
		}
		if (c == '/') {
			PUT_UNDERSCORE();
		} else if (isupper(c)) {
			if (!first) {
				PUT_UNDERSCORE();
			}
			putchar(tolower(c));
		} else {
			putchar(c);
			first = 0;
		}
	}
	putchar('\n');
}
