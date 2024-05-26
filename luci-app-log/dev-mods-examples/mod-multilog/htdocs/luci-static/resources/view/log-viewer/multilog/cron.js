'use strict';
'require view.log-viewer.multilog.multilog-abstract as abc';

return abc.view.extend({
	viewName   : 'multilog-cron',
	title      : _('Log') + ' - ' + _('cron'),
	autoRefresh: false,
	logFile    : '/var/log/cron',
});
