log = SimpleForm("logview")
log.submit = false
log.reset = false

t = log:field(DummyValue, '', '')
t.rawhtml = true
t.template = 'pikpak-webdav/pikpak-webdav_log'

return log
