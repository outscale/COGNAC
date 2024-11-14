#!/usr/bin/env bash

shopt -s expand_aliases

source "./helper.sh"

CALL_LIST_FILE=./call_list
CALL_LIST=$(cat $CALL_LIST_FILE)

COMPLEX_STRUCT=$(jq .components < osc-api.json | json-search -KR schemas | tr -d '"' | sed 's/,/\n/g' | grep -v Response | grep -v ${FUNCTION_SUFFIX})

type_to_ctype() {
    local t="$1"
    local snake_name="$2"
    local c_type="char *"

    if [ "$t" == 'int' -o "$t" == 'bool' -o "$t" == 'double' -o "$t" == 'long long int' ]; then
	snake_name=$( if [ "default" == "$snake_name" ] ; then echo default_arg; else echo $snake_name; fi )
	echo "        int is_set_${snake_name};"
	if [ "$t" == 'double' ]; then
	    c_type="double "
	elif [ "$t" == 'long long int' ]; then
	    c_type="long long int "
	else
	    c_type="int "
	fi
    elif [ "$t" == 'array integer' ]; then
	echo "        char *${snake_name}_str;"
	c_type="int *"
    elif [ "$t" == 'array double' ]; then
	echo "        char *${snake_name}_str;"
	c_type="double *"
    elif [ "$t" == 'array string' ]; then
	echo "        char *${snake_name}_str;"
	c_type="char **"
    elif [ "ref" == $( cut -d ' ' -f 1 <<< "$t") ]; then
	cat << EOF
        char *${snake_name}_str;
        int is_set_${snake_name};
EOF
	t=$( cut -f 2 -d ' ' <<< $t )
	c_type="struct $(to_snakecase <<< $t) "
    elif [ "array" == $( cut -d ' ' -f 1 <<< $t) ]; then
	if [ "ref" == $( cut -d ' ' -f 2 <<< $t) ]; then
	    t=$( cut -f 3 -d ' ' <<< $t )
	    cat << EOF
        char *${snake_name}_str;
        int nb_${snake_name};
EOF
	    c_type="struct $(to_snakecase <<< $t) *"
	fi
    fi
    echo "	${c_type}${snake_name};"
}

write_struct() {
    local s0="$1"
    local st_info="$2"
    local A_LST="$3"

    if [ "$st_info" == "" ]; then
	st_info=$(jq .components.schemas.$s0 < osc-api.json)
	A_LST=$(json-search -K properties <<< $st_info | tr -d '",[]')
    fi

    st_s_name=$(to_snakecase <<< $s0)

    echo  "struct $st_s_name {"
    for a in $A_LST; do
	local t=$(get_type3 "$st_info" "$a")
	local snake_n=$(to_snakecase <<< $a)
	echo '        /*'
	get_type_description "$st_info" "$a" | tr -d '"' | fold -s -w70 | sed -e  's/^/         * /g'
	echo '         */'

	type_to_ctype "$t" "$snake_n"
    done
    aditional=$(jq .additionalProperties <<< $st_info)

    if [[ "$aditional" != "null"  &&  "$aditional" != "false" ]]; then
	# no type checks are made here, the additional stuff is assumed to be a string
	echo -e '\tstruct osc_additional_strings **additional_strs;'
    fi

    echo -e '};\n'
}

create_struct() {
    #for s in "skip"; do
    local s="$1"
    local st0_info=$(jq .components.schemas.$s < osc-api.json)
    local A0_LST=$(json-search -Kn properties <<< $st0_info | tr -d '",[]')

    if [ "${structs[$s]}" != "" ]; then
	return
    fi

    if [ "$A0_LST" == "null" ]; then
	return
    fi
    structs["$s"]="is_set"

    for a in $A0_LST; do
	local t=$(get_type3 "$st0_info" "$a")

	if [ "ref" == "$( cut -d ' ' -f 1 <<< $t)" ]; then
	    local sst=$( cut -f 2 -d ' ' <<< $t )
	    local check="${structs[$sst]}"

	    if [ "$check" == "" ]; then
		create_struct "$sst"
		structs["$sst"]="is_set"
	    fi
	fi
    done
    write_struct "$s" "$st0_info" "$A0_LST"
}

declare -A structs

for s in $COMPLEX_STRUCT; do
    create_struct "$s"
done

for l in $CALL_LIST ;do
    snake_l=$(to_snakecase <<< $l)
    request=$(json-search -s  ${l}${FUNCTION_SUFFIX} < osc-api.json)
    ARGS_LIST=$(json-search -KR "properties" <<< $request | tr -d '"' | sed 's/,/\n/g')

    echo "struct osc_${snake_l}_arg  {"
    echo -n "        /* Required:"
    json-search required 2>&1 <<< $request | tr -d "[]\"\n" | tr -s ' ' | sed 's/nothing found/none/g' | to_snakecase
    echo " */"

    for x in $ARGS_LIST ;do
	snake_name=$(to_snakecase <<< "$x")

	t=$(get_type "$l" "$x")
	#echo "get type: $func $x"
	echo '        /*'
	get_type_description "$request" "$x" | tr -d '"' | fold -s -w70 | sed -e  's/^/         * /g' | sed "s/null/See '$snake_name' type documentation/"
	echo '         */'
	#echo "/* TYPE: $t */"
	type_to_ctype "$t" "${snake_name}"
    done
    echo -e "};\n"
done
