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
snakecasise an object name.
example `ReadVms` become `read_vms`
`/my/{NAME}/getId` become `my_name_get_id`

usage:
```
./path_to_snakecase STRING
```

# path_to_camelcase
camelcasise an object name.
example `ReadVms` become `read_vms`
`/my/{NAME}/getId` become `my_name_get_id`

usage:
```
./path_to_camelcase STRING
```

# get_argument_list

Take an object componant in `paths` or in `components.schema`, and give a list of all it arguments.

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

Just return "" so far, as the api I test this with, had no description in the path

usage:
```
./get_path_description JSON_ELEM ARG
```

example:
```
./get_path_description "{...}" argument_named_titi
```

# arg_placement

return where the argument is used.
`path`, if the argument is use in the path
`header` if it is an http header
`query` if it is in a query string
`data` if it is use in post data


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

generate the C code to create a osc_str that the path of the call.

example:

```
$ ./construct_path /project/{id}/get

osc_str_append_string(&end_call, "/project/");
osc_str_append_string(&end_call, args->id);
osc_str_append_string(&end_call, "/get");
```

The code generated is not exhaustive, but you get the idea.
