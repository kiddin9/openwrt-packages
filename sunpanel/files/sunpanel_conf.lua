local util = require "luci.util"
local tparser = require "luci.template.parser"
local uci = require "luci.model.uci"
local nixio = require "nixio"

local tostring, pairs, loadstring = tostring, pairs, loadstring
local setmetatable, loadfile = setmetatable, loadfile
local getfenv, setfenv, rawget = getfenv, setfenv, rawget
local assert, type, error = assert, type, error

local default_ctx = {tostring = tostring}

local from_string = function(template)
    return Template(default_ctx, nil, template)
end

local from_file = function(template_file)
    return Template(default_ctx, template_file)
end

-- Template class
Template = util.class()

-- Constructor - Reads and compiles the template on-demand
function Template.__init__(self, viewns, name, template)
 if name then
  self.name = name
 else
  self.name = "[string]"
 end

    -- Create a new namespace for this template
 self.viewns = viewns

    -- Compile template
    local err
    local sourcefile

    if name then
        sourcefile = name
        self.template, _, err = tparser.parse(sourcefile)
    else
        sourcefile = "[string]"
        self.template, _, err = tparser.parse_string(template)
    end

    -- If we have no valid template throw error, otherwise cache the template
    if not self.template then
        error("Failed to load template '" .. self.name .. "'.\n" ..
                "Error while parsing template '" .. sourcefile .. "':\n" ..
                (err or "Unknown syntax error"))
    end
end

-- Renders a template
function Template.render(self, scope)

 -- Put our predefined objects in the scope of the template
 setfenv(self.template, setmetatable({}, {__index =
  function(tbl, key)
   return rawget(tbl, key) or self.viewns[key] or scope[key]
  end}))

 -- Now finally render the thing
 local stat, err = util.copcall(self.template)
 if not stat then
  error("Failed to execute template '" .. self.name .. "'.\n" ..
        "A runtime error occurred: " .. tostring(err or "(nil)"))
 end
end

if #arg == 3 then 
  local cur = uci.cursor() 
  local configs = {}
  cur:foreach(arg[1], arg[1], function(s)
    for k, v in pairs(s) do
      configs[k] = v
    end
  end)
  if not nixio.fs.access(arg[2]) then
    print(arg[2] .. " not found")
    os.exit(10)
  end
  local target = io.open(arg[3], "w")
  if not target then
    print(arg[3] .. " can not write")
  end
  configs.write = function(data)
    target:write(data)
  end
  from_file(arg[2]):render(configs)
  target:close()
else
  print("penpot_template.lua [appname] [template-in] [template-out]")
end

