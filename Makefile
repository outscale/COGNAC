# COGNAC for: Code Outscale Generator New Automatic Creator
# you can find a better name if you want.

all: make_cli

config.mk:
	@echo "config.mk is not present"
	@echo "use './configure --help' for information, on how to make it"
	@exit 1

OAPI_RULE_DEPEDENCIES=main.c osc_sdk.h osc_sdk.c main-helper.h
OAPI_APPIMAGE_RULE_DEPEDENCIES=$(CLI_NAME)-completion.bash

list_api_version:
	curl -s https://api.github.com/repos/outscale/osc-api/tags | $(JSON_SEARCH) -R name

include config.mk

help:
	@echo "Available targets:"
	@echo "- osc_sdk.c/osc_sdk.h/main.c/$(CLI_NAME)-completion.bash: make the file"
	@echo "- list_api_version: list all version avable on github"
	@echo "- clean: remove every generated files"


include oapi-cli.mk

BIN_DEPENDANCIES=bin/path_to_snakecase bin/path_to_camelcase bin/line_check bin/get_argument_list bin/funclist bin/get_path_type bin/get_path_description bin/arg_placement bin/construct_path bin/construct_endpoint

osc-api.json::
	./bin/osc-api-seems-valid.sh osc-api.json "need_remove"

make_cli: $(CLI_NAME) $(CLI_NAME)-completion.bash

bin/funclist: bin/funclist.c
	$(CC) -O3 bin/funclist.c $(JSON_C_LDFLAGS) $(JSON_C_CFLAGS) -o bin/funclist

bin/construct_path: bin/construct_path.c
	$(CC) -O3 bin/construct_path.c $(JSON_C_LDFLAGS) $(JSON_C_CFLAGS) -o bin/construct_path

bin/construct_endpoint: bin/construct_endpoint.c
	$(CC) -O3 bin/construct_endpoint.c $(JSON_C_LDFLAGS) $(JSON_C_CFLAGS) -o bin/construct_endpoint

bin/path_to_snakecase: bin/path_to_snakecase.c
	$(CC) -O3 bin/path_to_snakecase.c $(JSON_C_LDFLAGS) $(JSON_C_CFLAGS) -o bin/path_to_snakecase

bin/arg_placement: bin/arg_placement.c
	$(CC) -O3 bin/arg_placement.c $(JSON_C_LDFLAGS) $(JSON_C_CFLAGS) -o bin/arg_placement

bin/path_to_camelcase: bin/path_to_camelcase.c
	$(CC) -O3 bin/path_to_camelcase.c $(JSON_C_LDFLAGS) $(JSON_C_CFLAGS) -o bin/path_to_camelcase

bin/line_check: bin/line_check.c
	$(CC) -O3 bin/line_check.c -o bin/line_check

bin/get_argument_list: bin/get_argument_list.c
	$(CC) -O3 -g bin/get_argument_list.c $(JSON_C_LDFLAGS) $(JSON_C_CFLAGS) -o bin/get_argument_list

bin/get_path_type: bin/get_path_type.c
	$(CC) -O3 -g bin/get_path_type.c $(JSON_C_LDFLAGS) $(JSON_C_CFLAGS) -o bin/get_path_type

bin/get_path_description: bin/get_path_description.c
	$(CC) -O3 -g bin/get_path_description.c $(JSON_C_LDFLAGS) $(JSON_C_CFLAGS) -o bin/get_path_description

main.c: $(BIN_DEPENDANCIES) osc-api.json call_list config.sh main_tpl.c cognac_gen.sh mk_args.c.sh
	./cognac_gen.sh main_tpl.c main.c c

osc_sdk.c: $(BIN_DEPENDANCIES) osc-api.json call_list config.sh lib.c cognac_gen.sh construct_data.c.sh mk_args.c.sh
	./cognac_gen.sh lib.c osc_sdk.c c

osc_sdk.h: $(BIN_DEPENDANCIES) osc-api.json call_list config.sh lib.h cognac_gen.sh mk_args.c.sh
	./cognac_gen.sh lib.h osc_sdk.h c

$(CLI_NAME)-completion.bash: $(BIN_DEPENDANCIES) osc-api.json call_list config.sh oapi-cli-completion-tpl.bash cognac_gen.sh
	./cognac_gen.sh oapi-cli-completion-tpl.bash $(CLI_NAME)-completion.bash bash

config.sh: configure config.mk
	echo "alias json-search=$(JSON_SEARCH)" > config.sh
	echo $(SED_ALIAS) >> config.sh
	echo FUNCTION_SUFFIX=$(FUNCTION_SUFFIX) >> config.sh
	echo "export CLI_NAME=$(CLI_NAME)" >> config.sh
	echo "export SDK_NAME=$(SDK_NAME)" >> config.sh
	echo "export FROM_PATH=$(FROM_PATH)" >> config.sh
	echo -e "debug()\n{" >> config.sh
	echo -e '\tif [[ "$$DEBUG_MODE" == "1" ]] ; then echo "$$@" >&2 ; fi\n}' >> config.sh
	echo export DEBUG_MODE=$(DEBUG_MODE) >> config.sh

call_list: osc-api.json bin/funclist
	bin/funclist osc-api.json $(FUNCLIST_ARG) > call_list

clean:
	rm -vf osc-api.json call_list osc_sdk.c osc_sdk.h main.c $(CLI_NAME) config.sh $(CLI_NAME)-completion.bash bin/line_check bin/funclist bin/path_to_snakecase

.PHONY: clean list_api_version help make_cli

