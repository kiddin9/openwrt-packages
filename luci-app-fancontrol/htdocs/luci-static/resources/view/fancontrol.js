'use strict';
'require view';
'require fs';
'require form';
'require uci';
'require tools.widgets as widgets';

return view.extend({
	load: function () {
		return Promise.all([
			uci.load('fancontrol')
		]);
	},
	render: async function (data) {
		var m, s, o;

		m = new form.Map('fancontrol', _('Fan General Control'));
		s = m.section(form.TypedSection, 'fancontrol', _('Settings'));
		s.anonymous = true;

		o = s.option(form.Flag, 'enabled', _('Enabled'), _('Enabled'));
		o.rmempty = false;

		o = s.option(form.Value, 'thermal_file', _('Thermal File'), _('Thermal File'));
		o.placeholder = '/sys/devices/virtual/thermal/thermal_zone0/temp';
		var temp_div = uci.get('fancontrol', 'settings', 'temp_div');
		var temp = parseInt(await fs.read_direct(uci.get('fancontrol', 'settings', 'thermal_file')));
		if (temp_div > 0 && temp > 0) {
			o.description = _('Current temperature:') + ' <b>' + (temp / temp_div) + '°C</b>';
		} else {
			o.description = _('Thermal File');
		}

		o = s.option(form.Value, 'fan_file', _('Fan File'), _('Fan Speed File'));
		o.placeholder = '/sys/devices/virtual/thermal/cooling_device0/cur_state';
		var speed = parseInt(await fs.read_direct(uci.get('fancontrol', 'settings', 'fan_file')));
		o.description = _('Current speed:') + ' <b>' + (speed) + '</b>';

		o = s.option(form.Value, 'start_speed', _('Initial Speed'), _('Please enter the initial speed for fan startup.'));
		o.placeholder = '35';

		o = s.option(form.Value, 'max_speed', _('Max Speed'), _('Please enter maximum fan speed.'));
		o.placeholder = '255';

		o = s.option(form.Value, 'start_temp', _('Start Temperature'), _('Please enter the fan start temperature.'));
		o.placeholder = '45';

		return m.render();
	}
});