#include <stdio.h>
#include <string.h>
#include "json.h"

int main(int ac, char **av)
{
	struct json_object *j_file = json_object_from_file(av[1]);

	struct json_object *compo;
	struct json_object *schema;
	int ret = 0;
	ret = json_object_object_get_ex(j_file, "components", &compo);
	if (!ret)
		return 1;
	json_object_object_get_ex(compo, "schemas", &schema);
	if (!ret)
		return 1;
	int first = 1;

	json_object_object_foreach(schema, k, v_) {
		char *new_k = strdup(k);
		char *resquest = strstr(new_k, "Request");
		if (resquest) {
			if (!first)
				putchar(' ');
			first = 0;
			*resquest = 0;
			printf("%s", new_k);
		}
		free(new_k);
	}
	json_object_put(j_file);
	return 0;
}
