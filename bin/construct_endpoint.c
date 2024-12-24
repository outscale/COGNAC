#include <stdio.h>
#include <string.h>


int main(int ac, char **av)
{
	int buf_i;
	char *componant_name = av[1];
	char *brk;
again:
	{
		brk = strchr(componant_name, '{');
		if (!brk) {
			printf("\tosc_str_append_string(&e->endpoint, \"%s\");\n", componant_name);
			return 0;
		}

		*brk = 0;
		printf("\tosc_str_append_string(&e->endpoint, \"%s\");\n", componant_name);

		printf("\tosc_str_append_string(&e->endpoint, e->");
		for (++brk; *brk != '}'; ++brk)
			putchar(*brk);
		puts(");");
		componant_name = brk + 1;
		goto again;
	}
	return 0;
}
