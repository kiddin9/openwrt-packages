'use strict';
'require form';
'require fs';
'require view';
'require uci';
'require ui';
'require tools.widgets as widgets'


return view.extend({
	load: function(){
		uci.load('3proxy');
	},

	render: function(data) {
		var config = uci.sections('3proxy');
		var file = (config.config);
		var m, s, o;

		m = new form.Map('3proxy', _('Configuration'), _('Configuration file for 3proxy.'));

		s = m.section(form.TypedSection, '3proxy', null);
		s.anonymous = true;

		o = s.option(form.TextValue, '_tmpl', _('Edit config 3proxy'));
		o.rows = 20;
		o.cfgvalue = function(section_id) {
			return fs.trimmed('/etc/3proxy.cfg');
		};
		o.write = function(section_id, formvalue) {
			return fs.write(('/etc/3proxy.cfg'), formvalue.trim().replace(/\r\n/g, '\n') + '\n');
		};

		return m.render();
	}
});
