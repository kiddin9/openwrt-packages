// SPDX-License-Identifier: Apache-2.0

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
	return L.resolveDefault(callServiceList('daed'), {}).then(function (res) {
		var isRunning = false;
		try {
			isRunning = res['daed']['instances']['daed']['running'];
		} catch (e) { }
		return isRunning;
	});
}

function renderStatus(isRunning, port) {
	var spanTemp = '<span style="color:%s"><strong>%s %s</strong></span>';
	var renderHTML;
	if (isRunning) {
		var button = String.format('&#160;<a class="btn cbi-button" href="http://%s:%s" target="_blank" rel="noreferrer noopener">%s</a>',
			window.location.hostname, port, _('Open Web Interface'));
		renderHTML = spanTemp.format('green', _('daed'), _('RUNNING')) + button;
	} else {
		renderHTML = spanTemp.format('red', _('daed'), _('NOT RUNNING'));
	}

	return renderHTML;
}

return view.extend({
	load: function() {
		return Promise.all([
			uci.load('daed')
		]);
	},

	render: function(data) {
		var m, s, o;
		var webport = (uci.get(data[0], 'config', 'address') || '0.0.0.0:2023').split(':').slice(-1)[0];

		m = new form.Map('daed', _('daed'),
			_('A modern dashboard for dae.'));

		s = m.section(form.TypedSection);
		s.anonymous = true;
		s.render = function () {
			poll.add(function () {
				return L.resolveDefault(getServiceStatus()).then(function (res) {
					var view = document.getElementById('service_status');
					view.innerHTML = renderStatus(res, webport);
				});
			});

			return E('div', { class: 'cbi-section', id: 'status_bar' }, [
					E('p', { id: 'service_status' }, _('Collecting data...'))
			]);
		}

		s = m.section(form.NamedSection, 'config', 'daed');

		o = s.option(form.Flag, 'enabled', _('Enable'));
		o.default = o.disabled;
		o.rmempty = false;

		o = s.option(form.Value, 'listen_addr', _('Listening address'));
		o.datatype = 'ipaddrport(1)';
		o.default = '0.0.0.0:2023';
		o.rmempty = false;

		o = s.option(form.Value, 'log_maxbackups', _('Max log backups'),
			_('The maximum number of old log files to retain.'));
		o.datatype = 'uinteger';
		o.default = '1';

		o = s.option(form.Value, 'log_maxsize', _('Max log size'),
			_('The maximum size in megabytes of the log file before it gets rotated.'));
		o.datatype = 'uinteger';
		o.default = '5';

		return m.render();
	}
});
