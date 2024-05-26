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
	return L.resolveDefault(callServiceList('qbittorrent'), {}).then(function (res) {
		var isRunning = false;
		try {
			isRunning = res['qbittorrent']['instances']['instance1']['running'];
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
		renderHTML = spanTemp.format('green', _('qBittorrent'), _('RUNNING')) + button;
	} else {
		renderHTML = spanTemp.format('red', _('qBittorrent'), _('NOT RUNNING'));
	}

	return renderHTML;
}

return view.extend({
	load: function() {
		return Promise.all([
			uci.load('qbittorrent')
		]);
	},

	render: function(data) {
		var m, s, o;
		var webport = uci.get(data[0], 'config', 'http_port') || '8080';

		m = new form.Map('qbittorrent', _('qBittorrent'),
			_('qBittorrent is a bittorrent client programmed in C++ / Qt.<br />' +
				'Default login username is <code>admin</code> and password is <code>adminadmin</code>.'));

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

		s = m.section(form.NamedSection, 'config', 'qbittorrent');

		o = s.option(form.Flag, 'enabled', _('Enable'));
		o.default = o.disabled;
		o.rmempty = false;

		o = s.option(form.Value, 'http_port', _('Listen port'));
		o.datatype = 'port';
		o.default = '8080';
		o.rmempty = false;

		o = s.option(form.Value, 'download_dir', _('Download path'));
		o.default = '/mnt/download';
		o.rmempty = false;

		return m.render();
	}
});
