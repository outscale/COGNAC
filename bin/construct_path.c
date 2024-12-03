#include <stdio.h>
#include <string.h>

int main(int ac, char **av)
{
	char buf[1024];
	int buf_i;
	char *componant_name = av[1];

	if (*componant_name == '/')
		++componant_name;
	char *brk = strchr(componant_name, '{');
	if (!brk) {
		printf("\tosc_str_append_string(&end_call, \"/api/v1/%s\");\n", componant_name);
		return 0;
	}

	*brk = 0;
	printf("\tosc_str_append_string(&end_call, \"/api/v1/%s\");\n", componant_name);

again:
	printf("\tosc_str_append_string(&end_call, args->");
	for (++brk; *brk != '}'; ++brk)
		putchar(*brk);
	puts(");");
	buf_i = 0;
	for (++brk; *brk; ++brk) {
		if (*brk == '{') {
			buf[buf_i] = 0;
			printf("\tosc_str_append_string(&end_call, \"%s\");\n", buf);
			goto again;
		}
		buf[buf_i++] = *brk;
	}
	if (buf_i) {
		buf[buf_i] = 0;
		printf("\tosc_str_append_string(&end_call, \"%s\");\n", buf);
	}
}
