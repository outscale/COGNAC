#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "json.h"

#define OBJ_GET(src, name, dst)	do {					\
		ret = json_object_object_get_ex(src, name, dst);	\
		if (!ret) {						\
			puts("null");					\
			goto err;					\
		}							\
	} while (0)							\

int main(int ac, char **av)
{
	struct json_object *j_file = json_object_from_file(av[1]);
	char *componant_name = av[2];
	int func_ret = 1;
	int ret;

	/* if / is found, assume in path */
	if (strchr(componant_name, '/')) {
		int ret = 0;
		struct json_object *paths;
		struct json_object *func;
		struct json_object *parameters;
		struct json_object *post_or_get;
		int len;

		OBJ_GET(j_file, "paths", &paths);
		OBJ_GET(paths, componant_name, &func);
		ret = json_object_object_get_ex(func, "post", &post_or_get);
		if (!ret) {
			OBJ_GET(func, "get", &post_or_get);
		}
		OBJ_GET(post_or_get, "parameters", &parameters);
		len = json_object_array_length(parameters);
		for (int i = 0; i < len; ++i) {
			struct json_object *name;

			OBJ_GET(json_object_array_get_idx(parameters, i),
				"name", &name);
			printf(" %s" + !i, json_object_get_string(name));
		}
	} else {
		struct json_object *compo;
		struct json_object *schema;
		struct json_object *func;
		struct json_object *properties;
		int i = 0;

		OBJ_GET(j_file, "components", &compo);
		OBJ_GET(compo, "schemas", &schema);
		OBJ_GET(schema, componant_name, &func);
		OBJ_GET(func, "properties", &properties);
		json_object_object_foreach(properties, k, v_) {
			printf(" %s" + !i++, k);
		}
	}
	putchar('\n');
	func_ret = 0;
err:
	json_object_put(j_file);
	return func_ret;

}
