# funclist

usage:
```
./funclist api.json
```

Look in an OpenAPI JSON file for the list of functions. To do this, identify which objects in components.schemas end with 'Request'. Each function call is separated by a space.

# line_check

usage:
```
./line_check "test_keywork" "this_arg" <<< "there is this_arg in this line"
```

Will return "this_arg".

This utility was created to avoid calling grep for each keyword we need to check. With this utility, we can pass all our keywords to line_check and then switch based on which keyword was found.

This is also much faster than multiple calls to grep.

# osc-api-seems-valid.sh

This utility is used to check if osc-api.json has been generated correctly. It verifies that the file is a valid JSON and contains at least one API function.

# path_to_snakecase
Converts an object name to snake_case.
example `ReadVms` becomes `read_vms`
`/my/{NAME}/getId` becomes `my_name_get_id`

usage:
```
./path_to_snakecase STRING
```

# path_to_camelcase
Converts an object name to camelCase.
example `read_vms` become `ReadVms`
`/my/{NAME}/getId` become `myNameGetId`

usage:
```
./path_to_camelcase STRING
```

# get_argument_list


Retrieves an object component from `paths` or `components.schema` and returns a list of all its arguments.

usage:
```
./get_argument_list file.json componant_name
```

# get_path_type

usage:
```
./bin/get_path_type osc-api.json PATH ARGUMENT_NAME
```

example:

```
$ ./bin/get_path_type osc-api.json /projects id
int
```

assuming id is of type int

or

usage:
```
./bin/get_path_type JSON_ELEM ARGUMENT_NAME
```

example:
```
$ ./bin/get_path_type '{"post": {"parameters": [ {"name": "a", "type": "string"} ]}}' "a"
string

```

# get_path_description


Returns an empty string "" for now, as the API I tested this with had no description in the path.

usage:
```
./get_path_description JSON_ELEM ARG
```

example:
```
./get_path_description "{...}" argument_named_titi
```

# arg_placement

Return where the argument is used:
`path`: If the argument is used in the URL path.
`header`: If the argument is used as an HTTP header.
`query`: If the argument is in a query string.
`data`: If the argument is used in POST data.

usage:
```
./arg_placement osc-api.json PATH ARGUMENT_NAME
```

example:
```
$ ./arg_placement osc-api.json /projects id
query
```

# construct_path

Generate the C code to create an osc_str for the path of the call.

example:

```
$ ./construct_path /project/{id}/get

osc_str_append_string(&end_call, "/project/");
osc_str_append_string(&end_call, args->id);
osc_str_append_string(&end_call, "/get");
```

The generated code is not exhaustive, but it conveys the general idea.
