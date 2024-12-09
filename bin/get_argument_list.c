#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "helper.h"
#include "json.h"

int main(int ac, char **av)
{
	struct json_object *j_file = json_object_from_file(av[1]);
	char *componant_name = av[2];
	char *option = ac > 2 ? av[3] : NULL;
	int func_ret = 1;
	int only_require = 0;
	int ret;

	if (option && !strcmp(option, "--require"))
		only_require = 1;

	/* if / is found, assume in path */
	if (strchr(componant_name, '/')) {
		int ret = 0;
		struct json_object *func;
		struct json_object *parameters;
		struct json_object *post_or_get;
		int len;

		func = get_path_from_file(j_file, componant_name);
		post_or_get = get_or_post_from_path(func);
		if (!post_or_get)
			goto err;
		ret = json_object_object_get_ex(func, "post", &post_or_get);
		if (!ret) {
			OBJ_GET(func, "get", &post_or_get);
		}
		OBJ_GET(post_or_get, "parameters", &parameters);
		len = json_object_array_length(parameters);
		for (int i = 0; i < len; ++i) {
			struct json_object *name;
			struct json_object *param = json_object_array_get_idx(parameters, i);

			if (only_require) {
				struct json_object *required;
				json_object_object_get_ex(param, "required", &required);
				if (!required || !json_object_get_boolean(required)) {
					continue;
				}
			}
			OBJ_GET(param, "name", &name);
			printf(" %s" + !i, json_object_get_string(name));
		}
		componant_name = componant_name_from_get_or_post(post_or_get);
		if (!componant_name)
			goto out;
		putchar(' ');
		goto in_schema;
	} else {
		struct json_object *compo;
		struct json_object *schema;
		struct json_object *func;
		struct json_object *properties;

	in_schema:
		int i = 0;

		OBJ_GET(j_file, "components", &compo);
		OBJ_GET(compo, "schemas", &schema);
		OBJ_GET(schema, componant_name, &func);
		if (only_require) {
			OBJ_GET(func, "required", &properties);

			int len = json_object_array_length(properties);
			for (int i = 0; i < len; ++i) {
				const char *str = json_object_get_string(json_object_array_get_idx(properties, i));
				printf(" %s" + !i, str);
			}
		} else {
			OBJ_GET(func, "properties", &properties);
			json_object_object_foreach(properties, k, v_) {
				printf(" %s" + !i++, k);
			}
		}
	}
out:
	putchar('\n');
	func_ret = 0;
err:
	json_object_put(j_file);
	return func_ret;

}
