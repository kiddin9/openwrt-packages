'use strict';
'require form';
'require fs';
'require view';
'require uci';
'require ui';
'require tools.widgets as widgets'

/*
	Copyright 2022-2023 Rafał Wabik - IceG - From eko.one.pl forum

	Modified for atinout by Konstantine Shevlakov <shevlakov@132lan.ru> 2023
	
	Licensed to the GNU General Public License v3.0.
*/


var cmddesc = _("Each line must have the following format: 'At command description;AT command'. For user convenience, the file is saved to the location <code>/etc/atcommands.user</code>."); 

return view.extend({
	load: function() {
		return fs.list('/dev').then(function(devs) {
			return devs.filter(function(dev) {
				return dev.name.match(/ttyUSB/) || dev.name.match(/ttyAC/);
			});
		});
	},

	render: function(devs) {
		var m, s, o;
		m = new form.Map('atinout', _('Configuration'), _('Configuration panel for atinout.'));

		s = m.section(form.TypedSection, 'atinout', '', _(''));
		s.anonymous = true;

		o = s.option(form.Value, 'atc_port', _('Port for communication with the modem'), 
			_("Select serial modem port."));
		devs.sort((a, b) => a.name > b.name);
		devs.forEach(dev => o.value('/dev/' + dev.name));
		
		o.placeholder = _('Please select a port');
		o.rmempty = false;

		o = s.option(form.TextValue, '_tmpl', _('User AT commands'), cmddesc);
		o.rows = 20;
		o.cfgvalue = function(section_id) {
			return fs.trimmed('/etc/atcommands.user');
		};
		o.write = function(section_id, formvalue) {
			return fs.write('/etc/atcommands.user', formvalue.trim().replace(/\r\n/g, '\n') + '\n');
		};

		return m.render();
	}
});
