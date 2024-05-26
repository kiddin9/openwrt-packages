'use strict';
'require form';
'require rpc';
'require fs';
'require view';
'require uci';
'require ui';
'require tools.widgets as widgets'


/*
	Written by Konstantine Shevlakov at <shevlakov@132lan.ru> 2023

	Licensed to the GNU General Public License v3.0.

*/

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
		return rv.sort((a, b) => a.name > b.name);
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

var maindesc = _('Modeminfo: Configuration');
var mdesc = _('Configuration panel of Modeminfo.');
var qfdesc = _('Get modem data via qmicli (experimental). Require install qmi-utils.');
var sdesc = _('Select serial port.');
var qdesc = _('Select qmi port.');
var lacdec = _('Show LAC and CID in decimal.');
var mmdesc = _('Get device hardware name via mmcli utility if aviable.');
var qmidesc = _('Enable qmi-proxy mode.');
var idesc = _('Short info on Overview page');
var portplace = _('Please select a port');

return view.extend({
	render: function(){
		var m, s, o;
		m = new form.Map('modeminfo', maindesc, mdesc);

		s = m.section(form.TypedSection, 'general', _('General option'), null);
		s.anonymous = true;

		o = s.option(form.Flag, 'index', _('Index page'), idesc);
		s.anonymous = true;
		o.rmempty = true;

		o = s.option(form.Flag, 'decimail', _('Show decimal'), lacdec);
		o.rmempty = true;

		o = s.option(form.ListValue, 'delay', _('Interval'), _('Poll interval data'));
		o.value('', _('none'));
		o.value('1', '1 '+_('sec'));
		o.value('2', '2 '+_('sec'));
		o.value('5', '5 '+_('sec'));
		o.value('10', '10 '+_('sec'));
		o.value('30', '30 '+_('sec'));

		s = m.section(form.TypedSection, 'modeminfo', _('Devices setup'), null);
		s.anonymous = true;
		s.addremove = true;

		o = s.option(form.Flag, 'qmi_mode', _('Use QMI'), qfdesc);
		o.rmempty = true;

		o = s.option(form.ListValue, 'device', _('Data port'), sdesc);
		o.load = function(section_id) {
			return callSerialPort('/dev/').then(L.bind(function(devices) {
				for (var i = 0; i < devices.length; i++)
					this.value(devices[i]);
				return form.Value.prototype.load.apply(this, [section_id]);
			}, this));
		};
		o.placeholder = portplace;
		o.rmempty = true;
		o.depends('qmi_mode', '0');

		o = s.option(form.ListValue, 'device_qmi', _('Data port'), qdesc);
		o.load = function(section_id) {
			return callQMIPort('/dev/').then(L.bind(function(devices) {
				for (var i = 0; i < devices.length; i++)
					this.value(devices[i]);
				return form.Value.prototype.load.apply(this, [section_id]);
			}, this));
		};
		o.placeholder = portplace;
		o.rmempty = true;
		o.depends('qmi_mode', '1');

		o = s.option(form.Flag, 'mmcli_name', _('Name via mmcli'), mmdesc);
		o.rmempty = true;
		o.depends('qmi_mode', '0');

		o = s.option(form.Flag, 'qmi_proxy', _('QMI proxy'), qmidesc);
		o.rmempty = true;
		o.depends('qmi_mode', '1');

		return m.render();
	}	
});
