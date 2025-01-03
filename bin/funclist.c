#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "json.h"

int main(int ac, char **av)
{
	bool funclist_from_path = 0;
	struct json_object *j_file = NULL;

	char *suffix = "Request";
	int ret = 0;
	int func_ret = 1;
	int first = 1;
	int i;

	for (i = 1; i < ac; ++i) {
		if (!strcmp(av[i], "--func-suffix")) {
			++i;
			if (i == ac) {
				printf("usage: %s --func-suffix SUFFIX", av[0]);
				return 1;
			}
			suffix = av[i];
		} else if (!j_file) {
			j_file = json_object_from_file(av[1]);
		} else {
			funclist_from_path = 1;
		}
	}

	if (!funclist_from_path) {
		struct json_object *compo;
		struct json_object *schema;

		ret = json_object_object_get_ex(j_file, "components", &compo);
		if (!ret)
			goto err;
		json_object_object_get_ex(compo, "schemas", &schema);
		if (!ret)
			goto err;

		json_object_object_foreach(schema, k, v_) {
			char *new_k = strdup(k);
			char *resquest = strstr(new_k, suffix);

			if (resquest) {
				if (!first)
					putchar(' ');
				first = 0;
				*resquest = 0;
				printf("%s", new_k);
			}
			free(new_k);
		}
	} else {
		struct json_object *paths;

		ret = json_object_object_get_ex(j_file, "paths", &paths);
		if (!ret)
			goto err;

		json_object_object_foreach(paths, k, v_) {
			if (!first)
				putchar(' ');
			first = 0;
			printf("%s", k);
		}
	}

	func_ret = 0;
err:
	json_object_put(j_file);
	return func_ret;
}
