'use strict';
'require poll';
'require baseclass';
'require ui';
'require view';

document.head.append(E('style', {'type': 'text/css'},
`
:root {
	--app-log-dark-font-color: #2e2e2e;
	--app-log-light-font-color: #fff;
	--app-log-debug-font-color: #737373;
	--app-log-emerg-color: #a93734;
	--app-log-alert: #ff7968;
	--app-log-crit: #fcc3bf;
	--app-log-err: #ffe9e8;
	--app-log-warn: #fff7e2;
	--app-log-notice: #e3ffec;
	--app-log-info: rgba(0,0,0,0);
	--app-log-debug: #ebf6ff;
	--app-log-entries-count-border: #ccc;
}
:root[data-darkmode="true"] {
	--app-log-dark-font-color: #fff;
	--app-log-light-font-color: #fff;
	--app-log-debug-font-color: #e7e7e7;
	--app-log-emerg-color: #a93734;
	--app-log-alert: #eb5050;
	--app-log-crit: #dc7f79;
	--app-log-err: #c89593;
	--app-log-warn: #8d7000;
	--app-log-notice: #007627;
	--app-log-info: rgba(0,0,0,0);
	--app-log-debug: #5986b1;
	--app-log-entries-count-border: #555;
}
#logWrapper {
	overflow: auto !important;
	width: 100%;
	min-height: 20em';
}
.log-empty {
}
.log-emerg {
	background-color: var(--app-log-emerg-color) !important;
	color: var(--app-log-light-font-color);
}
log-emerg .td {
	color: var(--app-log-light-font-color) !important;
}
log-emerg td {
	color: var(--app-log-light-font-color) !important;
}
.log-alert {
	background-color: var(--app-log-alert) !important;
	color: var(--app-log-light-font-color);
}
.log-alert .td {
	color: var(--app-log-light-font-color) !important;
}
.log-alert td {
	color: var(--app-log-light-font-color) !important;
}
.log-crit {
	background-color: var(--app-log-crit) !important;
	color: var(--app-log-dark-font-color) !important;
}
.log-crit .td {
	color: var(--app-log-dark-font-color) !important;
}
.log-crit td {
	color: var(--app-log-dark-font-color) !important;
}
.log-err {
	background-color: var(--app-log-err) !important;
	color: var(--app-log-dark-font-color) !important;
}
.log-err .td {
	color: var(--app-log-dark-font-color) !important;
}
.log-err td {
	color: var(--app-log-dark-font-color) !important;
}
.log-warn {
	background-color: var(--app-log-warn) !important;
	color: var(--app-log-dark-font-color) !important;
}
.log-warn .td {
	color: var(--app-log-dark-font-color) !important;
}
.log-warn td {
	color: var(--app-log-dark-font-color) !important;
}
.log-notice {
	background-color: var(--app-log-notice) !important;
	color: var(--app-log-dark-font-color) !important;
}
.log-notice .td {
	color: var(--app-log-dark-font-color) !important;
}
.log-notice td {
	color: var(--app-log-dark-font-color) !important;
}
.log-info {
	background-color: var(--app-log-info) !important;
	/*color: var(--app-log-dark-font-color) !important;*/
}
.log-debug {
	background-color: var(--app-log-debug) !important;
	color: var(--app-log-debug-font-color) !important;
}
.log-debug .td {
	color: var(--app-log-debug-font-color) !important;
}
.log-debug td {
	color: var(--app-log-debug-font-color) !important;
}
.log-highlight-item {
	background-color: #ffef00;
	color: #2e2e2e;
}
.log-entries-count {
	margin: 0 0 5px 5px;
	font-weight: bold;
	opacity: 0.7;
}
.log-entries-count-level {
	display: inline-block !important;
	margin: 0 0 0 5px;
	padding: 0 4px;
	-webkit-border-radius: 3px;
	-moz-border-radius: 3px;
	border-radius: 3px;
	border: 1px solid var(--app-log-entries-count-border);
	font-weight: normal;
}
.log-host-dropdown-item {
}
.log-facility-dropdown-item {
}
.log-side-block {
	position: fixed;
	z-index: 1 !important;
	opacity: 0.7;
	right: 1px;
	top: 40vh;
}
.log-side-btn {
	position: relative;
	display: block;
	left: 1px;
	top: 1px;
	margin: 0 !important;
	min-width: 3.2em;
}
`));

return baseclass.extend({
	view: view.extend({
		/**
		 * View name (for local storage and downloads).
		 *
		 * @property {string} viewName
		 */
		viewName         : null,

		/**
		 * Page title.
		 *
		 * @property {string} title
		 */
		title            : null,

		/**
		 * Enable auto refresh log.
		 *
		 * @property {bool} autoRefresh
		 */
		autoRefresh      : false,

		pollInterval     : L.env.pollinterval,

		logFacilities    : {
			'kern'    : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'kern')),
			'user'    : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'user')),
			'mail'    : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'mail')),
			'daemon'  : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'daemon')),
			'auth'    : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'auth')),
			'syslog'  : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'syslog')),
			'lpr'     : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'lpr')),
			'news'    : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'news')),
			'uucp'    : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'uucp')),
			'authpriv': E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'authpriv')),
			'ftp'     : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'ftp')),
			'ntp'     : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'ntp')),
			'log'     : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'log')),
			'clock'   : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'clock')),
			'local0'  : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'local0')),
			'local1'  : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'local1')),
			'local2'  : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'local2')),
			'local3'  : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'local3')),
			'local4'  : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'local4')),
			'local5'  : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'local5')),
			'local6'  : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'local6')),
			'local7'  : E('span', { 'class': 'zonebadge log-facility-dropdown-item' }, E('strong', 'local7')),
		},

		logLevels        : {
			'emerg' : E('span', { 'class': 'zonebadge log-emerg' }, E('strong', _('Emergency'))),
			'alert' : E('span', { 'class': 'zonebadge log-alert' }, E('strong', _('Alert'))),
			'crit'  : E('span', { 'class': 'zonebadge log-crit' }, E('strong', _('Critical'))),
			'err'   : E('span', { 'class': 'zonebadge log-err' }, E('strong', _('Error'))),
			'warn'  : E('span', { 'class': 'zonebadge log-warn' }, E('strong', _('Warning'))),
			'notice': E('span', { 'class': 'zonebadge log-notice' }, E('strong', _('Notice'))),
			'info'  : E('span', { 'class': 'zonebadge log-info' }, E('strong', _('Info'))),
			'debug' : E('span', { 'class': 'zonebadge log-debug' }, E('strong', _('Debug'))),
		},

		tailValue            : 25,

		fastTailIncrement    : 50,

		fastTailValue        : null,

		timeFilterValue      : null,

		timeFilterReValue    : false,

		hostFilterValue      : [],

		facilityFilterValue  : [],

		levelFilterValue     : [],

		msgFilterValue       : null,

		msgFilterReValue     : false,

		logSortingValue      : 'asc',

		autoRefreshValue     : true,

		isAutorefresh        : true,

		isHosts              : false,

		isFacilities         : false,

		isLevels             : false,

		logHosts             : {},

		logLevelsStat        : {},

		logHostsDropdown     : null,

		logFacilitiesDropdown: null,

		logLevelsDropdown    : null,

		totalLogLines        : 0,

		lastHash            : null,

		actionButtons        : [],

		htmlEntities(str) {
			return String(str).replace(
				/&/g, '&#38;').replace(
				/</g, '&#60;').replace(
				/>/g, '&#62;').replace(
				/"/g, '&#34;').replace(
				/'/g, '&#39;');
		},

		checkZeroValue(value) {
			return (/^[0-9]+$/.test(value)) ? value : 0
		},

		makeLogHostsDropdownItem(host) {
			return E(
				'span',
				{ 'class': 'zonebadge log-host-dropdown-item' },
				E('strong', host)
			);
		},

		makeLogHostsDropdownSection() {
			this.logHostsDropdown = new ui.Dropdown(
				null,
				this.logHosts,
				{
					id                : 'logHostsDropdown',
					multiple          : true,
					select_placeholder: _('All'),
				}
			);
			return E(
				'div', { 'class': 'cbi-value' }, [
					E('label', {
						'class': 'cbi-value-title',
						'for'  : 'logHostsDropdown',
					}, _('Hosts')),
					E('div', { 'class': 'cbi-value-field' },
						this.logHostsDropdown.render()
					),
				]
			);
		},

		makeLogFacilitiesDropdownSection() {
			this.logFacilitiesDropdown = new ui.Dropdown(
				null,
				this.logFacilities,
				{
					id                : 'logFacilitiesDropdown',
					sort              : Object.keys(this.logFacilities),
					multiple          : true,
					select_placeholder: _('All'),
				}
			);
			return E(
				'div', { 'class': 'cbi-value' }, [
					E('label', {
						'class': 'cbi-value-title',
						'for'  : 'logFacilitiesDropdown',
					}, _('Facilities')),
					E('div', { 'class': 'cbi-value-field' },
						this.logFacilitiesDropdown.render()
					),
				]
			);
		},

		makeLogLevelsDropdownSection() {
			this.logLevelsDropdown = new ui.Dropdown(
				null,
				this.logLevels,
				{
					id                : 'logLevelsDropdown',
					sort              : Object.keys(this.logLevels),
					multiple          : true,
					select_placeholder: _('All'),
				}
			);
			return E(
				'div', { 'class': 'cbi-value' }, [
					E('label', {
						'class': 'cbi-value-title',
						'for'  : 'logLevelsDropdown',
					}, _('Logging levels')),
					E('div', { 'class': 'cbi-value-field' },
						this.logLevelsDropdown.render()
					),
				]
			);
		},

		setRegexpValidator(elem, flag) {
			ui.addValidator(
				elem,
				'string',
				true,
				v => {
					if(!flag.checked) {
						return true;
					};
					try {
						new RegExp(v, 'giu');
						return true;
					} catch(err) {
						return _('Invalid regular expression') + ':\n' + err.message;
					};
				},
				'blur',
				'focus',
				'input'
			);
		},

		setFilterSettings() {
			this.tailValue         = this.checkZeroValue(this.tailInput.value);
			this.timeFilterValue   = this.timeFilter.value;
			this.timeFilterReValue = this.timeFilterRe.checked;
			if(this.isHosts) {
				this.hostFilterValue = this.logHostsDropdown.getValue();
			};
			if(this.isFacilities) {
				this.facilityFilterValue = this.logFacilitiesDropdown.getValue();
			};
			if(this.isLevels) {
				this.levelFilterValue = this.logLevelsDropdown.getValue();
			};
			this.msgFilterValue      = this.msgFilter.value;
			this.msgFilterReValue    = this.msgFilterRe.checked;
			this.logSortingValue     = this.logSorting.value;
			this.autoRefreshValue    = this.autoRefresh.checked;
			if(this.isAutorefresh) {
				if(this.autoRefreshValue) {
					poll.add(this.pollFuncWrapper, this.pollInterval);
					this.refreshBtn.style.visibility = 'hidden';
				} else {
					poll.remove(this.pollFuncWrapper);
					this.refreshBtn.style.visibility = 'visible';
				};
			};
		},

		resetFormValues() {
			this.tailInput.value      = this.tailValue;
			this.timeFilter.value     = this.timeFilterValue;
			this.timeFilterRe.checked = this.timeFilterReValue;
			if(this.isHosts) {
				this.logHostsDropdown.setValue(this.hostFilterValue);
			};
			if(this.isFacilities) {
				this.logFacilitiesDropdown.setValue(this.facilityFilterValue);
			};
			if(this.isLevels) {
				this.logLevelsDropdown.setValue(this.levelFilterValue);
			};
			this.msgFilter.value     = this.msgFilterValue;
			this.msgFilterRe.checked = this.msgFilterReValue;
			this.logSorting.value    = this.logSortingValue;
			this.autoRefresh.checked = this.autoRefreshValue;
		},

		/**
		 * Receives raw log data.
		 * Abstract method, must be overridden by a subclass!
		 *
		 * @instance
		 * @abstract
		 *
		 * @param {number} tail
		 * @returns {string}
		 * Returns the raw content of the log.
		 */
		getLogData(tail) {
			throw new Error('getLogData must be overridden by a subclass');
		},

		/**
		 * Parses log data.
		 * Abstract method, must be overridden by a subclass!
		 *
		 * @instance
		 * @abstract
		 *
		 * @param {string} logdata
		 * @param {number} tail
		 * @returns {Array<number, string|null, string|null, string|null, string|null, string|null>}
		 * Returns an array of values: [ #, Timestamp, Host, Facility, Level, Message ].
		 */
		parseLogData(logdata, tail) {
			throw new Error('parseLogData must be overridden by a subclass');
		},

		/**
		 * Highlights the search result for a pattern.
		 * Abstract method, must be overridden by a subclass!
		 *
		 * To disable the highlight option, views extending
		 * this base class should overwrite the `filterHighlightFunc`
		 * function with `null`.
		 *
		 * @instance
		 * @abstract
		 *
		 * @param {string} logdata
		 * @returns {string}
		 * Returns a string with the highlighted part.
		 */
		filterHighlightFunc(match) {
			throw new Error('filterHighlightFunc must be overridden by a subclass');
		},

		setStringFilter(entriesArray, fieldNum, pattern) {
			let fArr = [];
			entriesArray.forEach((e, i) => {
				if(e[fieldNum] !== null && e[fieldNum].includes(pattern)) {
					if(typeof(this.filterHighlightFunc) == 'function') {
						e[fieldNum] = e[fieldNum].replace(pattern, this.filterHighlightFunc);
					};
					fArr.push(e);
				};
			});
			return fArr;
		},

		setRegexpFilter(entriesArray, fieldNum, pattern, formElem) {
			let fArr = [];
			try {
				let regExp = new RegExp(pattern, 'giu');
				entriesArray.forEach((e, i) => {
					if(e[fieldNum] !== null && regExp.test(e[fieldNum])) {
						if(this.filterHighlightFunc) {
							e[fieldNum] = e[fieldNum].replace(regExp, this.filterHighlightFunc);
						};
						fArr.push(e);
					};
					regExp.lastIndex = 0;
				});
			} catch(err) {
				if(err.name === 'SyntaxError') {
					ui.addNotification(null,
						E('p', {}, _('Invalid regular expression') + ': ' + err.message));
					return entriesArray;
				} else {
					throw err;
				};
			};
			return fArr;
		},

		setTimeFilter(entriesArray) {
			let fPattern = this.timeFilterValue;
			if(!fPattern) {
				return entriesArray;
			};
			return (this.timeFilterReValue) ?
				this.setRegexpFilter(entriesArray, 1, fPattern, this.timeFilter) :
					this.setStringFilter(entriesArray, 1, fPattern);
		},

		setHostFilter(entriesArray) {
			let logHostsKeys = Object.keys(this.logHosts);
			if(logHostsKeys.length > 0 && this.logHostsDropdown) {
				this.logHostsDropdown.addChoices(logHostsKeys, this.logHosts);
				if(this.hostFilterValue.length === 0 || logHostsKeys.length === this.hostFilterValue.length) {
					return entriesArray;
				};
				return entriesArray.filter(e => this.hostFilterValue.includes(e[2]));
			};
			return entriesArray;
		},

		setFacilityFilter(entriesArray) {
			let logFacilitiesKeys = Object.keys(this.logFacilities);
			if(logFacilitiesKeys.length > 0 && this.logFacilitiesDropdown) {
				if(this.facilityFilterValue.length === 0 || logFacilitiesKeys.length === this.facilityFilterValue.length) {
					return entriesArray;
				};
				return entriesArray.filter(e => this.facilityFilterValue.includes(e[3]));
			};
			return entriesArray;
		},

		setLevelFilter(entriesArray) {
			let logLevelsKeys = Object.keys(this.logLevels);
			if(logLevelsKeys.length > 0 && this.logLevelsDropdown) {
				if(this.levelFilterValue.length === 0 || logLevelsKeys.length === this.levelFilterValue.length) {
					return entriesArray;
				};
				return entriesArray.filter(e => this.levelFilterValue.includes(e[4]));
			};
			return entriesArray;
		},

		setMsgFilter(entriesArray) {
			let fPattern = this.msgFilterValue;
			if(!fPattern) {
				return entriesArray;
			};
			return (this.msgFilterReValue) ?
				this.setRegexpFilter(entriesArray, 5, fPattern, this.msgFilter) :
					this.setStringFilter(entriesArray, 5, fPattern);
		},

		/**
		 * Creates the contents of the log area.
		 * Abstract method, must be overridden by a subclass!
		 *
		 * @instance
		 * @abstract
		 *
		 * @param {Array<number, string|null, string|null, string|null, string|null, string|null>} logdataArray
		 * @returns {Node}
		 * Returns a DOM node containing the log area.
		 */
		makeLogArea(logdataArray) {
			throw new Error('makeLogArea must be overridden by a subclass');
		},

		disableFormElems() {
			Array.from(this.logFilterForm.elements).forEach(
				e => e.disabled = true
			);
			this.actionButtons.forEach(e => e.disabled = true);
		},

		enableFormElems() {
			Array.from(this.logFilterForm.elements).forEach(
				e => e.disabled = false
			);
			this.actionButtons.forEach(e => e.disabled = false);
		},

		downloadLog(ev) {
			this.disableFormElems();
			return this.getLogData(0).then(logdata => {
				logdata = logdata || '';
				let link = E('a', {
					'download': this.viewName + '.log',
					'href'    : URL.createObjectURL(
						new Blob([ logdata ], { type: 'text/plain' })),
				});
				link.click();
				URL.revokeObjectURL(link.href);
			}).catch(err => {
				ui.addNotification(null,
					E('p', {}, _('Download error') + ': ' + err.message));
			}).finally(() => {
				this.enableFormElems();
			});
		},

		restoreSettingsFromLocalStorage() {
			let tailValueLocal = localStorage.getItem(`luci-app-${this.viewName}-tailValue`);
			if(tailValueLocal) {
				this.tailValue = Number(tailValueLocal);
			};
			let logSortingLocal = localStorage.getItem(`luci-app-${this.viewName}-logSortingValue`);
			if(logSortingLocal) {
				this.logSortingValue = logSortingLocal;
			};
			if(this.isAutorefresh) {
				let autoRefreshLocal = localStorage.getItem(`luci-app-${this.viewName}-autoRefreshValue`);
				if(autoRefreshLocal) {
					this.autoRefreshValue = Boolean(Number(autoRefreshLocal));
				};
			};
		},

		saveSettingsToLocalStorage(tailValue, logSortingValue, autoRefreshValue) {
			tailValue = this.checkZeroValue(tailValue);
			if(this.tailValue != tailValue) {
				localStorage.setItem(
					`luci-app-${this.viewName}-tailValue`, String(tailValue));
			};
			if(this.logSortingValue != logSortingValue) {
				localStorage.setItem(
					`luci-app-${this.viewName}-logSortingValue`, logSortingValue);
			};
			if(this.isAutorefresh) {
				if(this.autoRefreshValue != autoRefreshValue) {
					localStorage.setItem(
						`luci-app-${this.viewName}-autoRefreshValue`, String(Number(autoRefreshValue)));
				};
			};
		},

		reloadLog(tail, modal=false, autorefresh=false) {
			tail = (tail && tail > 0) ? tail : 0;
			if(!autorefresh) {
				this.disableFormElems();
				poll.stop();
			};
			return this.getLogData(tail).then(logdata => {
				logdata = logdata || '';
				this.logWrapper.innerHTML = '';
				this.logWrapper.append(
					this.makeLogArea(
						this.setMsgFilter(
							this.setFacilityFilter(
								this.setLevelFilter(
									this.setHostFilter(
										this.setTimeFilter(
											this.parseLogData(logdata, tail)
										)
									)
								)
							)
						)
					)
				);
				if(logdata && logdata !== '') {
					if(this.isFacilities && !this.logFacilitiesDropdown) {
						this.logFacilitiesDropdownElem = this.makeLogFacilitiesDropdownSection();
					};
					if(this.isLevels && !this.logLevelsDropdown) {
						this.logLevelsDropdownElem = this.makeLogLevelsDropdownSection();
					};
					if(this.isHosts && !this.logHostsDropdown) {
						this.logHostsDropdownElem = this.makeLogHostsDropdownSection();
					};
				};

				if(!autorefresh) {
					poll.start();
				};
			}).finally(() => {
				if(modal) {
					ui.hideModal();
				};
				if(!autorefresh) {
					this.enableFormElems();
				};
			});
		},

		filterSettingsModal() {
			return ui.showModal(_('Filter settings'), [
				E('div', { 'class': 'cbi-map' }, [
					E('div', { 'class': 'cbi-section' }, [
						E('div', { 'class': 'cbi-section-node' }, [
							E('div', { 'class': 'cbi-value' }, [
								E('label', {
									'class': 'cbi-value-title',
									'for'  : 'tailInput',
								}, _('Last entries')),
								E('div', { 'class': 'cbi-value-field' }, [
									this.tailInput,
									E('button', {
										'class': 'cbi-button btn',
										'click': L.bind(ev => {
											ev.target.blur();
											ev.preventDefault();
											this.tailInput.value = 0;
											this.tailInput.focus();
										}, this),
									}, '&#9003;'),
								]),
							]),
							E('div', { 'class': 'cbi-value' }, [
								E('label', {
									'class': 'cbi-value-title',
									'for'  : 'timeFilter',
								}, _('Timestamp filter')),
								E('div', { 'class': 'cbi-value-field' }, [
									this.timeFilter,
									E('button', {
										'class': 'cbi-button btn',
										'click': L.bind(ev => {
											ev.target.blur();
											ev.preventDefault();
											this.timeFilter.value = null;
											this.timeFilter.focus();
										}, this),
									}, '&#9003;'),
								]),
							]),
							E('div', { 'class': 'cbi-value' }, [
								E('label', {
									'class': 'cbi-value-title',
									'for'  : 'timeFilterRe',
								}, _('Filter is regexp')),
								E('div', { 'class': 'cbi-value-field' }, [
									E('div', { 'class': 'cbi-checkbox' }, [
										this.timeFilterRe,
										E('label', {}),
									]),
									E('div', { 'class': 'cbi-value-description' },
										_('Apply timestamp filter as regular expression')
									),
								]),
							]),
							this.logHostsDropdownElem,
							this.logFacilitiesDropdownElem,
							this.logLevelsDropdownElem,
							E('div', { 'class': 'cbi-value' }, [
								E('label', {
									'class': 'cbi-value-title',
									'for'  : 'msgFilter',
								}, _('Message filter')),
								E('div', { 'class': 'cbi-value-field' }, [
									this.msgFilter,
									E('button', {
										'class': 'cbi-button btn',
										'click': L.bind(ev => {
											ev.target.blur();
											ev.preventDefault();
											this.msgFilter.value = null;
											this.msgFilter.focus();
										}, this),
									}, '&#9003;'),
								]),
							]),
							E('div', { 'class': 'cbi-value' }, [
								E('label', {
									'class': 'cbi-value-title',
									'for'  : 'msgFilterRe',
								}, _('Filter is regexp')),
								E('div', { 'class': 'cbi-value-field' }, [
									E('div', { 'class': 'cbi-checkbox' }, [
										this.msgFilterRe,
										E('label', {}),
									]),
									E('div', { 'class': 'cbi-value-description' },
										_('Apply message filter as regular expression')
									),
								]),
							]),
							E('div', { 'class': 'cbi-value' }, [
								E('label', {
									'class': 'cbi-value-title',
									'for'  : 'logSorting',
								}, _('Sorting entries')),
								E('div', { 'class': 'cbi-value-field' }, this.logSorting),
							]),
							((this.isAutorefresh) ?
								E('div', { 'class': 'cbi-value' }, [
									E('label', {
										'class': 'cbi-value-title',
										'for'  : 'autoRefresh',
									}, _('Auto refresh')),
									E('div', { 'class': 'cbi-value-field' },
										E('div', { 'class': 'cbi-checkbox' }, [
											this.autoRefresh,
											E('label', {}),
										])
									),
								]) : ''),
						]),
					]),
				]),
				E('div', { 'class': 'right' }, [
					this.logFilterForm,
					E('button', {
						'class': 'btn',
						'click': ev => {
							ev.target.blur();
							this.resetFormValues();
							this.timeFilter.focus();
							this.msgFilter.focus();
							ui.hideModal();
						},
					}, _('Dismiss')),
					' ',
					E('button', {
						'type' : 'submit',
						'form' : 'logFilterForm',
						'class': 'btn cbi-button-positive important',
						'click': ui.createHandlerFn(this, function(ev) {
							ev.target.blur();
							ev.preventDefault();
							return this.onSubmitFilter();
						}),
					}, _('Apply')),
				]),
			], 'cbi-modal');
		},

		updateLog(autorefresh=false) {
			let tail = (Number(this.tailValue) == 0 || Number(this.fastTailValue) == 0)
				? 0 : Math.max(Number(this.tailValue), this.fastTailValue)
			return this.reloadLog(tail, false, autorefresh);
		},

		/**
		 * Creates a promise for the RPC request.
		 * Abstract method, must be overridden by a subclass!
		 *
		 * To completely disable the auto log refresh option, views extending
		 * this base class should overwrite the `getLogHash` function
		 * with `null`.
		 *
		 * @instance
		 * @abstract
		 *
		 * @returns {Promise}
		 * Returns a promise that returns the unique value for the current log state.
		 */
		getLogHash() {
			throw new Error('getLogHash must be overridden by a subclass');
		},

		async pollFunc() {
			await this.getLogHash().then(async hash => {
				if(this.lastHash !== hash) {
					this.lastHash = hash;
					return await this.updateLog(true);
				};
			});
		},

		onSubmitFilter() {
			this.saveSettingsToLocalStorage(
				this.tailInput.value, this.logSorting.value, this.autoRefresh.checked);
			this.setFilterSettings();
			this.fastTailValue = Number(this.tailValue);
			return this.reloadLog(Number(this.tailValue), true);
		},

		scrollToTop() {
			this.logWrapper.scrollIntoView(true);
		},

		scrollToBottom() {
			this.logWrapper.scrollIntoView(false);
		},

		load() {
			this.restoreSettingsFromLocalStorage();
			if(!this.autoRefresh || typeof(this.getLogHash) != 'function') {
				this.isAutorefresh    = false;
				this.autoRefreshValue = false;
			};
			return this.getLogData(this.tailValue);
		},

		render(logdata) {
			this.pollFuncWrapper = L.bind(this.pollFunc, this);

			this.logWrapper = E('div', {
				'id': 'logWrapper',
			}, this.makeLogArea(this.parseLogData(logdata, this.tailValue)));

			this.fastTailValue = this.tailValue

			this.tailInput = E('input', {
				'id'       : 'tailInput',
				'name'     : 'tailInput',
				'type'     : 'text',
				'form'     : 'logFilterForm',
				'class'    : 'cbi-input-text',
				'style'    : 'width:4em !important; min-width:4em !important',
				'maxlength': 5,
			});
			this.tailInput.value = this.tailValue;
			ui.addValidator(this.tailInput, 'uinteger', true);

			this.logHostsDropdownElem      = '';
			this.logFacilitiesDropdownElem = '';
			this.logLevelsDropdownElem     = '';
			if(this.isLevels) {
				this.logLevelsDropdownElem = this.makeLogLevelsDropdownSection();
			};
			if(this.isFacilities) {
				this.logFacilitiesDropdownElem = this.makeLogFacilitiesDropdownSection();
			};
			if(this.isHosts) {
				this.logHostsDropdownElem = this.makeLogHostsDropdownSection();
			};

			this.timeFilter = E('input', {
				'id'         : 'timeFilter',
				'name'       : 'timeFilter',
				'type'       : 'text',
				'form'       : 'logFilterForm',
				'class'      : 'cbi-input-text',
				'placeholder': _('Type a search pattern...'),
			});

			this.timeFilterRe = E('input', {
				'id'    : 'timeFilterRe',
				'name'  : 'timeFilterRe',
				'type'  : 'checkbox',
				'form'  : 'logFilterForm',
				'change': ev => this.timeFilter.focus(),
			});

			this.setRegexpValidator(this.timeFilter, this.timeFilterRe);

			this.msgFilter = E('input', {
				'id'         : 'msgFilter',
				'name'       : 'msgFilter',
				'type'       : 'text',
				'form'       : 'logFilterForm',
				'class'      : 'cbi-input-text',
				'placeholder': _('Type a search pattern...'),
			});

			this.msgFilterRe = E('input', {
				'id'    : 'msgFilterRe',
				'name'  : 'msgFilterRe',
				'type'  : 'checkbox',
				'form'  : 'logFilterForm',
				'change': ev => this.msgFilter.focus(),
			});

			this.setRegexpValidator(this.msgFilter, this.msgFilterRe);

			this.logSorting = E('select', {
				'id'   : 'logSorting',
				'name' : 'logSorting',
				'form' : 'logFilterForm',
				'class': "cbi-input-select",
			}, [
				E('option', { 'value': 'asc' }, _('ascending')),
				E('option', { 'value': 'desc' }, _('descending')),
			]);
			this.logSorting.value = this.logSortingValue;

			this.autoRefresh = E('input', {
				'id'   : 'autoRefresh',
				'name' : 'autoRefresh',
				'type' : 'checkbox',
				'form' : 'logFilterForm',
			});
			this.autoRefresh.checked = this.autoRefreshValue;

			this.filterEditsBtn = E('button', {
				'class': 'cbi-button btn cbi-button-action',
				'click': L.bind(this.filterSettingsModal, this),
			}, _('Edit'));

			this.logFilterForm = E('form', {
				'id'    : 'logFilterForm',
				'name'  : 'logFilterForm',
				'submit': ev => {
					ev.preventDefault();
					return this.onSubmitFilter();
				},
			});

			this.logDownloadBtn = E('button', {
				'id'   : 'logDownloadBtn',
				'name' : 'logDownloadBtn',
				'class': 'cbi-button btn',
				'click': ui.createHandlerFn(this, this.downloadLog),
			}, _('Download log'));

			this.refreshBtn = E('button', {
				'title': _('Refresh log'),
				'class': 'cbi-button btn log-side-btn',
				'style': `visibility:${(this.autoRefreshValue) ? 'hidden' : 'visible'}`,
				'click': ui.createHandlerFn(this, function(ev) {
					ev.target.blur();
					return this.updateLog();
				}),
			}, '&#10227;');

			this.moreEntriesBtn = E('button', {
				'title': _('Get more entries'),
				'class': 'cbi-button btn log-side-btn',
				'style': 'margin-top:1px !important',
				'click': ui.createHandlerFn(this, function(ev) {
					ev.target.blur();
					if(this.fastTailValue === null) {
						this.fastTailValue = Number(this.tailValue);
					}
					if(this.fastTailValue > 0) {
						this.fastTailValue += this.fastTailIncrement;
					};
					return this.reloadLog(this.fastTailValue);
				}),
			}, `+${this.fastTailIncrement}`);

			this.allEntriesBtn = E('button', {
				'title': _('Get all entries'),
				'class': 'cbi-button btn log-side-btn',
				'style': 'margin-top:1px !important',
				'click': ui.createHandlerFn(this, function(ev) {
					ev.target.blur();
					this.fastTailValue = 0;
					return this.reloadLog(0);
				}),
			}, _('All'));

			this.filterModalBtn = E('button', {
				'title': _('Filter settings'),
				'class': 'cbi-button btn log-side-btn',
				'style': 'margin-top:10px !important',
				'click': ev => {
					ev.target.blur();
					this.filterSettingsModal();
				},
			}, '&#9634;');

			this.actionButtons.push(this.filterEditsBtn, this.logDownloadBtn,
									this.refreshBtn,this.moreEntriesBtn,
									this.allEntriesBtn, this.filterModalBtn);

			document.body.append(
				E('div', {
					'align': 'right',
					'class': 'log-side-block',
				}, [
					this.refreshBtn,
					this.moreEntriesBtn,
					this.allEntriesBtn,
					this.filterModalBtn,
					E('button', {
						'class': 'cbi-button btn log-side-btn',
						'style': 'margin-top:10px !important',
						'click': ev => {
							this.scrollToTop();
							ev.target.blur();
						},
					}, '&#8593;'),
					E('button', {
						'class': 'cbi-button btn log-side-btn',
						'style': 'margin-top:1px !important',
						'click': ev => {
							this.scrollToBottom();
							ev.target.blur();
						},
					}, '&#8595;'),
				])
			);

			if(this.isAutorefresh && this.autoRefreshValue) {
				poll.add(this.pollFuncWrapper, this.pollInterval);
			};

			return E([
				E('h2', { 'id': 'logTitle', 'class': 'fade-in' }, this.title),
				E('div', { 'class': 'cbi-section-descr fade-in' }),
				E('div', { 'class': 'cbi-section fade-in' },
					E('div', { 'class': 'cbi-section-node' }, [
						E('div', { 'class': 'cbi-value' }, [
							E('label', {
								'class': 'cbi-value-title',
								'for'  : 'filterSettings',
							}, _('Filter settings')),
							E('div', { 'class': 'cbi-value-field' }, [
								E('div', {}, this.filterEditsBtn),
								E('input', {
									'id'  : 'filterSettings',
									'type': 'hidden',
								}),
							]),
						]),
					])
				),
				E('div', { 'class': 'cbi-section fade-in' },
					E('div', { 'class': 'cbi-section-node' },
						this.logWrapper
					)
				),
				E('div', { 'class': 'cbi-section fade-in' },
					E('div', { 'class': 'cbi-section-node' },
						E('div', { 'class': 'cbi-value' },
							E('div', {
								'align': 'left',
								'style': 'width:100%',
							}, this.logDownloadBtn)
						),
					)
				),
			]);
		},

		handleSaveApply: null,
		handleSave     : null,
		handleReset    : null,
	}),
})
