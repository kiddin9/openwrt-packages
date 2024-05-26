'use strict';
'require form';
'require view';
'require uci';
'require rpc';
'require fs';
'require tools.widgets as widgets';


function getModemList() {
	return fs.exec_direct('/usr/bin/mmcli', [ '-L' ]).then(function(res) {
		var lines = (res || '').split(/\n/),
		    tasks = [];

		for (var i = 0; i < lines.length; i++) {
			var m = lines[i].match(/\/Modem\/(\d+)/);
			if (m)
				tasks.push(fs.exec_direct('/usr/bin/mmcli', [ '-m', m[1] ]));
		}

		return Promise.all(tasks).then(function(res) {
			var modems = [];

			for (var i = 0; i < res.length; i++) {
				var man = res[i].match(/manufacturer: ([^\n]+)/),
				    mod = res[i].match(/model: ([^\n]+)/),
				    dev = res[i].match(/device: ([^\n]+)/);

				if (dev) {
					modems.push({
						device:       dev[1].trim(),
						manufacturer: (man ? man[1].trim() : '') || '?',
						model:        (mod ? mod[1].trim() : '') || dev[1].trim()
					});
				}
			}

			return modems;
		});
	});
}

var callSerialPort = rpc.declare({
	object: 'file',
	method: 'list',
	params: [ 'path' ],
	expect: { entries: [] },
	filter: function(list, params) {
		var rv = [];
		for (var i = 0; i < list.length; i++)
			if (list[i].name.match(/^ttyACM/) || list[i].name.match(/^ttyUSB/))
				rv.push(params.path + list[i].name);
		return rv.sort();
	}
});

var callQMIPort = rpc.declare({
        object: 'file',
        method: 'list',
        params: [ 'path' ],
        expect: { entries: [] },
        filter: function(list, params) {
                var rv = [];
                for (var i = 0; i < list.length; i++)
                        if (list[i].name.match(/^cdc-wdm/))
                                rv.push(params.path + list[i].name);
                return rv.sort();
        }
});

var callLEDs = rpc.declare({
	object: 'luci',
	method: 'getLEDs',
	expect: { '': {} }
});


return view.extend({

	load: function() {
		return Promise.all([
			callLEDs(),
			L.resolveDefault(fs.list('/www' + L.resource('view/system/led-trigger')), []),
		]).then(function(data) {
			var plugins = data[1];
			var tasks = [];

			for (var i = 0; i < plugins.length; i++) {
				var m = plugins[i].name.match(/^(.+)\.js$/);

				if (plugins[i].type != 'file' || m == null)
					continue;

				tasks.push(L.require('view.system.led-trigger.' + m[1]).then(L.bind(function(name){
					return L.resolveDefault(L.require('view.system.led-trigger.' + name)).then(function(form) {
						return {
							name: name,
							form: form,
						};
					});
				}, this, m[1])));
			}

			return Promise.all(tasks).then(function(plugins) {
				var value = {};
				value[0] = data[0];
				value[1] = plugins;
				
				return value;
			});
		});
	},

	render: function(data) {
		
		var m, s, o, triggers = [];
		var leds = data[0];
		var plugins = data[1];

		for (var k in leds)
			for (var i = 0; i < leds[k].triggers.length; i++)
				triggers[i] = leds[k].triggers[i];

		m = new form.Map('cellled', _('CellLED'));
		m.description = _('Application for showing cellular RSSI LEDs');

		s = m.section(form.TypedSection, 'device', _('General setup'));
		s.anonymous = true;
		s.rmempty = true;
				
		o = s.option(form.ListValue, 'data_type', _('Select Data service'));
		o.value('qmi', 'libQMI');
		o.value('uqmi', 'uQMI');
		o.value('mm', 'Modem Manager');
		o.value('serial', 'Serial Port');

		o = s.option(form.ListValue, 'device', _('Select Data port'));
		o.load = function(section_id) {
			return callSerialPort('/dev/').then(L.bind(function(devices) {
				for (var i = 0; i < devices.length; i++)
					this.value(devices[i]);
				return form.Value.prototype.load.apply(this, [section_id]);
			}, this));
		};
		o.rmempty = true;
		o.depends('data_type', 'serial');

		o = s.option(form.ListValue, 'device_qmi', _('Select Data port'));
		o.load = function(section_id) {
			return callQMIPort('/dev/').then(L.bind(function(devices) {
				for (var i = 0; i < devices.length; i++)
					this.value(devices[i]);
				return form.Value.prototype.load.apply(this, [section_id]);
			}, this));
		};
		o.rmempty = true;
		o.depends('data_type', 'qmi');
		o.depends('data_type', 'uqmi');

		o = s.option(form.ListValue, 'device_mm', _('Select Data port'));
		o.load = function(section_id) {
			return getModemList().then(L.bind(function(devices) {
				for (var i = 0; i < devices.length; i++)
					this.value(devices[i].device,
						'%s - %s'.format(devices[i].manufacturer, devices[i].model));
				return form.Value.prototype.load.apply(this, [section_id]);
			}, this));
		};
		o.rmempty = true;
		o.depends('data_type', 'mm');
		
		o = s.option(form.Value, 'timeout', _('Timeout interval data(sec)'));
		o.datatype = 'and(uinteger,min(5))';

		o = s.option(form.Flag, 'rgb_led', _('RGB LED'), _('Use RGB Led'));

		o = s.option(form.Flag, 'use_pwm', _('Use PWM'), _('Enable if Support PWM LED'));
		o.depends('rgb_led', '1');

		o = s.option(form.ListValue, 'red_led', _('Red LED'));
		Object.keys(leds).sort().forEach(function(name) {
                        o.value(name);
                });
		o.rmempty = true;
		o.depends('rgb_led', '1');

		o = s.option(form.ListValue, 'green_led', _('Greed LED'));
		Object.keys(leds).sort().forEach(function(name) {
			o.value(name);
		});
		o.rmempty = true;
		o.depends('rgb_led', '1');
		
		o = s.option(form.ListValue, 'blue_led', _('Blue LED'));		
		Object.keys(leds).sort().forEach(function(name) {
			o.value(name);
		});
		o.rmempty = true;
		o.depends('rgb_led', '1');

		s = m.section(form.GridSection, 'rssi_led', _('Signal strength values'));
		s.addremove = true;
		s.anonymous = true;
		s.nodescriptions = true;

		o = s.option(form.Flag, 'rgb', _('RGB Led'));

		o = s.option(form.ListValue, 'led', _('LED'));
		Object.keys(leds).sort().forEach(function(name) {
			o.value(name);
		});
		o.rmempty = true;
		o.depends('rgb', '0');

		o = s.option(form.ListValue, 'type', _('Quality'));
		o.value('poor',_('Poor'));
		o.value('bad',_('Bad'));
		o.value('fair',_('Fair'));
		o.value('good',_('Good'));
		o.depends('rgb', '1');

		o = s.option(form.Value, 'rssi_min', _('Min.value %'));
		o.datatype = 'and(uinteger,min(0),max(100))';
		o.rmempty = true;

		o = s.option(form.Value, 'rssi_max', _('Max.value %'));
		o.datatype = 'and(uinteger,min(0),max(100))';
		o.rmempty = true;

		return m.render();
	}
});
