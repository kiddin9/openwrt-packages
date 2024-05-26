log = SimpleForm("logview")
log.submit = false
log.reset = false

t = log:field(DummyValue, '', '')
t.rawhtml = true
t.template = 'cloudflarespeedtest/logread'

return log
