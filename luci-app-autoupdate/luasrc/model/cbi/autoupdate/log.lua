log = SimpleForm("autoupdate")
log.reset = false
log.submit = false
log:append(Template("autoupdate/autoupdate_log"))

return log
