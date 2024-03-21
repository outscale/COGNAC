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

#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "curl/curl.h"
#include <time.h>
#include <unistd.h>
#include "osc_sdk.h"
#include "json.h"

#define AK_SIZE 20
#define SK_SIZE 40
#define TIMESTAMP_SIZE 17
#define TIME_HDR_KEY "X-Osc-Date: "
#define TIME_HDR_KEY_L (sizeof TIME_HDR_KEY)

#ifdef _WIN32

#define SAFE_C 0

static inline char* stpcpy(char *dest, const char *src)
{
	for (; *src; ++src) {
		*dest++ = *src;
	}
	*dest = 0;
	return dest;
}

#define CFG_FILE "config.json"

#define LOAD_CFG_GET_HOME(buf)			\
	{					\
		strcpy(buf, CFG_FILE);		\
	}
#else

#define CFG_FILE "/.osc/config.json"

#define SAFE_C 1

#endif

#ifdef WITH_DESCRIPTION

static const char *calls_name[] = {
  ____call_list_dec____('\t"'; '",\n '; '\tNULL\n')
};

static const char *calls_descriptions[] = {
  ____call_list_descriptions____('\t'; ',\n'; '\tNULL\n')
};

static const char *calls_args_descriptions[] = {
  ____call_list_args_descriptions____('\t'; ',\n'; '\tNULL\n')
};

const char *osc_find_description(const char *call_name)
{
	const char **c;
	int i = 0;

	for (c = calls_name; *c; ++c) {
		if (!strcmp(*c, call_name))
			return calls_descriptions[i];
		++i;
	}
	return NULL;
}

const char *osc_find_args_description(const char *call_name)
{
	const char **c;
	int i = 0;

	for (c = calls_name; *c; ++c) {
		if (!strcmp(*c, call_name))
			return calls_args_descriptions[i];
		++i;
	}
	return NULL;
}

const char **osc_calls_name(void)
{
	return calls_name;
}

#endif  /* WITH_DESCRIPTION */

#ifdef WITH_C11_THREAD_LOCAL
#define THREAD_LOCAL _Thread_local
#else
#define THREAD_LOCAL
#endif

static THREAD_LOCAL const char *cfg_path;

void osc_set_cfg_path(const char *cfg)
{
	cfg_path = cfg;
}

const char *osc_set_get_path(void)
{
	return cfg_path;
}

void *osc_realloc(void *buf, size_t l)
{
	void *ret = realloc(buf, l);

	if (!ret)
		free(buf);
	return ret;
}

/* We don't use _Bool as we try to be C89 compatible */
int osc_str_append_bool(struct osc_str *osc_str, int bool)
{
	int len = osc_str->len;
	assert(osc_str);

	osc_str->len = len + (bool ? 4 : 5);
	osc_str->buf = osc_realloc(osc_str->buf, osc_str->len + 1);
	if (!osc_str->buf)
		return -1;
	strcpy(osc_str->buf + len, (bool ? "true" : "false"));
	return 0;
}

int osc_str_append_int(struct osc_str *osc_str, int i)
{
	int len = osc_str->len;
	assert(osc_str);

	osc_str->buf = osc_realloc(osc_str->buf, len + 64);
	if (!osc_str->buf)
		return -1;
	osc_str->len = len + snprintf(osc_str->buf + len, 64, "%d", i);
	osc_str->buf[osc_str->len] = 0;
	return 0;
}

int osc_str_append_double(struct osc_str *osc_str, double i)
{
	int len = osc_str->len;
	assert(osc_str);

	osc_str->buf = osc_realloc(osc_str->buf, len + 64);
	if (!osc_str->buf)
		return -1;
	osc_str->len = len + snprintf(osc_str->buf + len, 64, "%f", i);
	osc_str->buf[osc_str->len] = 0;
	return 0;
}

int osc_str_append_string(struct osc_str *osc_str, const char *str)
{
	if (!str)
		return 0;
	assert(osc_str);

	int len = osc_str->len;
	int dlen = strlen(str);

	osc_str->len = osc_str->len + dlen;
	osc_str->buf = osc_realloc(osc_str->buf, osc_str->len + 1);
	if (!osc_str->buf)
		return -1;
	memcpy(osc_str->buf + len, str, dlen + 1);
	return 0;
}

int osc_str_append_n_string(struct osc_str *osc_str, const char *str, int l)
{
	if (!str)
		return 0;
	assert(osc_str);

	int len = osc_str->len;

	osc_str->len = osc_str->len + l;
	osc_str->buf = osc_realloc(osc_str->buf, osc_str->len + 1);
	if (!osc_str->buf)
		return -1;
	memcpy(osc_str->buf + len, str, l);
	osc_str->buf[len + l] = 0;
	return 0;
}

static char *osc_strdup(const char *str) {
	if (!str)
		return NULL;
	return strdup(str);
}

#define TRY(test,  ...)						\
	if (test) { fprintf(stderr, __VA_ARGS__); return -1; }

#define STRY(test,  ...)					\
	if (test) return -1

#define TRY_APPEND_COL(count_args, data)			\
	if (count_args++ > 0)					\
		STRY(osc_str_append_string(data, "," ));

#ifndef LOAD_CFG_GET_HOME
#define LOAD_CFG_GET_HOME(buf)						\
	{								\
		const char *dest = CFG_FILE;				\
		char *home = getenv("HOME");				\
									\
		TRY(strlen(home) + sizeof CFG_FILE > sizeof buf,	\
		    "home path too big");				\
		strcpy(stpcpy(buf, home), dest);			\
	}
#endif

#define ARG_TO_JSON_STR(separator, what) do {				\
		auto_osc_str struct osc_str s;				\
		char *tmp = what;					\
		char *endl;						\
									\
		osc_init_str(&s);					\
		while((endl = strchr(tmp, '\n')) != NULL) {		\
			int l = endl - tmp;				\
									\
			osc_str_append_n_string(&s, tmp, l);		\
			osc_str_append_string(&s, "\\n");		\
			tmp = endl + 1;					\
		}							\
		osc_str_append_string(&s, tmp);				\
		STRY(osc_str_append_string(data, separator));		\
		STRY(osc_str_append_string(data, "\"" ));		\
		STRY(osc_str_append_string(data, s.buf));		\
		STRY(osc_str_append_string(data, "\"" ));		\
	} while (0)

#define ARG_TO_JSON(name, type, what) do {				\
		TRY_APPEND_COL(count_args, data);			\
		STRY(osc_str_append_string(data, "\""#name"\":" ));	\
		STRY(osc_str_append_##type(data, what));		\
	} while (0)


int osc_load_ak_sk_from_conf(const char *profile, char **ak, char **sk)
{
	char buf[1024];
	const char *cfg = cfg_path;
	struct json_object *js, *ak_js, *sk_js;
	auto_osc_json_c struct json_object *to_free = NULL;

	if (!ak && !sk)
		return 0;
	if (!cfg) {
		LOAD_CFG_GET_HOME(buf);
		cfg = buf;
	}
	if (sk)
		*sk = NULL;
	if (ak)
		*ak = NULL;
	TRY(access(cfg, R_OK), "can't open/read %s\n", cfg);
	js = json_object_from_file(cfg);
	TRY(!js, "can't load json-file %s (json might have incorect syntaxe)\n", cfg);
	to_free = js;
	js = json_object_object_get(js, profile);
	TRY(!js, "can't find profile %s\n", profile);
	if (ak) {
		ak_js = json_object_object_get(js, "access_key");
		TRY(!ak_js, "can't find 'access_key' in profile '%s'\n", profile);
		*ak = strdup(json_object_get_string(json_object_object_get(js, "access_key")));
	}
	if (sk) {
		sk_js = json_object_object_get(js, "secret_key");
		TRY(!sk_js, "can't find 'secret_key' in profile '%s'\n", profile);
		*sk = strdup(json_object_get_string(json_object_object_get(js, "secret_key")));
	}
	return 0;
}

int osc_load_loging_password_from_conf(const char *profile,
				       char **email, char **password)
{
	char buf[1024];
	const char *cfg = cfg_path;
	auto_osc_json_c struct json_object *to_free = NULL;
	struct json_object *js, *login_js, *pass_js;

	if (!email && !password)
		return 0;
	if (!cfg) {
		LOAD_CFG_GET_HOME(buf);
		cfg = buf;
	}
	if (password)
		*password = NULL;
	if (email)
		*email = NULL;
	js = json_object_from_file(cfg);
	TRY(!js, "can't open %s\n", cfg);
	to_free = js;
	js = json_object_object_get(js, profile);
	TRY(!js, "can't find profile '%s'\n", profile);
	if (email) {
		login_js = json_object_object_get(js, "login");
		TRY(!login_js, "can't find 'login' in profile '%s'\n", profile);
		*email = osc_strdup(json_object_get_string(login_js));
	}

	if (password) {
		pass_js = json_object_object_get(js, "password");
		if (!pass_js) {
			return 0; /* is optional */
		}
		*password = osc_strdup(json_object_get_string(pass_js));
	}
	return 0;
}

int osc_load_region_from_conf(const char *profile, char **region)
{
	struct json_object *region_obj;
	const char *cfg = cfg_path;
	char buf[1024];
	struct json_object *js;
	auto_osc_json_c struct json_object *to_free = NULL;

	if (!cfg) {
		LOAD_CFG_GET_HOME(buf);
		cfg = buf;
	}
	js = json_object_from_file(cfg);
	TRY(!js, "can't open %s\n", cfg);
	to_free = js;
	js = json_object_object_get(js, profile);
	if (!js)
		return -1;

	region_obj = json_object_object_get(js, "region");
	if (!region_obj) {
		return -1;
	}
	*region = osc_strdup(json_object_get_string(region_obj));
	return 0;
}

int osc_load_cert_from_conf(const char *profile, char **cert, char **key)
{
	struct json_object *cert_obj, *key_obj, *js;
	const char *cfg = cfg_path;
	auto_osc_json_c struct json_object *to_free = NULL;
	char buf[1024];
	int ret = 0;

	if (!cfg) {
		LOAD_CFG_GET_HOME(buf);
		cfg = buf;
	}
	js = json_object_from_file(cfg);
	TRY(!js, "can't open %s\n", cfg);
	to_free = js;
	js = json_object_object_get(js, profile);
	if (!js)
		return 0;

	cert_obj = json_object_object_get(js, "x509_client_cert");
	if (!cert_obj)
		cert_obj = json_object_object_get(js, "client_certificate");
	if (cert_obj) {
		*cert = osc_strdup(json_object_get_string(cert_obj));
		ret |= OSC_ENV_FREE_CERT;
	}

	key_obj = json_object_object_get(js, "x509_client_sslkey");
	if (key_obj) {
		*key = osc_strdup(json_object_get_string(key_obj));
		ret |= OSC_ENV_FREE_SSLKEY;
	}

	return 0;
}

/* Function that will write the data inside a variable */
static size_t write_data(void *data, size_t size, size_t nmemb, void *userp)
{
	size_t bufsize = size * nmemb;
	struct osc_str *response = userp;
	int olen = response->len;

	response->len = response->len + bufsize;
	response->buf = osc_realloc(response->buf, response->len + 1);
	memcpy(response->buf + olen, data, bufsize);
	response->buf[response->len] = 0;
	return bufsize;
}

void osc_init_str(struct osc_str *r)
{
	r->len = 0;
	r->buf = NULL;
}

void osc_deinit_json_c(json_object **j)
{
	if (j && *j)
		json_object_put(*j);
}

void osc_deinit_str(struct osc_str *r)
{
	free(r->buf);
	osc_init_str(r);
}

____complex_struct_to_string_func____

____func_code____


int osc_sdk_set_useragent(struct osc_env *e, const char *str)
{
	return curl_easy_setopt(e->c, CURLOPT_USERAGENT, str);
}

static inline char *cfg_login(struct osc_env_conf *cfg)
{
	if (!cfg)
		return NULL;
	return cfg->login;
}

static inline char *cfg_pass(struct osc_env_conf *cfg)
{
	if (!cfg)
		return NULL;
	return cfg->password;
}

int osc_init_sdk_ext(struct osc_env *e, const char *profile, unsigned int flag,
		     struct osc_env_conf *cfg)
{
	char *ca = getenv("CURL_CA_BUNDLE");
	char *endpoint;
	char user_agent[sizeof "osc-sdk-c/" + OSC_SDK_VERSON_L];
	char *cert = getenv("OSC_X509_CLIENT_CERT");
	char *sslkey = getenv("OSC_X509_CLIENT_KEY");
	char *auth = getenv("OSC_AUTH_METHOD");
	char *force_log = cfg_login(cfg);
	char *force_pass = cfg_pass(cfg);

	strcpy(stpcpy(user_agent, "osc-sdk-c/"), osc_sdk_version_str());
	e->region = getenv("OSC_REGION");
	e->flag = flag;
	e->auth_method = cfg ? cfg->auth_method : OSC_AKSK_METHOD;
	endpoint = getenv("OSC_ENDPOINT_API");
	osc_init_str(&e->endpoint);

	if (auth && (!strcmp(auth, "password") || !strcmp(auth, "basic"))) {
		e->auth_method = OSC_PASSWORD_METHOD;
	} else if (auth && !strcmp(auth, "none")) {
		e->auth_method = OSC_NONE_METHOD;
	} else if (auth && strcmp(auth, "accesskey")) {
		fprintf(stderr, "'%s' invalid authentication method\n", auth);
		return -1;
	}

	if (force_log)
		e->ak = force_log;
	if (force_pass)
		e->sk = force_pass;
	if (!profile && e->auth_method != OSC_NONE_METHOD) {
		profile = getenv("OSC_PROFILE");
		if (e->auth_method == OSC_PASSWORD_METHOD) {
			if (!force_log)
				e->ak = getenv("OSC_LOGIN");
			if (!force_pass)
				e->sk =  getenv("OSC_PASSWORD");
		} else {
			if (!force_log)
				e->ak = getenv("OSC_ACCESS_KEY");
			if (!force_pass)
				e->sk = getenv("OSC_SECRET_KEY");
		}
		if (!profile && (!e->ak || !e->sk))
			profile = "default";
	}

	if (profile && e->auth_method != OSC_NONE_METHOD) {
		int f;

		if (e->auth_method == OSC_PASSWORD_METHOD) {
			STRY(osc_load_loging_password_from_conf(
				    profile, force_log ? NULL : &e->ak,
				    force_pass ? NULL : &e->sk) < 0);
			if (!force_log)
				e->flag |= OSC_ENV_FREE_AK;
			if (!force_pass) {
				if (!e->sk)
					e->sk = getenv("OSC_PASSWORD");
				else
					e->flag |= OSC_ENV_FREE_SK;
			}
		} else {
			STRY(osc_load_ak_sk_from_conf(
				    profile, force_log ? NULL : &e->ak,
				    force_pass ? NULL : &e->sk) < 0);
			if (!force_log)
				e->flag |= OSC_ENV_FREE_AK;
			if (!force_pass)
				e->flag |= OSC_ENV_FREE_SK;
		}
		if (!osc_load_region_from_conf(profile, &e->region))
			e->flag |= OSC_ENV_FREE_REGION;
		f = osc_load_cert_from_conf(profile, &e->cert, &e->sslkey);
		if (f < 0)
			return -1;
		e->flag |= f;
	}

	if (!e->region)
		e->region = "eu-west-2";

	if (!endpoint) {
		osc_str_append_string(&e->endpoint, "https://api.");
		osc_str_append_string(&e->endpoint, e->region);
		osc_str_append_string(&e->endpoint, ".outscale.com");
	} else {
		osc_str_append_string(&e->endpoint, endpoint);
	}

	if (e->auth_method == OSC_AKSK_METHOD) {
		if (!e->ak || !e->sk) {
			fprintf(stderr, "access key and secret key needed\n");
			return -1;
		}

		if (strlen(e->ak) != AK_SIZE || strlen(e->sk) != SK_SIZE) {
			fprintf(stderr, "Wrong access key or secret key size\n");
			return -1;
		}
	} else if (e->auth_method == OSC_PASSWORD_METHOD) {
		if (!e->ak || !e->sk) {
			fprintf(stderr, "login and password needed\n");
			return -1;
		}
	}

	e->headers = NULL;
	e->c = curl_easy_init();

	#ifdef _WIN32
	curl_easy_setopt(e->c, CURLOPT_SSL_OPTIONS, (long)CURLSSLOPT_NATIVE_CA);
	#endif

	/* Setting HEADERS */
	if (flag & OSC_VERBOSE_MODE)
		curl_easy_setopt(e->c, CURLOPT_VERBOSE, 1);
	if (flag & OSC_INSECURE_MODE)
		curl_easy_setopt(e->c, CURLOPT_SSL_VERIFYPEER, 0);
	if (cert)
		curl_easy_setopt(e->c, CURLOPT_SSLCERT, cert);
	if (sslkey)
		curl_easy_setopt(e->c, CURLOPT_SSLKEY, sslkey);
	curl_easy_setopt(e->c, CURLOPT_WRITEFUNCTION, write_data);
	curl_easy_setopt(e->c, CURLOPT_USERAGENT, user_agent);

	/* setting CA if CURL_CA_BUNDLE is set */
	if (ca)
	  curl_easy_setopt(e->c, CURLOPT_CAINFO, ca);

	e->headers = curl_slist_append(e->headers, "Content-Type: application/json");

	/* For authentification we specify the method and our acces key / secret key */
	if (e->auth_method == OSC_AKSK_METHOD) {
		curl_easy_setopt(e->c, CURLOPT_AWS_SIGV4, "osc");
	} else if (e->auth_method == OSC_PASSWORD_METHOD) {
		time_t clock;
		struct tm tm;
		struct tm *tmp;
		char time_hdr[TIME_HDR_KEY_L + TIMESTAMP_SIZE] = TIME_HDR_KEY;

		time(&clock);
#if SAFE_C == 1
		TRY(!gmtime_r(&clock, &tm), "gmtime_r fail\n");\
		tmp = &tm;
#else
		(void)tm;
		tmp = gmtime(&clock);
		TRY(!tmp, "gmtime fail\n");
#endif
		strftime(time_hdr + TIME_HDR_KEY_L - 1,
			 TIMESTAMP_SIZE, "%Y%m%dT%H%M%SZ", tmp);
		e->headers = curl_slist_append(e->headers, time_hdr);
	}
	curl_easy_setopt(e->c, CURLOPT_HTTPHEADER, e->headers);

	if (e->auth_method != OSC_NONE_METHOD) {
		curl_easy_setopt(e->c, CURLOPT_USERNAME, e->ak);
		curl_easy_setopt(e->c, CURLOPT_PASSWORD, e->sk);
	}

	return 0;
}

int osc_init_sdk(struct osc_env *e, const char *profile, unsigned int flag)
{
	return osc_init_sdk_ext(e, profile, flag, NULL);
}

void osc_deinit_sdk(struct osc_env *e)
{
	curl_slist_free_all(e->headers);
	curl_easy_cleanup(e->c);
	osc_deinit_str(&e->endpoint);
	if (e->flag & OSC_ENV_FREE_AK) {
		free(e->ak);
		e->ak = NULL;
	}
	if (e->flag & OSC_ENV_FREE_SK) {
		free(e->sk);
		e->sk = NULL;
	}
	if (e->flag & OSC_ENV_FREE_REGION) {
		free(e->region);
		e->region = NULL;
	}

	if (e->flag & OSC_ENV_FREE_CERT) {
		free(e->cert);
	}
	if (e->flag & OSC_ENV_FREE_SSLKEY) {
		free(e->sslkey);
	}

	e->c = NULL;
	e->flag = 0;
}
