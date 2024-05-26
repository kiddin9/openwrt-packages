'use strict';
'require baseclass';
'require ui';
'require view.log-viewer.log-base as base';

document.head.append(E('style', {'type': 'text/css'},
`
:root {
	--app-log-entry-outline-color: #ccc;
}
:root[data-darkmode="true"] {
	--app-log-entry-outline-color: #555;
}
#log-area {
	width: 100%;
	height: 100%;
	margin-bottom: 1em;
}
.log-entry-line {
	display: inline-block;
	text-indent: 8px;
	margin: 0 0 1px 0;
	padding: 0 4px;
	-webkit-border-radius: 3px;
	-moz-border-radius: 3px;
	border-radius: 3px;
	border: 1px solid var(--app-log-entry-outline-color);
	font-weight: normal;
	/*font-size: 12px !important;*/
	font-family: monospace !important;
	white-space: pre-wrap !important;
	overflow-wrap: anywhere !important;
}
`));

return baseclass.extend({
	view: base.view.extend({

		filterHighlightFunc(match) {
			return `<span class="log-highlight-item">${match}</span>`;
		},

		padNumber(number, lengthFirst, lengthLast) {
			let length = Math.max(lengthFirst, lengthLast);
			try {
				number = String(number).padStart(length, ' ');
			} catch(e) {
				if(e.name != 'TypeError') {
					throw e;
				};
			};
			return number;
		},

		makeLogArea(logdataArray) {
			let lines   = `<span class="log-entry-line center" style="width:100%">${_('No entries available...')}</span>`;
			let logArea = E('div', { 'id': 'log-area' });

			for(let level of Object.keys(this.logLevels)) {
				this.logLevelsStat[level] = 0;
			};

			let logdataArrayLen = logdataArray.length;

			if(logdataArray.length > 0) {
				lines = [];
				let firstNumLength = String(logdataArray[0][0]).length;
				let lastNumLength  = String(logdataArray[logdataArrayLen - 1][0]).length;
				logdataArray.forEach((e, i) => {
					if(e[4] in this.logLevels) {
						this.logLevelsStat[e[4]] = this.logLevelsStat[e[4]] + 1;
					};
					e[0] = this.padNumber(e[0], firstNumLength, lastNumLength);
					if(e[5]) {
						e[5] = `&#9;${e[5]}`;
					};
					lines.push(
						`<span class="log-entry-line log-${e[4] || 'empty'}">` +
						e.filter(i => (i)).join(' ') +
						'</span>'
					);
				});
				lines = lines.join('<br />');
			};

			try {
				logArea.insertAdjacentHTML('beforeend', lines);
			} catch(err) {
				if(err.name === 'SyntaxError') {
					ui.addNotification(null,
						E('p', {}, _('HTML/XML error') + ': ' + err.message), 'error');
				};
				throw err;
			};

			let levelsStatString = '';
			if((Object.values(this.logLevelsStat).reduce((s,c) => s + c, 0)) > 0) {
				Object.entries(this.logLevelsStat).forEach(e => {
					if(e[0] in this.logLevels && e[1] > 0) {
						levelsStatString += `<span class="log-entries-count-level log-${e[0]}" title="${e[0]}">${e[1]}</span>`;
					};
				});
			};

			return E([
				E('div', { 'class': 'log-entries-count' },
					`${_('Entries')}: ${logdataArray.length} / ${this.totalLogLines}${levelsStatString}`
				),
				logArea,
			]);
		},
	}),
});
