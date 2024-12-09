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


char *componant_name_from_get_or_post(struct json_object *post_or_get)
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

struct json_object *oneof_or_anyof(struct json_object *param)
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


struct json_object *get_or_post_from_path(struct json_object *path)
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

struct json_object *get_path_from_file(struct json_object *j_file, char *path)
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

#endif
