log = SimpleForm("natter2")
log.reset = false
log.submit = false
log:append(Template("natter2/natter_log"))

return log
