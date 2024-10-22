#!/usr/bin/env bash

shopt -s expand_aliases

func=$1

source ./helper.sh

if [[ "complex_struct" == "$2" ]]; then
    base=$(jq .components.schemas.$func < osc-api.json)
    args=$(json-search -Kn properties  <<< $base | tr -d '",[]')
    alias get_type=get_type2
else
    base=$(json-search ${func}Request < osc-api.json)
    args=$(json-search -Kn properties <<< $base | tr -d "\n[],\"" | sed 's/  / /g')
fi

aditional=$(json-search -n additionalProperties <<< $base)

if [[ "$aditional" != "null"  &&  "$aditional" != "false" ]]; then
    # no type checks are made here, the additional stuff is assumed to be a string
    cat <<EOF
	struct osc_additional_strings **elems = args->additional_strs;

	for (struct osc_additional_strings **e = elems; e && *e; ++e) {
		TRY_APPEND_COL(count_args, data);
		STRY(osc_str_append_string(data, "\"" ));
		STRY(osc_str_append_string(data, (*e)->key ));
		STRY(osc_str_append_string(data, "\":" ));
		STRY(osc_str_append_string(data, "\"" ));
		STRY(osc_str_append_string(data, (*e)->val ));
		STRY(osc_str_append_string(data, "\"" ));
	}
EOF
fi


if [[ "$args" == "null" ]]; then
    exit
fi

for x in $args ;do
    snake_x=$(to_snakecase <<< $x)
    snake_x=$( if [ "default" == "$snake_x" ] ; then echo default_arg; else echo $snake_x; fi )
    t=$(get_type $func $x)

    if [ "$t" == 'long long int' ]; then
	t='int'
    fi

    if [ "$t" == 'bool' ]; then
	cat <<EOF
	if (args->is_set_$snake_x) {
		ARG_TO_JSON($x, bool, args->$snake_x);
	   	ret += 1;
	}
EOF
    elif [ "$t" ==  'string' ]; then
	cat <<EOF
	if (args->$snake_x) {
		TRY_APPEND_COL(count_args, data);
	        ARG_TO_JSON_STR("\"$x\\":", args->$snake_x);
	   	ret += 1;
	}
EOF
    elif [ "$t" ==  'int' -o  "$t" ==  'double' ]; then
	cat <<EOF
	if (args->is_set_$snake_x || args->$snake_x) {
		ARG_TO_JSON($x, $t, args->$snake_x);
	   	ret += 1;
	}
EOF
    elif [ "$t" ==  'array string' ]; then
	cat <<EOF
	if (args->$snake_x) {
		char **as;

	   	TRY_APPEND_COL(count_args, data);
		STRY(osc_str_append_string(data, "\"$x\\":[" ));
		for (as = args->$snake_x; *as; ++as) {
			if (as != args->$snake_x)
				STRY(osc_str_append_string(data, "," ));
			ARG_TO_JSON_STR("", *as);
		}
		STRY(osc_str_append_string(data, "]" ));
		ret += 1;
	} else if (args->${snake_x}_str) {
		ARG_TO_JSON($x, string, args->${snake_x}_str);
		ret += 1;
	}
EOF
    elif [ "$t" ==  'array integer' -o "$t" ==  'array double' ]; then
	if [ "$t" ==  'array integer' ]; then
	    sub_t='int'
	else
	    sub_t='double'
	fi

	cat <<EOF
	if (args->$snake_x) {
		$sub_t *ip;

	   	TRY_APPEND_COL(count_args, data);
		STRY(osc_str_append_string(data, "\"$x\\":[" ));
		for (ip = args->$snake_x; *ip > 0; ++ip) {
			if (ip != args->$snake_x)
				STRY(osc_str_append_string(data, "," ));
			STRY(osc_str_append_${sub_t}(data, *ip));
		}
		STRY(osc_str_append_string(data, "]" ));
		ret += 1;
	} else if (args->${snake_x}_str) {
		ARG_TO_JSON($x, string, args->${snake_x}_str);
		ret += 1;
	}
EOF
    elif [ 'ref' == "$( echo $t | cut -d ' ' -f 1 )" ]; then
	type="$( echo $t | cut -d ' ' -f 2 | to_snakecase)"

	cat <<EOF
	if (args->${snake_x}_str) {
		ARG_TO_JSON($x, string, args->${snake_x}_str);
		ret += 1;
	} else if (args->is_set_$snake_x) {
	       TRY_APPEND_COL(count_args, data);
	       STRY(osc_str_append_string(data, "\"$x\": { " ));
	       STRY(${type}_setter(&args->${snake_x}, data) < 0);
	       STRY(osc_str_append_string(data, "}" ));
	       ret += 1;
	}
EOF
    else
	suffix=""
	if [ 'ref' == $(echo $t | cut -d ' ' -f 2 ) ]; then
	    suffix="_str"
	    type="$( echo $t | cut -d ' ' -f 3 | to_snakecase)"


	    cat <<EOF
        if (args->$snake_x) {
	        TRY_APPEND_COL(count_args, data);
		STRY(osc_str_append_string(data, "\"$x\\":[" ));
		for (int i = 0; i < args->nb_${snake_x}; ++i) {
	       	    struct ${type} *p = &args->$snake_x[i];
		    if (p != args->$snake_x)
		        STRY(osc_str_append_string(data, "," ));
		    STRY(osc_str_append_string(data, "{ " ));
	       	    STRY(${type}_setter(p, data) < 0);
	       	    STRY(osc_str_append_string(data, "}" ));
		}
		STRY(osc_str_append_string(data, "]" ));
		ret += 1;
	} else
EOF
	fi
	cat <<EOF
	if (args->$snake_x${suffix}) {
		ARG_TO_JSON($x, string, args->${snake_x}${suffix});
		ret += 1;
	}
EOF
    fi
done

