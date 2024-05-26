'use strict';
'require view.log-viewer.multilog.multilog-abstract as abc';

return abc.view.extend({
	viewName   : 'multilog-maillog',
	title      : _('Log') + ' - ' + _('maillog'),
	autoRefresh: false,
	logFile    : '/var/log/maillog',
});
