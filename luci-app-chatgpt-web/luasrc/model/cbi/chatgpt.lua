-- Copyright (C) 2023 sirpdboy  <herboy2008@gmail.com>  https://github.com/sirpdboy/chatgpt-web.git
require("luci.util")
local m, s

m = Map("chatgpt-web",translate(""))

m:section(SimpleSection).template = "chatgpt-web"

return m
