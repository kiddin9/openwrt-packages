'use strict';
'require view.log-viewer.multilog.multilog-abstract as abc';

return abc.view.extend({
	viewName   : 'multilog-secure',
	title      : _('Log') + ' - ' + _('secure'),
	autoRefresh: false,
	logFile    : '/var/log/secure',
});
