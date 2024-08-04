'use strict';
'require view';
'require poll';
'require fs';
'require rpc';
'require uci';
'require form';

var conf = 'alwaysonline';
var instance = 'alwaysonline';

var callServiceList = rpc.declare({
	object: 'service',
	method: 'list',
	params: ['name'],
	expect: { '': {} }
});

function getServiceStatus() {
	return L.resolveDefault(callServiceList(conf), {})
		.then(function (res) {
			var isrunning = false;
			try {
				isrunning = res[conf]['instances'][instance]['running'];
			} catch (e) { }
			return isrunning;
		});
}

return view.extend({
//	handleSaveApply: null,
//	handleSave: null,
//	handleReset: null,

	load: function() {
	return Promise.all([
		getServiceStatus(),
		uci.load('alwaysonline')
	]);
	},

	poll_status: function(nodes, stat) {
		var isRunning = stat[0],
			view = nodes.querySelector('#service_status');

		if (isRunning) {
			view.innerHTML = "<span style=\"color:green;font-weight:bold\">" + instance + " - " + _("SERVER RUNNING") + "</span>";
		} else {
			view.innerHTML = "<span style=\"color:red;font-weight:bold\">" + instance + " - " + _("SERVER NOT RUNNING") + "</span>";
		}
		return;
	},

	render: function(res) {
		var isRunning = res[0];

		var m, s, o;

		m = new form.Map('alwaysonline', _('AlwaysOnline'),
			_('<a href="%s" target="_blank"><b>AlwaysOnline</b></a> is a HTTP server which mocks a lot network/internet/portal detection servers.').format('https://github.com/Jamesits/alwaysonline'));

		s = m.section(form.NamedSection, '_status');
		s.anonymous = true;
		s.render = function (section_id) {
			return E('div', { class: 'cbi-section' }, [
				E('div', { id: 'service_status' }, _('Collecting data ...'))
			]);
		};

		s = m.section(form.NamedSection, 'global', 'alwaysonline');
		s.anonymous = true;

		o = s.option(form.Flag, 'enabled', _('Enable'));
		o.rmempty = false;

		s = m.section(form.GridSection, 'domain', _('Apply to Domains'));
		s.sortable  = true;
		s.anonymous = true;
		s.addremove = true;

		o = s.option(form.Flag, 'enabled', _('Enable'));
		o.default = o.enabled;
		o.editable = true;
		o.rmempty = false;

		o = s.option(form.Value, 'name', _('Domain'));
		o.datatype = 'hostname';
		o.rmempty = false;

		o = s.option(form.Value, 'group', _('Group'));
		o.rmempty = true;
		//o.modalonly = true;

		o = s.option(form.ListValue, 'family', _('Address family'));
		o.value('4', 'IPv4');
		o.value('6', 'IPv6');
		o.value('both', _('Both'));
		o.default = 'both';
		o.rmempty = false;

		o = s.option(form.Value, 'overwrite', _('Address overwrite'));
		o.datatype = 'ipaddr(1)';
		o.rmempty = true;
		o.depends('family', '4');
		o.depends('family', '6');

		return m.render()
		.then(L.bind(function(m, nodes) {
			poll.add(L.bind(function() {
				return Promise.all([
					getServiceStatus()
				]).then(L.bind(this.poll_status, this, nodes));
			}, this), 3);
			return nodes;
		}, this, m));
	}
});
