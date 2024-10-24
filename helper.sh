source ./config.sh

get_type_direct() {
    arg_info="$1"
    local direct_ref=$(jq -r '.["$ref"]' 2> /dev/null <<< $arg_info)
    local have_direct_ref=$?
    if [ $have_direct_ref == 0 -a "$direct_ref" != 'null' ]; then
    	ref_path=$(cut -c 2- <<< $direct_ref | sed 's|/|.|g')
	local direct_ref_properties=$(jq $ref_path.properties < osc-api.json 2> /dev/null)
	if [ "$direct_ref_properties" == 'null' ]; then
    	    arg_info="$(jq $ref_path < osc-api.json)"
	fi
    fi
    local types=$(jq -r .type 2> /dev/null <<< $arg_info)
    local have_type=$?
    local one_of=$(jq -r .oneOf 2> /dev/null <<< $arg_info)
    local have_one_of=$?
    local any_of=$(jq -r .anyOf 2> /dev/null <<< $arg_info)
    local have_any_of=$?
    if [[ $have_any_of == 0 && "$any_of" != 'null'  ]]; then
	one_of="$any_of"
	have_one_of=$have_any_of
    fi
    if [[ $have_type == 0 && "$types" != 'null' ]]; then
	if [[ "$types" == 'integer' ]]; then
	    echo "long long int"
	    return 0
	elif [[ "$types" == 'number' ]]; then
	    echo double
	    return 0
	elif [[ "$types" == 'boolean' ]]; then
	    echo bool
	    return 0
	elif [[ "$types" == 'array' ]]; then
	    local item_one_off=$(jq -r .items.oneOf 2> /dev/null <<< $arg_info)
	    local item_is_one_of=$?
	    local item_any_of=$(jq -r .items.anyOf 2> /dev/null <<< $arg_info)
	    local item_have_any_of=$?
	    local sub_type=$(jq -r .items.type 2> /dev/null <<< $arg_info)
	    have_stype=$?
	    if [[ $item_have_any_of == 0 && "$item_any_of" != 'null'  ]]; then
		local the_one=$(jq .[0] <<< $item_any_of)
		sub_type=$(get_type_direct "$the_one")
		have_stype=0
	    fi
	    if [[ $item_is_one_of == 0 && "$item_one_off" != 'null'  ]]; then
		local the_one=$(jq .[0] <<< $item_one_off)
		sub_type=$(get_type_direct "$the_one")
		have_stype=0
	    fi
	    if [[ $have_stype == 0 ]]; then
		if [[ "$sub_type" == 'string' ]]; then
		    types="array string"
		elif [[ "$sub_type" == 'integer' ]]; then
		    types="array integer"
		elif [[ "$sub_type" == 'number' ]]; then
		    types="array double"
		elif [[ "$sub_type" == 'null' ]]; then
		    local osub_ref=$(json-search -R '$ref' <<< ${arg_info})
		    local sub_ref=$(cut  -d '/' -f 4 <<< $osub_ref 2> /dev/null)
		    osub_ref=$(cut -c 2- <<< $osub_ref | sed 's|/|.|g')
		    local sub_ref_properties=$(jq $osub_ref.properties < osc-api.json 2> /dev/null)
		    if [[ "$sub_ref_properties" == 'null'  ||  "$sub_ref_properties" == '' ]]; then
    			local arg_info="$(jq $osub_ref < osc-api.json)"
			local dtypes=$(json-search $limit -R type 2> /dev/null <<< $arg_info)
			types="array $dtypes"
		    else
			types="array ref $sub_ref"
		    fi
		else
		    types="array ${sub_type}"
		fi
	    fi
	fi
	echo $types
    elif [[ $have_one_of == 0 && "$one_of" != 'null'  ]]; then
	local the_one=$(jq .[0] <<< $one_of)
	get_type_direct "$the_one"
    else
	echo ref $(json-search -R '$ref' <<< ${arg_info} | cut  -d '/' -f 4)
    fi
}

get_type3() {
    st_info="$1"
    arg="$2"
    arg_info=$(json-search $arg <<< $st_info)
    get_type_direct "$arg_info"
    return 0
}

get_type2() {
    struct="$1"
    arg="$2"
    st_info=$(jq .components.schemas.$struct < osc-api.json)

    get_type3 "$st_info" "$arg"
}

get_type_description_() {
    jq .properties.$2.description <<< "$1"
}

get_sub_type_description() {
    local st_info=$(jq .components.schemas.$1 < osc-api.json)
    jq .description <<< $st_info | fold -s -w74 | sed "s/^/${2}/"
    local properties=$(json-search -Kn properties <<< $st_info | tr -d '"[],')
    local o_type="$4"
    if [[ "$properties" == "null" ]]; then
	return
    fi
    for p in $properties; do
	local properties=$(jq .properties[\"$p\"] <<< $st_info)

	local desc=$(jq .description <<< $properties)
	local type=$(get_type_direct "$properties")
	local show_idx=""

	if [[ ${o_type%% *} == "array" ]]; then
	    show_idx="INDEX."
	fi
	echo "${2}--${3}.${show_idx}$p: $type"
	if [[ "$desc" != "null" ]]; then
	    fold -s -w74 <<< $desc | sed "s/^/${2}  /"
	fi
	local sub=$(json-search -R '$ref' <<< $properties 2>&1 )
	if [[ "$sub" != 'null' && "$sub" != "nothing found" ]]; then
	    local sub_type=$(cut  -d '/' -f 4 <<< $sub)
	    get_sub_type_description "$sub_type" "${2}    " "${3}.${show_idx}${p}" "$type"
	fi
	#get_sub_type_description "$st_info" "$p"
    done
}

get_type_description() {
    local properties=$(jq .properties.$2 <<< "$1")
    local desc=$(jq .description <<< "$properties")
    local ref=$(json-search '$ref' <<< "$properties" 2>&1 )

    if [[ "$desc" != "null" ]]; then
	echo $desc
    fi
    if [[ "$ref" != "null" && "$ref" != "nothing found" ]]; then
	local sub_type=$(jq .properties.$2 <<< "$1" | json-search -R '$ref' | cut  -d '/' -f 4)
	local o_type=$(get_type3 "$1" "$2")
	get_sub_type_description "$sub_type" "  " "$2" "$o_type"
    fi
}

get_type() {
    x=$2
    func=$1
    local arg_info=$(json-search ${func}Request < osc-api.json | json-search $x)
    local direct_ref=$(jq -r '.["$ref"]' 2> /dev/null <<< $arg_info)
    local have_direct_ref=$?
    if [[ $have_direct_ref == 0 && "$direct_ref" != 'null' ]]; then
    	ref_path=$(cut -c 2- <<< $direct_ref | sed 's|/|.|g')
	local direct_ref_properties=$(jq $ref_path.properties < osc-api.json 2> /dev/null)
	if [[ "$direct_ref_properties" == 'null' ]]; then
    	    arg_info="$(jq $ref_path < osc-api.json)"
	fi
    fi


    local one_of=$(jq -r .oneOf 2> /dev/null <<< $arg_info)
    local have_one_of=$?
    local limit=""
    if [[ $have_one_of == 0 && "$one_of" != 'null'  ]]; then
	limit="-M 1"
    fi
    types=$(json-search $limit -R type 2> /dev/null <<< $arg_info)
    have_type=$?
    if [ $have_type == 0 ]; then
	if [[ "$types" == 'integer' ]]; then
	    echo "long long int"
	    return 0
	elif [[ "$types" == 'number' ]]; then
	    echo double
	    return 0
	elif [[ "$types" == 'boolean' ]]; then
	    echo bool
	    return 0
	elif [[ "$types" == 'array' ]]; then
	    local osub_ref=$(json-search -R '$ref' <<< ${arg_info})
	    local have_sref=$?
	    local sub_ref=$(cut  -d '/' -f 4 <<< $osub_ref 2> /dev/null)
	    osub_ref=$(cut -c 2- <<< $osub_ref | sed 's|/|.|g')

	    if [[ $have_sref == 0 ]]; then
		local sub_ref_properties=$(jq $osub_ref.properties < osc-api.json 2> /dev/null)
		if [[ "$sub_ref_properties" == '' ]]; then
    		    local arg_info="$(jq $osub_ref < osc-api.json)"
		    local dtypes=$(json-search $limit -R type 2> /dev/null <<< $arg_info)
		    types="array $dtypes"
		else
		    types="array ref $sub_ref"
		fi
	    fi
	fi
	echo $types
    else
	echo ref $(json-search -R '$ref' <<< ${arg_info} | cut  -d '/' -f 4)
    fi
    return 0
}

alias to_snakecase="sed 's/\([a-z0-9]\)\([A-Z]\)/\1_\L\2/g;s/[A-Z]/\L&/g'"
