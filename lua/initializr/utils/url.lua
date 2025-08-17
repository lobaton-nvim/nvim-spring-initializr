local M = {}

-- @param str string: the string to encode
-- @return string: the URL-encoded string
function M.urlencode(str)
	return tostring(str):gsub("([^%w%-_%.%~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end)
end

-- @param params table: a table of string keys and values
-- @return string: a URL query string (e.g., "key1=value1&key2=value2")
function M.encode_query(params)
	local query = {}
	for k, v in pairs(params) do
		table.insert(query, string.format("%s=%s", M.urlencode(k), M.urlencode(v)))
	end
	return table.concat(query, "&")
end

return M
