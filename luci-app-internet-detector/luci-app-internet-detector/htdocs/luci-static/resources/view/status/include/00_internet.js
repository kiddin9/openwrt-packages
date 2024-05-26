'use strict';
'require baseclass';
'require fs';
'require rpc';
'require uci';

document.head.append(E('style', {'type': 'text/css'},
`
:root {
	--app-id-font-color: #454545;
	--app-id-font-shadow: #fff;
	--app-id-connected-color: #6bdebb;
	--app-id-disconnected-color: #f8aeba;
	--app-id-undefined-color: #dfdfdf;
}
:root[data-darkmode="true"] {
	--app-id-font-color: #f6f6f6;
	--app-id-font-shadow: #4d4d4d;
	--app-id-connected-color: #005F20;
	--app-id-disconnected-color: #a93734;
	--app-id-undefined-color: #4d4d4d;
}
.id-connected {
	--on-color: var(--app-id-font-color);
	background-color: var(--app-id-connected-color) !important;
	border-color: var(--app-id-connected-color) !important;
	color: var(--app-id-font-color) !important;
	text-shadow: 0 1px 1px var(--app-id-font-shadow);
}
.id-disconnected {
	--on-color: var(--app-id-font-color);
	background-color: var(--app-id-disconnected-color) !important;
	border-color: var(--app-id-disconnected-color) !important;
	color: var(--app-id-font-color) !important;
	text-shadow: 0 1px 1px var(--app-id-font-shadow);
}
.id-undefined {
	--on-color: var(--app-id-font-color);
	background-color: var(--app-id-undefined-color) !important;
	border-color: var(--app-id-undefined-color) !important;
	color: var(--app-id-font-color) !important;
	text-shadow: 0 1px 1px var(--app-id-font-shadow);
}
.id-label-status {
	display: inline-block;
	word-wrap: break-word;
	margin: 2px !important;
	padding: 4px 8px;
	border: 1px solid;
	-webkit-border-radius: 4px;
	-moz-border-radius: 4px;
	border-radius: 4px;
	font-weight: bold;
}
`));

return baseclass.extend({
	title               : _('Internet'),
	appName             : 'internet-detector',
	currentAppMode      : null,
	inetStatus          : null,

	callUIPoll: rpc.declare({
		object: 'luci.internet-detector',
		method: 'UIPoll',
		expect: { '': {} }
	}),

	getUIPoll() {
		return this.callUIPoll().then(data => {
			return data;
		});
	},

	callInetStatus: rpc.declare({
		object: 'luci.internet-detector',
		method: 'InetStatus',
		expect: { '': {} }
	}),

	getInetStatus() {
		return this.callInetStatus().then(data => {
			return data;
		});
	},

	async load() {
		if(!this.currentAppMode) {
			await uci.load(this.appName).then(data => {
				this.currentAppMode = uci.get(this.appName, 'config', 'mode');
			}).catch(e => {});
		};

		if(this.currentAppMode === '2') {
			return this.getUIPoll();
		}
		else if(this.currentAppMode === '1') {
			return L.resolveDefault(this.getInetStatus(), null);
		};
	},

	render(data) {
		if(this.currentAppMode === '0') {
			return;
		}

		this.inetStatus = data;

		let inetStatusArea = E('div', {});

		if(!this.inetStatus || !this.inetStatus.instances || this.inetStatus.instances.length === 0) {
			let label = E('span', { 'class': 'id-label-status id-undefined' }, _('Undefined'));
			if(this.currentAppMode === '2') {
				label.classList.add('spinning');
			};
			inetStatusArea.append(label);
		} else {
			this.inetStatus.instances.sort((a, b) => a.num > b.num);

			for(let i of this.inetStatus.instances) {
				let status    = _('Disconnected');
				let className = 'id-label-status id-disconnected';
				if(i.inet == 0) {
					status    = _('Connected');
					className = 'id-label-status id-connected';
				}
				else if(i.inet == -1) {
					status    = _('Undefined');
					className = 'id-label-status id-undefined spinning';
				};

				let publicIp = (i.mod_public_ip !== undefined) ?
					' | %s: %s'.format(_('Public IP'), (i.mod_public_ip === '') ? _('Undefined') : _(i.mod_public_ip))
				: '';

				inetStatusArea.append(
					E('span', { 'class': className }, '%s%s%s'.format(
						i.instance + ': ', status, publicIp)
					)
				);
			};
		};

		return E('div', {
			'class': 'cbi-section',
			'style': 'margin-bottom:1em',
		}, inetStatusArea);
	},
});
