source ./config.sh

OSC_API_JSON=$(cat ./osc-api.json)

get_type_direct() {
    arg_info="$1"
    local types=$(jq -r .type 2> /dev/null <<< $arg_info)
    local have_type=$?
    local one_of=$(jq -r .oneOf 2> /dev/null <<< $arg_info)
    local have_one_of=$?
    if [ $have_type == 0 -a "$types" != 'null' ]; then
	if [ "$types" == 'integer' ]; then
	    echo int
	    return 0
	elif [ "$types" == 'number' ]; then
	    echo double
	    return 0
	elif [ "$types" == 'boolean' ]; then
	    echo bool
	    return 0
	elif [ "$types" == 'array' ]; then
	    local item_one_off=$(jq -r .items.oneOf 2> /dev/null <<< $arg_info)
	    local item_is_one_of=$?
	    local sub_type=$(jq -r .items.type 2> /dev/null <<< $arg_info)
	    have_stype=$?
	    if [ $item_is_one_of == 0 -a "$item_one_off" != 'null'  ]; then
		local the_one=$(jq .[0] <<< $item_one_off)
		sub_type=$(get_type_direct "$the_one")
		have_stype=0
	    fi
	    if [ $have_stype == 0 ]; then
		if [ "$sub_type" == 'string' ]; then
		    types="array string"
		elif [ "$sub_type" == 'integer' ]; then
		    types="array integer"
		elif [ "$sub_type" == 'number' ]; then
		    types="array double"
		elif [ "$sub_type" == 'null' ]; then
		    types="array ref $(json-search -R '$ref' <<< ${arg_info} | cut  -d '/' -f 4)"
		else
		    types="array ${sub_type}"
		fi
	    fi
	fi
	echo $types
    elif [ $have_one_of == 0 -a "$one_of" != 'null'  ]; then
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
    st_info=$(jq .components.schemas.$struct <<< $OSC_API_JSON)

    get_type3 "$st_info" "$arg"
}

get_type_description_() {
    echo "$1" | jq .properties.$2.description
}

get_sub_type_description() {
    local st_info=$(jq .components.schemas.$1 <<<  $OSC_API_JSON)
    echo $st_info | jq .description | fold -s -w64 | sed "s/^/${2}/"
    local properties=$(json-search -K properties <<< $st_info | tr -d '"[],')
    #echo $properties
    for p in $properties; do
	local properties=$(json-search $p <<< $st_info)
	local desc=$(jq .description <<< $properties)
	local type=$(get_type_direct "$properties")
	echo "${2}-$p: $type"
	if [ "$desc" != "null" ]; then
	    echo $desc | fold -s -w64 | sed "s/^/${2}  /"
	fi
	local sub=$(json-search -R '$ref' <<< $properties 2>&1 )
	if [ "$sub" != 'null' -a "$sub" != "nothing found" ]; then
	    local sub_type=$(cut  -d '/' -f 4 <<< $sub)
	    get_sub_type_description "$sub_type" "${2}    "
	fi
	#get_sub_type_description "$st_info" "$p"
    done
}

get_type_description() {
    local properties=$(jq .properties.$2 <<< "$1")
    local desc=$(jq .description <<< "$properties")
    local ref=$(json-search '$ref' <<< "$properties" 2>&1 )

    if [ "$desc" != "null" ]; then
	echo $desc
    fi
    if [ "$ref" != "null" -a "$ref" != "nothing found" ]; then
	local sub_type=$(echo  "$1" | jq .properties.$2 | json-search -R '$ref' | cut  -d '/' -f 4)
	get_sub_type_description "$sub_type" "  "
    fi
}

get_type() {
    x=$2
    func=$1
    local arg_info=$(json-search ${func}Request <<< $OSC_API_JSON | json-search $x)
    local one_of=$(jq -r .oneOf 2> /dev/null <<< $arg_info)
    local have_one_of=$?
    local limit=""
    if [ $have_one_of == 0 -a "$one_of" != 'null'  ]; then
	limit="-M 1"
    fi
    types=$(json-search $limit -R type 2> /dev/null <<< $arg_info)
    have_type=$?
    if [ $have_type == 0 ]; then
	if [ "$types" == 'integer' ]; then
	    echo int
	    return 0
	elif [ "$types" == 'number' ]; then
	    echo double
	    return 0
	elif [ "$types" == 'boolean' ]; then
	    echo bool
	    return 0
	elif [ "$types" == 'array' ]; then
	    sub_ref=$(json-search -R '$ref' <<< ${arg_info} | cut  -d '/' -f 4 2> /dev/null)
	    have_sref=$?

	    if [ $have_sref == 0 ]; then
		types="array ref $sub_ref"
	    fi
	fi
	echo $types
    else
	echo ref $(json-search -R '$ref' <<< ${arg_info} | cut  -d '/' -f 4)
    fi
    return 0
}

alias to_snakecase="sed 's/\([a-z0-9]\)\([A-Z]\)/\1_\L\2/g;s/[A-Z]/\L&/g'"
