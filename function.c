static  int ____snake_func_____data(struct osc_env *e, struct osc_____snake_func_____arg *args, struct osc_str *data)
{
	struct osc_str end_call;
	int ret = 0;
	int count_args = 0;

	(void)count_args; /* if use only query/header and path, this is unused */
	____maybe_query_init____
	osc_init_str(&end_call);
	osc_str_append_string(&end_call, e->endpoint.buf);
	if (!args)
		goto no_data;

	osc_str_append_string(data, "{");
	____construct_data____
	osc_str_append_string(data, "}");

no_data:
	____construct_path____
	____maybe_query_set____
	curl_easy_setopt(e->c, CURLOPT_URL, end_call.buf);
	osc_deinit_str(&end_call);
	return !!ret;
}

int osc_____snake_func____(struct osc_env *e, struct osc_str *out, struct osc_____snake_func_____arg *args)
{
	CURLcode res = CURLE_OUT_OF_MEMORY;
	struct osc_str data;
	int r;

	osc_init_str(&data);
	r = ____snake_func_____data(e, args, &data);
	if (r < 0)
		goto out;

	____curl_set_methode____
	curl_easy_setopt(e->c, CURLOPT_WRITEDATA, out);
	if (e->flag & OSC_VERBOSE_MODE) {
	  printf("<Data send to curl>\n%s\n</Data send to curl>\n", data.buf);
	}
	res = curl_easy_perform(e->c);
	if (res != CURLE_OK)
		goto out;

	long statuscode = 200;
	res = curl_easy_getinfo(e->c, CURLINFO_RESPONSE_CODE, &statuscode);
	if (res != CURLE_OK)
		goto out;

	if (statuscode >= 400)
		res = 1;
out:
	osc_deinit_str(&data);
	return res;
}
