#include <ctype.h>
#include <stdio.h>

int main(int ac, char **av)
{
	const char *str = av[1];
	int first = 0;

	for (const char *c_ptr = str; *c_ptr; ++c_ptr) {
		char c = *c_ptr;
		if (c == '/' || c == '_') {
			first = 1;
			continue;
		}
		if (c == '{' || c == '}') {
			continue;
		}
		if (first) {
			putchar(toupper(c));
			first = 0;
		} else {
			putchar(c);
		}
	}
	putchar('\n');
}
