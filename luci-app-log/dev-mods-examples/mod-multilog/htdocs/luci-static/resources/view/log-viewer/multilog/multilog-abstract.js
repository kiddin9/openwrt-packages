'use strict';
'require baseclass';
'require fs';
'require view.log-viewer.log-abstract as abc';

return baseclass.extend({
	view: abc.view.extend({
		/**
		 * Log file.
		 *
		 * @property {string} logFile
		 */
		logFile: null,

		getLogHash() {
			return fs.stat(this.logFile).then((data) => {
				return data.mtime || '';
			}).catch(e => {});
		},

		getLogData(tail) {
			return L.resolveDefault(fs.read_direct(this.logFile, 'text'), '');
		},
	}),
});
