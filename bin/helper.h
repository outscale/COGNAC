#ifndef HELPER_H__
#define HELPER_H__

#include "json.h"

#ifndef UNFOUND
#define UNFOUND "null"
#endif

#define OBJ_GET(src, name, dst)	do {					\
		ret = json_object_object_get_ex(src, name, dst);	\
		if (!ret) {						\
			puts(UNFOUND);					\
			goto err;					\
		}							\
	} while (0)							\


static char *componant_name_from_get_or_post(struct json_object *post_or_get)
{
	char *componant_name;
	struct json_object *request_body;

	int ret = json_object_object_get_ex(post_or_get, "requestBody", &request_body);
	if (!ret)
		return NULL;

	struct json_object *content;
	struct json_object *application_json;
	struct json_object *schema;
	struct json_object *ref;

	OBJ_GET(request_body, "content", &content);
	OBJ_GET(content, "application/json", &application_json);
	OBJ_GET(application_json, "schema", &schema);
	ret = json_object_object_get_ex(schema, "$ref", &ref);
	if (!ref)
		return NULL;
	componant_name = strrchr(json_object_get_string(ref), '/');
	if (!componant_name)
		return NULL;;
	++componant_name;

	return componant_name;
err:
	return NULL;
}

static struct json_object *oneof_or_anyof(struct json_object *param)
{
	struct json_object *anyof_or_oneof;
	int ret;

	if (!param)
		goto err;
	ret = json_object_object_get_ex(param, "anyOf", &anyof_or_oneof);

	if (!ret) {
		OBJ_GET(param, "oneOf", &anyof_or_oneof);
	}
	return anyof_or_oneof;
err:
	return NULL;
}


static struct json_object *get_or_post_from_path(struct json_object *path)
{
	struct json_object *post_or_get;
	int ret;

	if (!path)
		goto err;
	ret = json_object_object_get_ex(path, "post", &post_or_get);

	if (!ret) {
		OBJ_GET(path, "get", &post_or_get);
	}
	return post_or_get;
err:
	return NULL;
}

static struct json_object *get_path_from_file(struct json_object *j_file, char *path)
{
	struct json_object *paths;
	struct json_object *func;
	int ret;

	OBJ_GET(j_file, "paths", &paths);
	OBJ_GET(paths, path, &func);

	return func;
err:
	return NULL;
}

static struct json_object *try_get_ref(struct json_object *in, struct json_object *param)
{
	int ret;
	struct json_object *ref = NULL;
	struct json_object *json_ret = NULL;

	ret = json_object_object_get_ex(param, "$ref", &ref);
	if (!ret)
		return param;
	const char *ref_str = json_object_get_string(ref);

	ref_str = strchr(ref_str, '/');
	if (!ref_str || !*ref_str) {
		return NULL;
	}
	param = in;
	++ref_str;
	char *cpy = strdup(ref_str);
	ref_str = cpy;

	char *ref_str_2;

again:

	ref_str_2 = strchr(ref_str, '/');
	if (ref_str_2) {
		*ref_str_2 = 0;
	}
	ret = json_object_object_get_ex(param, ref_str, &param);
	if (!ret)
		goto err;
	if (ref_str_2) {
		ref_str = ref_str_2 + 1;
		goto again;
	}
	json_ret = param;
err:
	free(cpy);
	return json_ret;
}

#endif
