# COGNAC for: Code Outscale Generator New Automatic Creator
# you can find a better name if you want.

all: oapi-cli-completion.bash oapi-cli

config.mk:
	@echo "config.mk is not present"
	@echo "use './configure --help' for information, on how to make it"
	@exit 1

OAPI_RULE_DEPEDENCIES=main.c osc_sdk.h osc_sdk.c main-helper.h
OAPI_APPIMAGE_RULE_DEPEDENCIES=oapi-cli-completion.bash

list_api_version:
	curl -s https://api.github.com/repos/outscale/osc-api/tags | $(JSON_SEARCH) -R name

help:
	@echo "Available targets:"
	@echo "- osc_sdk.c/osc_sdk.h/main.c/oapi-cli-completion.bash: make the file"
	@echo "- list_api_version: list all version avable on github"
	@echo "- clean: remove every generated files"

include config.mk

include oapi-cli.mk

bin/funclist: bin/funclist.c
	$(CC) -O3 bin/funclist.c $(JSON_C_LDFLAGS) $(JSON_C_CFLAGS) -o bin/funclist

bin/line_check: bin/line_check.c
	$(CC) -O3 bin/line_check.c -o bin/line_check

main.c: bin/line_check osc-api.json call_list arguments-list.json config.sh main_tpl.c cognac_gen.sh mk_args.c.sh
	./cognac_gen.sh main_tpl.c main.c c

osc_sdk.c: bin/line_check osc-api.json call_list arguments-list.json config.sh lib.c cognac_gen.sh construct_data.c.sh mk_args.c.sh
	./cognac_gen.sh lib.c osc_sdk.c c

osc_sdk.h: bin/line_check osc-api.json call_list arguments-list.json config.sh lib.h cognac_gen.sh mk_args.c.sh
	./cognac_gen.sh lib.h osc_sdk.h c

oapi-cli-completion.bash: bin/line_check osc-api.json call_list arguments-list.json config.sh oapi-cli-completion-tpl.bash cognac_gen.sh
	./cognac_gen.sh oapi-cli-completion-tpl.bash oapi-cli-completion.bash bash

config.sh:
	echo "alias json-search=$(JSON_SEARCH)" > config.sh
	echo $(SED_ALIAS) >> config.sh

osc-api.json:
	curl -s https://raw.githubusercontent.com/outscale/osc-api/$(API_VERSION)/outscale.yaml \
		| yq $(YQ_ARG) > osc-api.json

arguments-list.json: osc-api.json
	$(JSON_SEARCH) -s Request osc-api.json  | $(JSON_SEARCH) -K properties \
	| sed 's/]/ /g' \
	| tr -d "\n[],\"" | sed -r 's/ +/ \n/g' \
	| sort | uniq | tr -d "\n" > arguments-list.json

call_list: osc-api.json bin/funclist
	bin/funclist osc-api.json > call_list


clean:
	rm -vf osc-api.json call_list osc_sdk.c arguments-list.json osc_sdk.h main.c oapi-cli config.sh oapi-cli-completion.bash bin/line_check

.PHONY: clean list_api_version help

