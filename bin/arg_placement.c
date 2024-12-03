#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "json.h"
#define UNFOUND "data"
#include "helper.h"

int main(int ac, char **av)
{
	struct json_object *j_file = json_object_from_file(av[1]);
	char *componant_name = av[2];
	char *arg_name = av[3];
	int ret;
	struct json_object *path;
	struct json_object *post_or_get;
	struct json_object *parameters;

	path = get_path_from_file(j_file, componant_name);
	post_or_get = get_or_post_from_path(path);
	if (!post_or_get)
		goto err;

	OBJ_GET(post_or_get, "parameters", &parameters);
	int len = json_object_array_length(parameters);
	for (int i = 0; i < len; ++i) {
		struct json_object *param = json_object_array_get_idx(parameters, i);
		struct json_object *name_obj;
		struct json_object *in;

		OBJ_GET(param, "name", &name_obj);
		const char *name = json_object_get_string(name_obj);
		struct json_object *type;
		struct json_object *schema;

		if (strcmp(name, arg_name))
			continue;
		OBJ_GET(param, "in", &in);
		puts(json_object_get_string(in));
		goto out;
	}
out:
err:
	json_object_put(j_file);
}
