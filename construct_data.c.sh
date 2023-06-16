#!/usr/bin/env bash

shopt -s expand_aliases

func=$1

source ./helper.sh

if [ "complex_struct" == "$2" ]; then
    args=$(jq .components.schemas.$func <<<  $OSC_API_JSON | json-search -K properties | tr -d '",[]')
    alias get_type=get_type2
else
    args=$(json-search ${func}Request osc-api.json | json-search -K properties | tr -d "\n[],\"" | sed 's/  / /g')
fi

for x in $args ;do
    snake_x=$(to_snakecase <<< $x)
    snake_x=$(sed s/default/default_arg/g <<< $snake_x)
    t=$(get_type $func $x)

    if [ "$t" == 'bool' ]; then
	cat <<EOF
	if (args->is_set_$snake_x) {
	   	TRY_APPEND_COL(count_args, data);
		STRY(osc_str_append_string(data, "\"$x\\":" ));
                STRY(osc_str_append_bool(data, args->$snake_x));
	   	ret += 1;
	}
EOF
    elif [ "$t" ==  'string' ]; then
	cat <<EOF
	if (args->$snake_x) {
	   	TRY_APPEND_COL(count_args, data);
		STRY(osc_str_append_string(data, "\"$x\\":\"" ));
                STRY(osc_str_append_string(data, args->$snake_x));
		STRY(osc_str_append_string(data, "\"" ));
	   	ret += 1;
	}
EOF
    elif [ "$t" ==  'int' -o  "$t" ==  'double' ]; then
	cat <<EOF
	if (args->is_set_$snake_x || args->$snake_x) {
	   	TRY_APPEND_COL(count_args, data);
		STRY(osc_str_append_string(data, "\"$x\\":" ));
                STRY(osc_str_append_${t}(data, args->$snake_x));
	   	ret += 1;
	}
EOF
    elif [ "$t" ==  'array string' ]; then
	cat <<EOF
	if (args->$snake_x) {
		char **as;

	   	TRY_APPEND_COL(count_args, data);
		STRY(osc_str_append_string(data, "\"$x\\":[" ));
		for (as = args->$snake_x; *as > 0; ++as) {
			if (as != args->$snake_x)
				STRY(osc_str_append_string(data, "," ));
			STRY(osc_str_append_string(data, "\"" ));
			STRY(osc_str_append_string(data, *as));
			STRY(osc_str_append_string(data, "\"" ));
		}
		STRY(osc_str_append_string(data, "]" ));
		ret += 1;
	} else if (args->${snake_x}_str) {
	   	TRY_APPEND_COL(count_args, data);
		STRY(osc_str_append_string(data, "\"$x\\":" ));
                STRY(osc_str_append_string(data, args->${snake_x}_str));
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
	   	TRY_APPEND_COL(count_args, data);
		STRY(osc_str_append_string(data, "\"$x\\":" ));
                STRY(osc_str_append_string(data, args->${snake_x}_str));
		ret += 1;
	}
EOF
    elif [ 'ref' == "$( echo $t | cut -d ' ' -f 1 )" ]; then
	type="$( echo $t | cut -d ' ' -f 2 | to_snakecase)"

	cat <<EOF
	if (args->${snake_x}_str) {
	   	TRY_APPEND_COL(count_args, data);
		STRY(osc_str_append_string(data, "\"$x\\":" ));
                STRY(osc_str_append_string(data, args->${snake_x}_str));
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
	   	TRY_APPEND_COL(count_args, data);
		STRY(osc_str_append_string(data, "\"$x\\":" ));
                STRY(osc_str_append_string(data, args->${snake_x}${suffix}));
		ret += 1;
	}
EOF
    fi
done

