'use strict';
'require form';
'require fs';
'require view';
'require uci';
'require ui';
'require tools.widgets as widgets'

/*
	Copyright 2022-2024 Rafał Wabik - IceG - From eko.one.pl forum
*/

return view.extend({
	load: function() {
		return fs.list('/dev').then(function(devs) {
			return devs.filter(function(dev) {
				return dev.name.match(/^ttyUSB/) || dev.name.match(/^cdc-wdm/) || dev.name.match(/^ttyACM/) || dev.name.match(/^mhi_/) || dev.name.match(/^wwan/);
			});
		});
	},

	render: function(devs) {
		var m, s, o;
		m = new form.Map('modemband', _('Configuration modemband'), _('Configuration panel for modemband and gui application.'));

		s = m.section(form.TypedSection, 'modemband', '', null);
		s.anonymous = true;

/*		Old config
		o = s.option(widgets.DeviceSelect, 'iface', _('Interface'),
		_('Network interface for Internet access.')
		);
		o.noaliases  = false;
		o.default = 'wan';
*/
	
		o = s.option(widgets.NetworkSelect, 'iface', _('Interface'),
		_('Network interface for Internet access.')
		);
		o.exclude = s.section;
		o.nocreate = true;
		o.rmempty = false;
		o.default = 'wan';

		o = s.option(form.Value, 'set_port', _('Port for communication with the modem'), 
			_("Select one of the available ttyUSBX ports."));
		devs.sort((a, b) => a.name > b.name);
		devs.forEach(dev => o.value('/dev/' + dev.name));
		
		o.placeholder = _('Please select a port');
		o.rmempty = false;

		o = s.option(form.Flag, 'wanrestart',	_('Restart WAN'),
		_('WAN restart after making changes to bands.')
		);
		o.rmempty = false;

		o = s.option(form.Flag, 'modemrestart', _('Modem restart'),
		_('Modem restart after making changes to bands.')
		);
		o.rmempty = false;

		o = s.option(form.Value, 'restartcmd', _('Restart with AT command'),
		_('AT command to restart the modem.')
		);
		o.default = 'AT+CFUN=1,1';
		o.depends("modemrestart", "1");
		o.rmempty = false;

		s = m.section(form.TypedSection, 'modemband', null);
		s.anonymous = true;
		s.addremove = false;

		s.tab('opt', _('Appearance and action settings'));
		s.anonymous = true;

		o = s.taboption('opt', form.Flag, 'notify', _('Turn off notifications'),
		_('Checking this option disables the notification that appears every time the bands are changed.')
		);
		o.rmempty = false;

		return m.render();
	}
});
