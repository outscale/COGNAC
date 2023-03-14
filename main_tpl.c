/**
 * BSD 3-Clause License
 *
 * Copyright (c) 2022, Outscale SAS
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

 /*
  * This code is autogenerated, don't edit it directely
  */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "json.h"
#include "osc_sdk.h"
#include "main-helper.h"

#ifndef JSON_C_TO_STRING_COLOR
#define JSON_C_TO_STRING_COLOR 0
#endif

#define OAPI_RAW_OUTPUT 1

#define OAPI_CLI_UAGENT "oapi-cli/0.1.0; osc-sdk-c/"

#define TRY(f, args...)						\
	do {							\
		if (f) {fprintf(stderr, args);  return 1;}	\
	} while(0)

static int argcmp2(const char *s1, const char *s2, char dst)
{
	while (*s1 == *s2 && *s1 && *s2) {
		s1++;
		s2++;
	}
	if ((*s2 == dst && *s1 == '\0') ||
	    (*s1 == dst && *s2 == '\0'))
		return 0;
	return *s1 != *s2;
}

static int argcmp(const char *s1, const char *s2)
{
	return argcmp2(s1, s2, '.');
}

static void *cascade_struct;
static int (*cascade_parser)(void *, char *, char *, struct ptr_array *);

____complex_struct_func_parser____


static int str_profile_to_int(const char *str)
{
	if (!strcmp(str, "password") || !strcmp(str, "basic"))
		return OSC_PASSWORD_METHOD;
	else if (!strcmp(str, "none"))
		return OSC_NONE_METHOD;
	else if (!strcmp(str, "accesskey"))
		return OSC_AKSK_METHOD;
	return -1;
}

int main(int ac, char **av)
{
	auto_osc_env struct osc_env e = {0};
	auto_osc_str struct osc_str r = {0};
	int color_flag = 0;
	int i;
	char *help_appent = getenv("COGNAC_HELP_APPEND");
	unsigned int flag = 0;
	unsigned int program_flag = 0;
	char *program_name = strrchr(av[0], '/');
	char *profile = NULL;
	char *login = NULL;
	char *password = NULL;
	int auth_m = OSC_AKSK_METHOD;
	int ret = 1;

	if (!program_name)
		program_name = av[0];
	else
		++program_name;

	for (i = 1; i < ac; ++i) {
		if (!strcmp("--verbose", av[i])) {
		  flag |= OSC_VERBOSE_MODE;
		} else if (!strcmp("--insecure", av[i])) {
		  flag |= OSC_INSECURE_MODE;
		} else if (!strcmp("--raw-print", av[i])) {
		  flag |= OAPI_RAW_OUTPUT;
		} else if (!strcmp("--raw-print", av[i])) {
		  flag |= OAPI_RAW_OUTPUT;
		} else if (!argcmp2("--authentication_method", av[i], '=')) {
			const char *auth_str;
			if (av[i][sizeof("--authentication_method") - 1] == '=') {
				auth_str = &av[i][sizeof("--authentication_method")];
			} else if (!av[i][sizeof("--authentication_method") - 1]) {
				TRY(!av[i+1], "-- need an authentication_method\n");
				auth_str = av[i+1];
				++i;
			} else {
				fprintf(stderr, "--authentication_method seems weirds\n");
				return 1;
			}
			auth_m = str_profile_to_int(auth_str);
			TRY(auth_m < 0, "%s unknow authentication_method\n", auth_str);
		} else if (!argcmp2("--config", av[i], '=')) {
			const char *cfg_str;
			if (av[i][sizeof("--config") - 1] == '=') {
				cfg_str = &av[i][sizeof("--config")];
			} else if (!av[i][sizeof("--config") - 1]) {
				TRY(!av[i+1], "--config need a path\n");
				cfg_str = av[i+1];
				++i;
			} else {
				fprintf(stderr, "--config seems weirds\n");
				return 1;
			}
			osc_set_cfg_path(cfg_str);
		} else if (!argcmp2("--profile", av[i], '=')) {
			if (av[i][sizeof("--profile") - 1] == '=') {
				profile = &av[i][sizeof("--profile")];
			} else if (!av[i][sizeof("--profile") - 1]) {
				TRY(!av[i+1], "--profile need a profile");
				profile = av[i+1];
				++i;
			} else {
				fprintf(stderr, "--profile seems weirds");
				return 1;
			}
		} else if (!argcmp2("--password", av[i], '=')) {
			if (av[i][sizeof("--password") - 1] == '=') {
				password = &av[i][sizeof("--password")];
			} else if (!av[i][sizeof("--password") - 1]) {
				TRY(!av[i+1], "--password need a password");
				password = av[i+1];
				++i;
			} else {
				fprintf(stderr, "--password seems weirds");
				return 1;
			}
		} else if (!argcmp2("--login", av[i], '=')) {
			if (av[i][sizeof("--login") - 1] == '=') {
				login = &av[i][sizeof("--login")];
			} else if (!av[i][sizeof("--login") - 1]) {
				TRY(!av[i+1], "--login need a login");
				login = av[i+1];
				++i;
			} else {
				fprintf(stderr, "--login seems weirds");
				return 1;
			}
		}
	}

	if (login || password)
		auth_m = OSC_PASSWORD_METHOD;

	if (ac < 2 || (ac == 2 && !strcmp(av[1], "--help"))) {
	show_help:
		printf("Usage: %s [--help] CallName [options] [--Params ParamArgument]\n"
		       "options:\n"
		       "\t--insecure	\tdoesn't verify SSL certificats\n"
		       "\t--raw-print	\tdoesn't format the output\n"
		       "\t--config=PATH		\tconfig file path\n"
		       "\t--authentication_method=METHODE\tset authentification method,  password|accesskey|none\n"
		       "\t--verbose	\tcurl backend is now verbose\n"
		       "\t--profile=PROFILE	\tselect profile\n"
		       "\t--login=EMAIL		\tset email, and authentification as password\n"
		       "\t--password=PASS	\tset password, and authentification as password\n"
		       "\t--help [CallName]\tthis, can be used with call name, example:\n\t\t\t\t%s --help ReadVms\n"
		       "\t--color	\t\ttry to colorize json if json-c support it\n%s%s",
		       program_name, program_name, help_appent ? help_appent : "",
		       help_appent ? "\n" : "");
		return 0;
	}

	TRY(osc_init_sdk_ext(&e, profile, flag,
			     &(struct osc_env_conf){
				     .auth_method=auth_m,
				     .password=password,
				     .login=login
			     }),
	    "fail to init C sdk\n");
	osc_init_str(&r);

	char user_agent[OSC_SDK_VERSON_L + sizeof OAPI_CLI_UAGENT] =
		OAPI_CLI_UAGENT;

	strcpy(user_agent + sizeof OAPI_CLI_UAGENT - 1, osc_sdk_version_str());
	osc_sdk_set_useragent(&e, user_agent);

	for (i = 1; i < ac; ++i) {
		if (!strcmp("--verbose", av[i]) ||		\
		    !strcmp("--insecure", av[i]) ||		\
		    !strcmp("--raw-print", av[i])) {
			/* Avoid Unknow Calls */
		} else if (!argcmp2("--profile", av[i], '=')) {
			if (!av[i][sizeof("--profile") - 1]) {
				++i;
			}
		} else if (!argcmp2("--authentication_method", av[i], '=')) {
			if (!av[i][sizeof("--authentication_method") - 1]) {
				++i;
			}
		} else if (!argcmp2("--config", av[i], '=')) {
			if (!av[i][sizeof("--config") - 1]) {
				++i;
			}
		} else if (!argcmp2("--password", av[i], '=')) {
			if (!av[i][sizeof("--password") - 1]) {
				++i;
			}
		} else if (!argcmp2("--login", av[i], '=')) {
			if (!av[i][sizeof("--login") - 1]) {
				++i;
			}
		} else if (!strcmp("--help", av[i])) {
			if (av[i+1]) {
				const char *cd = osc_find_description(av[i+1]);
				const char *cad = osc_find_args_description(av[i+1]);
				if (cd) {
					puts(cd);
					puts("Arguments Description:");
					puts(cad);
					goto good;
				} else {
					printf("Unknow Call %s\n", av[i+1]);
					goto out;
				}
			}
			goto show_help;
		} else if (!strcmp("--color", av[i])) {
			color_flag |= JSON_C_TO_STRING_COLOR;
		} else
		____cli_parser____
		{
			printf("Unknow Call %s\n", av[i]);
			ret = 1;
			goto out;
		}
	}
good:
	ret = 0;
out:
	return ret;
}
