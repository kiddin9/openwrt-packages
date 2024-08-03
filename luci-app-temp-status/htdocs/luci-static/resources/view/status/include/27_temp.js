'use strict';
'require baseclass';
'require rpc';

document.head.append(E('style', {'type': 'text/css'},
`
:root {
	--app-temp-status-font-color: #2e2e2e;
	--app-temp-status-hot-color: #fff6d9;
	--app-temp-status-crit-color: #fcc3bf;
}
:root[data-darkmode="true"] {
	--app-temp-status-font-color: #fff;
	--app-temp-status-hot-color: #8d7000;
	--app-temp-status-crit-color: #a93734;
}
.temp-status-hot {
	background-color: var(--app-temp-status-hot-color) !important;
	color: var(--app-temp-status-font-color) !important;
}
.temp-status-hot .td {
	color: var(--app-temp-status-font-color) !important;
}
.temp-status-hot td {
	color: var(--app-temp-status-font-color) !important;
}
.temp-status-crit {
	background-color: var(--app-temp-status-crit-color) !important;
	color: var(--app-temp-status-font-color) !important;
}
.temp-status-crit .td {
	color: var(--app-temp-status-font-color) !important;
}
.temp-status-crit td {
	color: var(--app-temp-status-font-color) !important;
}
`));

return baseclass.extend({
	title       : _('Temperature'),

	tempHot     : 90,

	tempCritical: 100,

	callTempStatus: rpc.declare({
		object: 'luci.temp-status',
		method: 'getTempStatus',
		expect: { '': {} }
	}),

	formatTemp(mc) {
		return Number((mc / 1e3).toFixed(1));
	},

	sortFunc(a, b) {
		return (a.number > b.number) ? 1 : (a.number < b.number) ? -1 : 0;
	},

	load() {
		return L.resolveDefault(this.callTempStatus(), null);
	},

	render(tempData) {
		if(!tempData) return;

		let tempTable = E('table', { 'class': 'table' },
			E('tr', { 'class': 'tr table-titles' }, [
				E('th', { 'class': 'th left', 'width': '33%' }, _('Sensor')),
				E('th', { 'class': 'th left' }, _('Temperature')),
			])
		);

		let tempArray = [];

		for(let [k, v] of Object.entries(tempData)) {
			v.sort(this.sortFunc);

			for(let i of Object.values(v)) {
				let sensor = i.title || i.item;

				if(i.sources === undefined) {
					continue;
				};

				i.sources.sort(this.sortFunc);

				for(let j of i.sources) {
					let temp = j.temp;
					let name = (j.label !== undefined) ? sensor + " / " + j.label :
						(j.item !== undefined) ? sensor + " / " + j.item.replace(/_input$/, "") : sensor

					if(temp !== undefined) {
						temp = this.formatTemp(temp);
						tempArray.push(temp);
					};

					let tempHot       = this.tempHot;
					let tempCritical  = this.tempCritical;
					let tpoints       = j.tpoints;
					let tpointsString = '';

					if(tpoints) {
						for(let i of Object.values(tpoints)) {
							let t = this.formatTemp(i.temp);
							tpointsString += `&#10;${i.type}: ${t} °C`;

							if(i.type === 'critical' || i.type === 'emergency') {
								tempCritical = t;
							}
							else if(i.type === 'hot' || i.type === 'max') {
								tempHot = t;
							};
						};
					};

					let rowStyle = (temp >= tempCritical) ? ' temp-status-crit':
						(temp >= tempHot) ? ' temp-status-hot' : '';

					tempTable.append(
						E('tr', { 'class': 'tr' + rowStyle }, [
							E('td', {
									'class'     : 'td left',
									'data-title': _('Sensor')
								},
								(tpointsString.length > 0) ?
								`<span style="cursor:help; border-bottom:1px dotted" data-tooltip="${tpointsString}">${name}</span>`
								: name
							),
							E('td', {
									'class'     : 'td left',
									'data-title': _('Temperature')
								},
								(temp === undefined) ? '-' : temp + ' °C'),
						])
					);
				};
			};
		};

		if(tempTable.childNodes.length === 1) {
			tempTable.append(
				E('tr', { 'class': 'tr placeholder' },
					E('td', { 'class': 'td' },
						E('em', {}, _('No temperature sensors available'))
					)
				)
			);
		};
		return tempTable;
	},
});
