'use strict';
'require fs';
'require rpc';
'require ui';
'require view.log-viewer.log-widget as widget';

return widget.view.extend({
	viewName      : 'dmesg',

	title         : _('Kernel Log'),

	autoRefresh   : true,

	entryRegexp   : new RegExp(/^<(\d{1,2})>\[([\d\s.]+)\]\s+(.*)$/),

	facilityName  : [
		'kern',
		'user',
		'mail',
		'daemon',
		'auth',
		'syslog',
		'lpr',
		'news',
	],

	localtime     : null,

	uptime        : null,

	days          : {
		0: 'Sun',
		1: 'Mon',
		2: 'Tue',
		3: 'Wed',
		4: 'Thu',
		5: 'Fri',
		6: 'Sat',
		7: 'Sun',
	},

	months        : {
		1:  'Jan',
		2:  'Feb',
		3:  'Mar',
		4:  'Apr',
		5:  'May',
		6:  'Jun',
		7:  'Jul',
		8:  'Aug',
		9:  'Sep',
		10: 'Oct',
		11: 'Nov',
		12: 'Dec',
	},

	callLogHash: rpc.declare({
		object: 'luci.log-viewer',
		method: 'getDmesgHash',
		expect: { '': {} }
	}),

	callSystemInfo: rpc.declare({
		object: 'system',
		method: 'info'
	}),

	getLogHash() {
		return this.callLogHash().then(data => {
			return data.hash || '';
		});
	},

	calcDmesgDate(t) {
		if(!this.localtime || !this.uptime) {
			return t;
		};
		let date = new Date((this.localtime - this.uptime + t) * 1000);
		return '%s %s %d %02d:%02d:%02d %d'.format(
			this.days[ date.getUTCDay() ],
			this.months[ date.getUTCMonth() + 1 ],
			date.getUTCDate(),
			date.getUTCHours(),
			date.getUTCMinutes(),
			date.getUTCSeconds(),
			date.getUTCFullYear()
		);
	},

	async getLogData(tail) {
		await this.callSystemInfo().then(s => {
			this.localtime = s.localtime;
			this.uptime    = s.uptime;
		}).catch(err => {});
		return fs.exec_direct('/bin/dmesg', [ '-r' ], 'text').catch(err => {
			throw new Error(_('Unable to load log data:') + ' ' + err.message);
		});
	},

	parseLogData(logdata, tail) {
		if(!logdata) {
			return [];
		};

		let unsupportedLog = false;
		this.isFacilities  = true;
		this.isLevels      = true;

		let strings = logdata.trim().split(/\n/);

		if(tail && tail > 0 && strings) {
			strings = strings.slice(-tail);
		};

		this.totalLogLines = strings.length;

		let entriesArray = strings.map((e, i) => {
			let logLevelsTranslate = Object.keys(this.logLevels);
			let strArray           = e.match(this.entryRegexp);
			if(strArray) {
				let level    = 0;
				let facility = 0;
				if(strArray[1].length > 1) {
					let fieldArray = Number(strArray[1]).toString(8).split('');
					level          = logLevelsTranslate[Number(fieldArray[1])];
					facility       = Number(fieldArray[0]);
				} else {
					level = logLevelsTranslate[Number(strArray[1]).toString(8)];
				};
				return [
					i + 1,                                          // #         (Number)
					this.calcDmesgDate(Number(strArray[2].trim())), // Timestamp (String)
					null,                                           // Host      (String)
					this.facilityName[ facility ],                  // Facility  (String)
					level,                                          // Level     (String)
					this.htmlEntities(strArray[3]) || ' ',          // Message   (String)
				];
			} else {
				unsupportedLog = true;
				return;
			};
		});

		if(unsupportedLog) {
			throw new Error(_('Unable to load log data:') + ' ' + _('Unsupported log format'));
		} else {
			if(this.logSortingValue === 'desc') {
				entriesArray.reverse();
			};
			return entriesArray;
		};
	},
});
