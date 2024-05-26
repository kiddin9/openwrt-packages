'use strict';
'require form';
'require view';
'require uci';
'require rpc';
'require tools.widgets as widgets';

return view.extend({
	handleEnableService: rpc.declare({
		object: 'luci',
		method: 'setInitAction',
		params: [ 'pingcontrol', 'enable' ],
		expect: { result: false }
	}),

	render: function() {
		var m, s, o;
		
		m = new form.Map('pingcontrol', _('PingControl'));
		m.description = _('Server availability check');

		s = m.section(form.GridSection, 'pingcontrol', _('Settings'));
		s.tab('general', _('General Settings'));
		s.tab('commands', _('Commands'));
		s.addremove = true;
		s.nodescriptions = true;

		o = s.taboption('general',form.Flag, 'enabled', _('Enabled'));
		o.rmempty = false;
		o.write = L.bind(function(section, value) {
			if (value == '1') {
				this.handleEnableService();
			}
			return uci.set('pingcontrol', section, 'enabled', value);
		}, this);

		o = s.taboption('general',widgets.NetworkSelect, 'iface', _('Ping interface'));
		o.rmempty = false;
		o.textvalue = function(section_id) {
			return uci.get('pingcontrol', section_id, 'iface');
		}

		o = s.taboption('general',form.DynamicList, 'testip', _('IP address or hostname of test servers'));
		o.datatype = 'or(hostname,ipaddr("nomask"))';

		o = s.taboption('general',form.Value, 'check_period', _('Period of check, sec'));
		o.rmempty = false;
		o.datatype = 'and(uinteger,min(20))';
		o.default = '60';

		o = s.taboption('general',form.Value, 'sw_before_modres', _('Failed attempts before iface up/down'), _('0 - not used'));
		o.rmempty = false;
		o.datatype = 'and(uinteger,min(0),max(100))';
		o.default = '3';

		o = s.taboption('general',form.Value, 'sw_before_sysres', _('Failed attempts before reboot'), _('0 - not used'));
		o.rmempty = false;
		o.datatype = 'and(uinteger,min(0),max(100))';
		o.default = '0';

		o = s.taboption('commands',form.Value, 'ping_ok', _('Successful ping'));
		o.modalonly = true;

		o = s.taboption('commands',form.Value, 'ping_lost', _('Ping lost'));
		o.modalonly = true;

		o = s.taboption('commands',form.Value, 'ping_restored', _('Ping restored'));
		o.modalonly = true;

		o = s.taboption('commands',form.Value, 'before_iface_down', _('Before interface down'));
		o.modalonly = true;

		o = s.taboption('commands',form.Value, 'after_iface_up', _('After interface up'));
		o.modalonly = true;

		o = s.taboption('commands',form.Value, 'before_reboot', _('Before reboot'));
		o.modalonly = true;

		return m.render();
	}
});
