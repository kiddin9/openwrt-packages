/* Copyright (C) 2023 ImmortalWrt.org */

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
	return L.resolveDefault(callServiceList('microsocks'), {}).then(function (res) {
		var isRunning = false;
		try {
			isRunning = res['microsocks']['instances']['microsocks']['running'];
		} catch (e) { }
		return isRunning;
	});
}

function renderStatus(isRunning) {
	var spanTemp = '<em><span style="color:%s"><strong>%s %s</strong></span></em>';
	var renderHTML;
	if (isRunning) {
		renderHTML = spanTemp.format('green', _('MicroSocks'), _('RUNNING'));
	} else {
		renderHTML = spanTemp.format('red', _('MicroSocks'), _('NOT RUNNING'));
	}

	return renderHTML;
}

return view.extend({
	render: function() {
		var m, s, o;

		m = new form.Map('microsocks', _('MicroSocks'),
			_('MicroSocks - multithreaded, small, efficient SOCKS5 server.'));

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

		s = m.section(form.NamedSection, 'config', 'microsocks');

		o = s.option(form.Flag, 'enabled', _('Enable'));
		o.default = o.disabled;
		o.rmempty = false;

		o = s.option(form.Value, 'bindaddr', _('Bind address'),
			_('Specifiy which ip outgoing connections are bound to.'));
		o.datatype = 'ipaddr';

		o = s.option(form.Value, 'listenip', _('Listen address'));
		o.datatype = 'ipaddr';
		o.placeholder = '0.0.0.0';

		o = s.option(form.Value, 'port', _('Listen port'));
		o.datatype = 'port';
		o.placeholder = '1080';

		o = s.option(form.Value, 'user', _('Username'));

		o = s.option(form.Value, 'password', _('Password'));
		o.password = true;
		o.rmempty = false;
		o.depends({'user': '', '!reverse': true});

		o = s.option(form.Flag, 'auth_once', _('Auth once'),
			_('Once a specific ip address authed successfully with user/pass, it is added to a whitelist and may use the proxy without auth.'));
		o.default = o.disabled;
		o.depends({'user': '', '!reverse': true});

		o = s.option(form.Flag, 'internet_access', _('Allow access from Internet'));
		o.default = o.disabled;

		return m.render();
	}
});
