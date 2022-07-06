module crud

import os
import x.json2

const (
	api_filepath = os.getwd() + "/assets/db/apis.json"
)

pub fn read_apis_with_method_alt(method string) ([]string, []string) {
	mut json_file := os.read_file(api_filepath) or { 
		println("[x] Error, Unable to find API database")
		exit(0)
	}

	json_convert := json2.raw_decode(json_file) or { "" }
	all_apis := json_convert.as_map()

	mut api_names := []string{}
	mut api_urls := []string{}

	for key, value in all_apis {
		api_json_info := json2.raw_decode(value.str()) or { "" }
		api_info := api_json_info.as_map()

		if (api_info['api_methods'] or { return api_names, api_urls }).str().contains(method) {
			api_names << key
			api_urls << (api_info['api_url'] or { return api_names, api_urls }).str()
		}
	}

	return api_names, api_urls
}