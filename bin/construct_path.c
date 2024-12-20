#include <stdio.h>
#include <string.h>

int main(int ac, char **av)
{
	char *componant_name = av[1];
	char *path_begin = ac > 2 ? av[2] : "";

	if (*componant_name == '/')
		++componant_name;

	char *brk = strchr(componant_name, '{');
	if (!brk) {
		printf("\tosc_str_append_string(&end_call, \"%s/%s\");\n", path_begin, componant_name);
		return 0;
	}

	*brk = 0;
	printf("\tosc_str_append_string(&end_call, \"%s/%s\");\n", path_begin, componant_name);

again:
	printf("\tosc_str_append_string(&end_call, args->");
	for (++brk; *brk != '}'; ++brk)
		putchar(*brk);
	puts(");");
	componant_name = brk + 1;
	brk = strchr(componant_name, '{');
	if (brk)
		*brk = 0;
	if (*componant_name)
		printf("\tosc_str_append_string(&end_call, \"%s\");\n", componant_name);
	if (brk)
		goto again;
}
