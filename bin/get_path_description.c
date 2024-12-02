#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "json.h"
#include "helper.h"

/* lot of commented code here, left here if I need better description */
int main(int ac, char **av)
{
	char *element = av[1];
	char *arg = av[2];
	int ret;
	int func_ret = 1;
	struct json_object *j_elem = json_tokener_parse(element);
	struct json_object *post_or_get;
	#if 0
	struct json_object *parameters;
	struct json_object *name_obj;
	#endif

	//printf("element: %s\n", element);

	post_or_get = get_or_post_from_path(j_elem);
	if (!post_or_get)
		goto err;

	printf("\"\"\n");
	func_ret = 0;
	goto out;

	#if 0
	OBJ_GET(post_or_get, "parameters", &parameters);
	int len = json_object_array_length(parameters);
	for (int i = 0; i < len; ++i) {
		struct json_object *param = json_object_array_get_idx(parameters, i);
		struct json_object *type;
		struct json_object *schema;
		const char *name;

		OBJ_GET(param, "name", &name_obj);
		name = json_object_get_string(name_obj);

		if (strcmp(name, arg))
			continue;
		func_ret = 0;
		OBJ_GET(param, "schema", &schema);
		ret = json_object_object_get_ex(schema, "type", &type);
		if (!ret) {
			struct json_object *anyof_or_oneof = oneof_or_anyof(schema);

			if (!anyof_or_oneof)
				goto err;
			anyof_or_oneof = json_object_array_get_idx(anyof_or_oneof, 0);
			OBJ_GET(anyof_or_oneof, "type", &type);
		}
		putchar('"');
		printf("%s", json_object_get_string(type));
		putchar('"');
		putchar('\n');
	}
	#endif
out:
err:
	json_object_put(j_elem);
	return func_ret;
}
