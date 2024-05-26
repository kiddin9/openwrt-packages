/* SPDX-License-Identifier: GPL-3.0-only
 *
 * Copyright (C) 2022 ImmortalWrt.org
 */

'use strict';
'require form';
'require fs';
'require uci';
'require view';

return view.extend({
	load: function() {
		return Promise.all([
			uci.load('cpufreq'),
			L.resolveDefault(fs.exec_direct('/etc/init.d/cpufreq', [ 'get_policies' ], 'json'), {})
		]);
	},

	render: function(data) {
		var m, s, o;

		m = new form.Map('cpufreq', _('CPU Freq Settings'),
			_('Set CPU Scaling Governor to Max Performance or Balance Mode'));

		s = m.section(form.NamedSection, 'cpufreq', 'settings');

		if (Object.keys(data[1]).length === 0) {
			s.render = () => {
				this.handleSaveApply = null;
				this.handleSave = null;
				this.handleReset = null;

				return E('div', { 'class': 'cbi-section warning' }, [
					E('h3', {}, _('Unsupported device!')),
					E('p', {}, _('Your device/kernel does not support CPU frequency scaling.'))
				]);
			}
		} else {
			/* Mark user edited */
			var ss = m.section(form.NamedSection, 'global', 'settings');
			var so = ss.option(form.HiddenValue, 'set');
			so.load = (/* ... */) => { return 1 };
			so.readonly = true;
			so.rmempty = false;

			for (var i in data[1]) {
				var index = data[1][i].index;
				s.tab(index, i, _('<h4>Apply for CPU %s.</h4>').format(data[1][i].cpus));

				o = s.taboption(index, form.ListValue, 'governor' + index, _('CPU Scaling Governor'));
				for (var gov of data[1][i].governors)
					o.value(gov);
				o.rmempty = false;

				o = s.taboption(index, form.ListValue, 'minfreq' + index, _('Min Idle CPU Freq'));
				for (var freq of data[1][i].freqs)
					o.value(freq);
				o.rmempty = false;

				o = s.taboption(index, form.ListValue, 'maxfreq' + index, _('Max Turbo Boost CPU Freq'));
				for (var freq of data[1][i].freqs)
					o.value(freq);
				o.validate = function(section_id, value) {
					if (!section_id)
						return true;
					else if (value === null || value === '')
						return _('Expecting: %s').format('non-empty value');

					var minfreq = this.map.lookupOption('minfreq' + index, section_id)[0].formvalue(section_id);
					if (parseInt(value) < parseInt(minfreq))
						return _('Max CPU Freq cannot be lower than Min CPU Freq.');

					return true;
				}

				o = s.taboption(index, form.Value, 'sdfactor' + index, _('CPU Switching Sampling rate'),
					_('The sampling rate determines how frequently the governor checks to tune the CPU (ms)'));
				o.datatype = 'range(1,100000)';
				o.default = '10';
				o.depends('governor' + index, 'ondemand');
				o.rmempty = false;

				o = s.taboption(index, form.Value, 'upthreshold' + index, _('CPU Switching Threshold'),
					_('Kernel make a decision on whether it should increase the frequency (%)'));
				o.datatype = 'range(1,99)';
				o.default = '50';
				o.depends('governor' + index, 'ondemand');
				o.rmempty = false;
			}
		}

		return m.render();
	}
});
