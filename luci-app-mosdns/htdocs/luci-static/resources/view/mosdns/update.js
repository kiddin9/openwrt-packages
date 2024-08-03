'use strict';
'require form';
'require fs';
'require ui';
'require view';

return view.extend({
	handleUpdate: function (m, section_id, ev) {
		return fs.exec('/usr/share/mosdns/mosdns.sh', ['geodata'])
			.then(function (i) {
				var res = i.code;
				if (res === 0) {
					ui.addNotification(null, E('p', _('Update success')), 'info');
				} else {
					ui.addNotification(null, E('p', i.stderr + '<br />' + i.stdout), 'warn');
					ui.addNotification(null, E('p', _('Update failed, Please check the network status')), 'error');
				}
			});
	},

	render: function () {
		var m, s, o;

		m = new form.Map('mosdns', _('Update GeoIP & GeoSite databases'),
			_('Automatically update GeoIP and GeoSite databases as well as ad filtering rules through scheduled tasks.'));

		s = m.section(form.TypedSection);
		s.anonymous = true;

		o = s.option(form.Flag, 'geo_auto_update', _('Enable Auto Database Update'));
		o.rmempty = false;

		o = s.option(form.ListValue, 'geo_update_week_time', _('Update Cycle'));
		o.value('*', _('Every Day'));
		o.value('1', _('Every Monday'));
		o.value('2', _('Every Tuesday'));
		o.value('3', _('Every Wednesday'));
		o.value('4', _('Every Thursday'));
		o.value('5', _('Every Friday'));
		o.value('6', _('Every Saturday'));
		o.value('7', _('Every Sunday'));
		o.default = 3;

		o = s.option(form.ListValue, 'geo_update_day_time', _('Update Time'));
		for (let t = 0; t < 24; t++) {
			o.value(t, t + ':00');
		};
		o.default = 3;

		o = s.option(form.Value, 'github_proxy', _('GitHub Proxy'),
			_('Update data files with GitHub Proxy, leave blank to disable proxy downloads.'));
		o.value('https://hub.gitmirror.com', _('https://hub.gitmirror.com'));
		o.rmempty = true;
		o.default = '';

		o = s.option(form.Button, '_udpate', null,
			_('Check And Update GeoData.'));
		o.title = _('Database Update');
		o.inputtitle = _('Check And Update');
		o.inputstyle = 'apply';
		o.onclick = L.bind(this.handleUpdate, this, m);

		return m.render();
	}
});
