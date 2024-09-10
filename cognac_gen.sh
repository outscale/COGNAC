#!/usr/bin/env bash

OSC_API_JSON=$(cat ./osc-api.json)

CALL_LIST_FILE=./call_list
CALL_LIST=$(cat $CALL_LIST_FILE)

PIPED_CALL_LIST=$(sed 's/ / | /g' <<< $CALL_LIST)

lang=$3

shopt -s expand_aliases

source ./helper.sh

dash_this_arg()
{
    local cur="$1"
    local st_info="$2"
    local arg="$3"

    local t=$(get_type3 "$st_info" $st_arg)
    cur="$cur.$arg"
    if [ "ref" == $( echo "$t" | cut -d ' ' -f 1) ]; then
	local st=$( echo $t | cut -f 2 -d ' ' )
	local st_info=$(jq .components.schemas.$st < osc-api.json)
	local st_args=$(json-search -K properties <<< "$st_info"- | tr -d '"[],')

	for st_arg in $st_args; do
	    dash_this_arg "$cur" "$st_info" $st_arg
	    echo -n ' '
	done
    else
	echo -n $cur
    fi
}

dash_this()
{
    local x=$1
    local arg=$2
    local t=$(get_type $x $arg)

    if [ "ref" == $( echo "$t" | cut -d ' ' -f 1) ]; then
	local st=$( echo $t | cut -f 2 -d ' ' )
	local st_info=$(jq .components.schemas.$st < osc-api.json)
	local st_args=$(json-search -K properties <<< "$st_info"- | tr -d '"[],')

	for st_arg in $st_args; do
	    local tt=$(get_type3 "$st_info" $st_arg)

	    dashed_args="$dashed_args $(dash_this_arg --$arg "$st_info" $st_arg)"
	done
    else
	dashed_args="$dashed_args --$arg"
    fi

}

cli_c_type_parser()
{
    a=$1
    type=$2
    indent_base=$3
    indent_plus="$indent_base    "
    snake_a=$(to_snakecase <<< $a)
    snake_a=$( if [ "default" == "$snake_a" ] ; then echo default_arg; else echo $snake_a; fi )

    if [ 'int' == "$type" ]; then
	cat <<EOF
${indent_plus}TRY(!aa, "$a argument missing\n");
${indent_plus}s->is_set_$snake_a = 1;
${indent_plus}s->$snake_a = atoi(aa);
$indent_base } else
EOF
    elif [ 'long long int' == "$type" ]; then
	cat <<EOF
${indent_plus}TRY(!aa, "$a argument missing\n");
${indent_plus}s->is_set_$snake_a = 1;
${indent_plus}s->$snake_a = atoll(aa);
$indent_base } else
EOF
    elif [ 'double' == "$type" ]; then
	    cat <<EOF
${indent_plus}TRY(!aa, "$a argument missing\n");
${indent_plus}s->is_set_$snake_a = 1;
${indent_plus}s->$snake_a = atof(aa);
$indent_base } else
EOF
    elif [ 'bool' == "$type" ]; then
	cat <<EOF
${indent_plus}s->is_set_$snake_a = 1;
${indent_plus}if (!aa || !strcasecmp(aa, "true")) {
${indent_plus}		s->$snake_a = 1;
$indent_plus } else if (!strcasecmp(aa, "false")) {
${indent_plus}		s->$snake_a = 0;
$indent_plus } else {
${indent_plus}		BAD_RET("$a require true/false\n");
$indent_plus }
$indent_base} else
EOF
    elif [ 'array integer' == "$type" -o 'array string' == "$type" -o 'array double' == "$type" ]; then


	local convertor=""
	local null_val='""'
	if [ 'array integer' == "$type" ]; then
	    convertor=atoi
	    null_val=0
	elif [ 'array double' == "$type" ]; then
	    convertor=atof
	    null_val=0.0
	fi
	cat <<EOF
${indent_plus}     if (aret == '.') {
${indent_plus}          int pos;
${indent_plus}          char *endptr;
${indent_plus}          int last = 0;
${indent_plus}          char *dot_pos = strchr(str, '.');

${indent_plus}          TRY(!(dot_pos++), "$a argument missing\n");
${indent_plus}          pos = strtoul(dot_pos, &endptr, 0);
${indent_plus}          TRY(endptr == dot_pos, "$a require an index\n");
${indent_plus}          if (s->${snake_a}) {
${indent_plus}                  for (; s->${snake_a}[last]; ++last);
${indent_plus}          }
${indent_plus}          if (pos < last) {
${indent_plus}                  s->${snake_a}[pos] = ${convertor}(aa);
${indent_plus}          } else {
${indent_plus}                  for (int i = last; i < pos; ++i)
${indent_plus}                          SET_NEXT(s->${snake_a}, $null_val, pa);
${indent_plus}                  SET_NEXT(s->${snake_a}, ${convertor}(aa), pa);
${indent_plus}          }
${indent_plus}     } else {
${indent_plus}	       TRY(!aa, "$a argument missing\n");
${indent_plus}         s->${snake_a}_str = aa;
${indent_plus}     }
$indent_base } else if (!(aret = argcmp(str, "$a[]")) || aret == '=') {
${indent_plus}   TRY(!aa, "$a[] argument missing\n");
${indent_plus}   SET_NEXT(s->${snake_a}, ${convertor}(aa), pa);
$indent_base } else
EOF
    elif [ 'ref' == $( echo "$type" | cut -d ' ' -f 1 ) ]; then

	sub_type=$(echo $type | cut -d ' ' -f 2 | to_snakecase)
	cat <<EOF
${indent_plus}char *dot_pos;

${indent_plus}TRY(!aa, "$a argument missing\n");
${indent_plus}dot_pos = strchr(str, '.');
${indent_plus}if (dot_pos++) {
${indent_plus}	    cascade_struct = &s->${snake_a};
${indent_plus}	    cascade_parser = ${sub_type}_parser;
${indent_plus}	    if (*dot_pos == '.') {
${indent_plus}		++dot_pos;
${indent_plus}	    }
${indent_plus}	    STRY(${sub_type}_parser(&s->${snake_a}, dot_pos, aa, pa));
${indent_plus}	    s->is_set_${snake_a} = 1;
$indent_plus } else {
${indent_plus}       s->${snake_a}_str = aa;
${indent_plus} }
$indent_base } else
EOF
    else
	suffix=""
	end_quote=""
	indent_add=""
	if [ 'ref' == $(echo $type | cut -d ' ' -f 2 ) ]; then
	    sub_type=$(echo $type | cut -d ' ' -f 3 | to_snakecase)
	    suffix="_str"
	    end_quote="${indent_plus}}"
	    indent_add="	"
	    cat <<EOF
${indent_plus}char *dot_pos = strchr(str, '.');

${indent_plus}if (dot_pos) {
${indent_plus}	      int pos;
${indent_plus}	      char *endptr;

${indent_plus}	      ++dot_pos;
${indent_plus}	      pos = strtoul(dot_pos, &endptr, 0);
${indent_plus}	      if (endptr == dot_pos)
${indent_plus}		      BAD_RET("'${a}' require an index (example $type.$a.0)\n");
${indent_plus}	      else if (*endptr != '.')
${indent_plus}		      BAD_RET("'${a}' require a .\n");
${indent_plus}	      TRY_ALLOC_AT(s,${snake_a}, pa, pos, sizeof(*s->${snake_a}));
${indent_plus}	      cascade_struct = &s->${snake_a}[pos];
${indent_plus}	      cascade_parser = ${sub_type}_parser;
${indent_plus}	      if (endptr[1] == '.') {
${indent_plus}		     ++endptr;
${indent_plus}	      }
${indent_plus}	      STRY(${sub_type}_parser(&s->${snake_a}[pos], endptr + 1, aa, pa));
$indent_plus } else {
EOF
	fi
	cat <<EOF
${indent_plus}${indent_add}TRY(!aa, "$a argument missing\n");
${indent_plus}${indent_add}s->$snake_a${suffix} = aa; // $type $(echo $type | cut -d ' ' -f 2 )
${end_quote}
$indent_base } else
EOF
    fi

}

replace_args()
{
    API_VERSION=$(json-search -R version < osc-api.json)
    SDK_VERSION=$(cat sdk-version)
    while IFS= read -r line
    do
	#check ____args____ here

	arg_check=$(bin/line_check ____args____ ____func_code____ ____functions_proto____ ____cli_parser____ ____complex_struct_func_parser____ ____complex_struct_to_string_func____ ____call_list_dec____ ____call_list_descriptions____ ____call_list_args_descriptions____ <<< "$line")

	if [ "$arg_check" == "____args____" ]; then
	    ./mk_args.${lang}.sh
	elif [ "$arg_check" == "____call_list_descriptions____" ]; then
	    DELIMES=$(cut -d '(' -f 2 <<< $line | tr -d ')')
	    D1=$(cut -d ';' -f 1  <<< $DELIMES | tr -d "'")
	    D2=$(cut -d ';' -f 2  <<< $DELIMES | tr -d "'")
	    D3=$(cut -d ';' -f 3  <<< $DELIMES | tr -d "'")
	    for x in $CALL_LIST ; do
		echo -en $D1
		local required=$(json-search ${x}Request < osc-api.json | json-search required 2>&1 | tr -d '[]\n"' | tr -s ' ' | sed 's/nothing found//g')
		local usage_required=$( for a in $(echo $required | tr -d ','); do echo -n " --${a}=${a,,}"; done )
		local usage="\"Usage: oapi-cli $x ${usage_required} [OPTIONS]\n\""
		local call_desc=$(jq .paths.\""/$x"\".description < osc-api.json | sed 's/<br \/>//g' | tr -d '"' | fold -s | sed 's/^/"/;s/$/\\n"/')

		echo $usage $call_desc \""\nRequired Argument:" $required "\n\""
		echo -en $D2
	    done
	    echo -ne $D3
	elif [ "$arg_check" == "____call_list_args_descriptions____" ]; then
	    DELIMES=$(cut -d '(' -f 2 <<< $line | tr -d ')')
	    D1=$(cut -d ';' -f 1  <<< $DELIMES | tr -d "'")
	    D2=$(cut -d ';' -f 2  <<< $DELIMES | tr -d "'")
	    D3=$(cut -d ';' -f 3  <<< $DELIMES | tr -d "'")
	    for x in $CALL_LIST ; do
		st_info=$(json-search -s  ${x}Request < osc-api.json)
		A_LST=$(json-search -K properties <<< $st_info | tr -d '",[]')

		echo -en $D1
		for a in $A_LST; do
		    local t=$(get_type3 "$st_info" "$a")
		    local snake_n=$(to_snakecase <<< $a)
		    echo "\"--$a: $t\\n\""
		    get_type_description "$st_info" "$a" | sed 's/<br \/>//g;s/\\"/\&quot;/g' | tr -d '"' | fold -s -w92 | sed 's/^/\t"  /;s/$/\\n"/;s/\&quot;/\\"/g'
		done
		echo -en $D2
	    done
	    echo -ne $D3
	elif [ "$arg_check" == "____call_list_dec____" ]; then
	    DELIMES=$(cut -d '(' -f 2 <<< $line | tr -d ')')
	    D1=$(cut -d ';' -f 1  <<< $DELIMES | tr -d "'")
	    D2=$(cut -d ';' -f 2  <<< $DELIMES | tr -d "'")
	    D3=$(cut -d ';' -f 3  <<< $DELIMES | tr -d "'")
	    for x in $CALL_LIST ;do
		echo -en $D1
		echo -n $x
		echo -en $D2
	    done
	    echo -ne $D3
	elif [ "$arg_check" == "____complex_struct_to_string_func____" ]; then
	    COMPLEX_STRUCT=$(jq .components < osc-api.json | json-search -KR schemas | tr -d '"' | sed 's/,/\n/g' | grep -v Response | grep -v Request)

	    for s in $COMPLEX_STRUCT; do
		struct_name=$(to_snakecase <<< $s)

		A_LST=$(jq .components.schemas.$s < osc-api.json | json-search -Kn properties | tr -d '",[]')
		if [ "$A_LST" != "null" ]; then
		    echo "static int ${struct_name}_setter(struct ${struct_name} *args, struct osc_str *data);"
		fi
	    done
	    for s in $COMPLEX_STRUCT; do
		struct_name=$(to_snakecase <<< $s)
		A_LST=$(jq .components.schemas.$s < osc-api.json | json-search -Kn properties | tr -d '",[]')
		if [ "$A_LST" != "null" ]; then
		    cat <<EOF
static int ${struct_name}_setter(struct ${struct_name} *args, struct osc_str *data) {
       int count_args = 0;
       int ret = 0;
EOF

		    ./construct_data.c.sh $s complex_struct
		    cat <<EOF

	return !!ret;
}
EOF
		fi
	    done
	elif [ "$arg_check" == "____complex_struct_func_parser____" ]; then
	    COMPLEX_STRUCT=$(jq .components < osc-api.json | json-search -KR schemas | tr -d '"' | sed 's/,/\n/g' | grep -v Response | grep -v Request)

	    # prototypes
	    for s in $COMPLEX_STRUCT; do
		struct_name=$(to_snakecase <<< $s)
		A_LST=$(jq .components.schemas.$s < osc-api.json | json-search -Kn properties | tr -d '",[]')
		if [ "$A_LST" != "null" ]; then
		    echo  "int ${struct_name}_parser(void *s, char *str, char *aa, struct ptr_array *pa);"
		fi
	    done
	    echo "" #add a \n

	    # functions
	    for s in $COMPLEX_STRUCT; do
		#for s in "skip"; do
		struct_name=$(to_snakecase <<< $s)

		A_LST=$(jq .components.schemas.$s < osc-api.json | json-search -Kn properties | tr -d '",[]')
		if [ "$A_LST" != "null" ]; then
		    echo  "int ${struct_name}_parser(void *v_s, char *str, char *aa, struct ptr_array *pa) {"

		    echo "	    struct $struct_name *s = v_s;"
		    echo "	    int aret = 0;"
		    for a in $A_LST; do
			t=$(get_type2 "$s" "$a")
			snake_n=$(to_snakecase <<< $a)

			echo "	if ((aret = argcmp(str, \"$a\")) == 0 || aret == '=' || aret == '.') {"
			cli_c_type_parser "$a" "$t" "        "
		    done
		    cat <<EOF
	{
		fprintf(stderr, "'%s' not an argumemt of '$s'\n", str);
		return -1;
	}
EOF
		    echo "	return 0;"
		    echo -e '}\n'
		fi
	    done

	elif [ "$arg_check" == "____cli_parser____" ] ; then
	    for l in $CALL_LIST; do
		snake_l=$(to_snakecase <<< $l)
		arg_list=$(json-search ${l}Request < osc-api.json \
			       | json-search -K properties \
			       | tr -d "[]\"," | sed '/^$/d')

		cat <<EOF
              if (!strcmp("$l", av[i])) {
		     auto_osc_json_c json_object *jobj = NULL;
		     auto_ptr_array struct ptr_array opa = {0};
		     struct ptr_array *pa = &opa;
	      	     struct osc_${snake_l}_arg a = {0};
		     struct osc_${snake_l}_arg *s = &a;
		     __attribute__((cleanup(files_cnt_cleanup))) char *files_cnt[MAX_FILES_PER_CMD] = {NULL};
	             int cret;

		     cascade_struct = NULL;
		     cascade_parser = NULL;

		     ${snake_l}_arg:

		     if (i + 1 < ac && av[i + 1][0] == '.' && av[i + 1][1] == '.') {
 		           char *next_a = &av[i + 1][2];
		           char *aa = i + 2 < ac ? av[i + 2] : 0;
			   int incr = 2;
			   char *eq_ptr = strchr(next_a, '=');

	      	           CHK_BAD_RET(!cascade_struct, "cascade need to be se first\n");
			   if (eq_ptr) {
			      	  CHK_BAD_RET(!*eq_ptr, "cascade need an argument\n");
			      	  incr = 1;
				  aa = eq_ptr + 1;
			   } else {
			     	  CHK_BAD_RET(!aa, "cascade need an argument\n");
					  META_ARGS({CHK_BAD_RET(aa[0] == '-', "cascade need an argument"); })
			   }
		      	   STRY(cascade_parser(cascade_struct, next_a, aa, pa));
			   i += incr;
		       	   goto ${snake_l}_arg;
		      }

		     if (i + 1 < ac && av[i + 1][0] == '-' && av[i + 1][1] == '-' && strcmp(av[i + 1] + 2, "set-var")) {
 		             char *next_a = &av[i + 1][2];
			     char *str = next_a;
 		     	     char *aa = i + 2 < ac ? av[i + 2] : 0;
			     int aret = 0;
			     int incr = aa ? 2 : 1;

			     (void)str;
			     if (aa && aa[0] == '-' && aa[1] == '-' && aa[2] != '-') {
				 	META_ARGS({ aa = 0; incr = 1; });
			     }
EOF

		for a in $arg_list ; do
		    type=$(get_type $l $a)
		    snake_a=$(to_snakecase <<< $a)

		    cat <<EOF
			      if ((aret = argcmp(next_a, "$a")) == 0 || aret == '='  || aret == '.') {
			      	 char *eq_ptr = strchr(next_a, '=');
			      	 if (eq_ptr) {
				    TRY((!*eq_ptr), "$a argument missing\n");
				    aa = eq_ptr + 1;
				    incr = 1;
				 }
EOF
		    cli_c_type_parser "$a" "$type" "				      "
		done

		cat <<EOF
			    {
				BAD_RET("'%s' is not a valide argument for '$l'\n", next_a);
			    }
		            i += incr;
			    goto ${snake_l}_arg;
		     }
		     cret = osc_$snake_l(&e, &r, &a);
            	     TRY(cret, "fail to call $l: %s\n", curl_easy_strerror(cret));
		     CHK_BAD_RET(!r.buf, "connection sucessful, but empty responce\n");
		     jobj = NULL;
		     if (program_flag & OAPI_RAW_OUTPUT)
		             puts(r.buf);
		     else {
			     jobj = json_tokener_parse(r.buf);
			     puts(json_object_to_json_string_ext(jobj,
					JSON_C_TO_STRING_PRETTY | JSON_C_TO_STRING_NOSLASHESCAPE |
					color_flag));
		     }
		     while (i + 1 < ac && !strcmp(av[i + 1], "--set-var")) {
		     	     ++i;
			     TRY(i + 1 >= ac, "--set-var require an argument");
		     	     if (!jobj)
			     	jobj = json_tokener_parse(r.buf);
			     if (parse_variable(jobj, av, ac, i))
			     	return -1;
		     	     ++i;
		      }

		      if (jobj) {
			     json_object_put(jobj);
			     jobj = NULL;
		      }
		     osc_deinit_str(&r);
	      } else
EOF
	    done
	elif [ "$arg_check" == "____functions_proto____" ] ; then
	    for l in $CALL_LIST; do
		local snake_l=$(to_snakecase <<< $l)
		echo "int osc_${snake_l}(struct osc_env *e, struct osc_str *out, struct osc_${snake_l}_arg *args);"
	    done
	elif [ "$arg_check" == "____func_code____" ]; then
	    for x in $CALL_LIST; do
		local snake_x=$(to_snakecase <<< $x)
		local args=$(json-search ${x}Request < osc-api.json \
				 | json-search -K properties  | tr -d "[]\",")
		dashed_args=""
		for arg in $args; do
		    dash_this "$x" "$arg"
		done

		while IFS= read -r fline
		do
		    grep ____construct_data____ <<< "$fline" > /dev/null
		    local have_construct_data=$?
		    if [ $have_construct_data == 0 ]; then
			./construct_data.${lang}.sh $x
		    else
			sed "s/____func____/$x/g; s/____snake_func____/$snake_x/g;s/____dashed_args____/$dashed_args/g" <<< "$fline"
		    fi
		done < function.${lang}
	    done
	else
	    sed "s/____call_list____/${CALL_LIST}/g;s/____piped_call_list____/${PIPED_CALL_LIST}/;s/____api_version____/${API_VERSION}/g;s/____sdk_version____/${SDK_VERSION}/g;s/____cli_version____/$(cat cli-version)/g" <<< "$line";
	fi
    done < $1
}

replace_args $1 > $2
