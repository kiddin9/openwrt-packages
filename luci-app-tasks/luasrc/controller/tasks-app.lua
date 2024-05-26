
module("luci.controller.tasks-app", package.seeall)


function index()
  entry({"admin", "system", "tasks"}, alias("admin", "system", "tasks", "all"), _("Tasks"), 56)
  --entry({"admin", "system", "tasks", "user"}, cbi("tasks/user"), _("User Tasks"), 1)
  entry({"admin", "system", "tasks", "all"}, form("tasks/all"))
end
