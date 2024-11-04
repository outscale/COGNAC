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
