/* SPDX-License-Identifier: GPL-3.0-only
 *
 * Copyright (C) 2022 ImmortalWrt.org
 */

'use strict';
'require form';
'require poll';
'require rpc';
'require uci';
'require view';

var callServiceList = rpc.declare({
	object: 'service',
	method: 'list',
	params: ['name'],
	expect: { '': {} }
});

function getServiceStatus() {
	return L.resolveDefault(callServiceList('bitsrunlogin-go'), {}).then(function (res) {
		var isRunning = false;
		try {
			isRunning = res['bitsrunlogin-go']['instances']['instance1']['running'];
		} catch (e) { }
		return isRunning;
	});
}

function renderStatus(isRunning) {
	var spanTemp = '<em><span style="color:%s"><strong>%s %s</strong></span></em>';
	var renderHTML;
	if (isRunning) {
		renderHTML = spanTemp.format('green', _('BitSrunLogin-Go'), _('RUNNING'));
	} else {
		renderHTML = spanTemp.format('red', _('BitSrunLogin-Go'), _('NOT RUNNING'));
	}

	return renderHTML;
}

return view.extend({
	load: function() {
		return Promise.all([
			uci.load('bitsrunlogin-go')
		]);
	},

	render: function(data) {
		var m, s, o;

		m = new form.Map('bitsrunlogin-go', _('BitSrunLogin-Go'),
			_('Bit Srun auto login tool.'));

		s = m.section(form.TypedSection);
		s.anonymous = true;
		s.render = function () {
			poll.add(function () {
				return L.resolveDefault(getServiceStatus()).then(function (res) {
					var view = document.getElementById('service_status');
					view.innerHTML = renderStatus(res);
				});
			});

			return E('div', { class: 'cbi-section', id: 'status_bar' }, [
					E('p', { id: 'service_status' }, _('Collecting data...'))
			]);
		}

		s = m.section(form.NamedSection, 'config', 'bitsrunlogin-go');

		o = s.option(form.Flag, 'enabled', _('Enable'));
		o.default = o.disabled;
		o.rmempty = false;

		o = s.option(form.Value, 'domain', _('Login address'));
		o.datatype = 'host';
		o.rmempty = false;

		o = s.option(form.Value, 'usertype', _('ISP type'),
			_('See <a href="https://github.com/Mmx233/BitSrunLoginGo" target="_blank">Mmx233/BitSrunLoginGo</a> for details.'));
		o.value('cmcc', _('China Mobile (cmcc)'));
		o.value('ctcc', _('China Telecom (ctcc)'));
		o.value('cucc', _('China Unicom (cucc)'));

		o = s.option(form.Value, 'username', _('Username'));
		o.rmempty = false;

		o = s.option(form.Value, 'password', _('Password'));
		o.password = true;
		o.rmempty = false;

		o = s.option(form.Flag, 'auto_acid', _('Auto detect AC_ID'),
			_('Automatically obtain correct ac_id from login server, the program will still use the configured ac_id below if it fails.'));
		o.default = o.enabled;
		o.rmempty = false;

		o = s.option(form.Value, 'acid', _('AC_ID'),
			_('Please refer to you school to modify this value, incorrect ac_id may cause login error.'));
		o.datatype = 'uinteger';
		o.default = '5';
		o.rmempty = false;

		o = s.option(form.Flag, 'dual_stack', _('Enable dual stack'));
		o.default = o.disabled;
		o.rmempty = false;

		o = s.option(form.Flag, 'enable_https', _('Enable HTTPS'),
			_('Use HTTPS to login.'));
		o.default = o.disabled;
		o.rmempty = false;

		o = s.option(form.Flag, 'skip_cert_verify', _('Skip certificate check'));
		o.default = o.disabled;
		o.depends('enable_https', '1');
		o.rmempty = false;

		o = s.option(form.Value, 'timeout', _('Timeout'),
			_('Maximum time allowed for connection.'));
		o.datatype = 'uinteger';
		o.default = '5';
		o.rmempty = false;

		o = s.option(form.Value, 'duration', _('Check interval'),
			_('Network connectivity check interval.'));
		o.datatype = 'uinteger';
		o.default = '3600';
		o.rmempty = false;

		o = s.option(form.Value, 'interfaces', _('Interface name'),
			_('Interface name in regex, e.g. "eth0\\.[2-3]".<br/>Multi-interfaces mode will be enabled if not empty.'));

		o = s.option(form.Flag, 'debug', _('Debug mode'),
			_('More granular information will be given in log.'));
		o.default = o.disabled;
		o.rmempty = false;

		return m.render();
	}
});
