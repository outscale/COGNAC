#/usr/bin/env bash

____func_code____

_mk_profiles()
{
    cur=${COMP_WORDS[COMP_CWORD]}

    if [ -f ~/.osc/config.json ]; then
        PROFILES=$(cat ~/.osc/config.json | tr -d '\n:'  | sed 's/{[^{}]*}//g' | tr -d "{}\" " | sed 's/,/ /g')
    fi
    for x in $PROFILES ; do echo --profile=$x ; done
}

_cognac()
{
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case ${COMP_CWORD} in
        *)
            case ${prev} in
		____piped_call_list____)
		    eval ${prev}
		    ;;
		--help)
		    COMPREPLY=($(compgen -W "____call_list____" -- ${cur}))
		    ;;
                *)
                    PROFILES=$(_mk_profiles)
                    COMPREPLY=($(compgen -W "$PROFILES --config --login --password --authentication_method --color --insecure --raw-print --verbose --help -h --list-calls --version ____call_list____" -- ${cur}))
		    ;;
            esac
            ;;
    esac
}

complete -F _cognac ____cli_name____
complete -F _cognac ____cli_name____-x86_64.AppImage

# thoses one are for debug
complete -F _cognac ./____cli_name____
complete -F _cognac ./____cli_name____-x86_64.AppImage
