'use strict';
'require view.log-viewer.log-abstract as abc';

return abc.view.extend({
	viewName   : 'dropbear',
	title      : _('Dropbear'),
	autoRefresh: false,
	appPattern : 'dropbear\[[0-9]*\]:',
});
