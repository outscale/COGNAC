#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "json.h"
#include "helper.h"

int main(int ac, char **av)
{
	char *componant_name;
	struct json_object *j_file = NULL;
	char *arg_name;
	int func_ret = 1;
	int ret;
	struct json_object *path;
	struct json_object *post_or_get;
	struct json_object *parameters;

	if (av[1][0] == '{') {
		j_file = json_tokener_parse(av[1]);
		path = j_file;
		arg_name = av[2];
	} else {
		j_file = json_object_from_file(av[1]);
		componant_name = av[2];
		arg_name = av[3];
		if (!strchr(componant_name, '/')) {
			puts(componant_name);
			goto err;
		}
		path = get_path_from_file(j_file, componant_name);
	}


	post_or_get = get_or_post_from_path(path);
	if (!post_or_get)
		goto err;
	OBJ_GET(post_or_get, "parameters", &parameters);
	int len = json_object_array_length(parameters);
	for (int i = 0; i < len; ++i) {
		struct json_object *param = json_object_array_get_idx(parameters, i);
		struct json_object *name_obj;

		OBJ_GET(param, "name", &name_obj);
		const char *name = json_object_get_string(name_obj);
		struct json_object *type;
		struct json_object *schema;

		if (strcmp(name, arg_name))
			continue;
		OBJ_GET(param, "schema", &schema);
		ret = json_object_object_get_ex(schema, "type", &type);
		if (!ret) {
			struct json_object *anyof_or_oneof = oneof_or_anyof(schema);

			if (!anyof_or_oneof)
				goto err;
			anyof_or_oneof = json_object_array_get_idx(anyof_or_oneof, 0);
			OBJ_GET(anyof_or_oneof, "type", &type);
		}
		puts(json_object_get_string(type));
		func_ret = 0;
		goto err;
	}
	componant_name = componant_name_from_get_or_post(post_or_get);
	if (!componant_name)
		goto err;
	puts(componant_name);
	func_ret = 0;

err:
	json_object_put(j_file);
	return func_ret;
}
