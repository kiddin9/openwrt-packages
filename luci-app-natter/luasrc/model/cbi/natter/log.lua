log = SimpleForm("natter")
log.reset = false
log.submit = false
log:append(Template("natter/natter_log"))

return log
