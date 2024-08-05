'use strict';
'require ui';
'require view';
'require uci';
'require form';
'require rpc';
'require tools.widgets as widgets';

return view.extend({
	// RPC call to properly configure proxies:
	configure_proxies: rpc.declare({
		object: 'luci.squid-adv',
		method: 'reconfigure',
	}),
	cert_valid: rpc.declare({
		object: 'luci.squid-adv',
		method: 'cert_valid',
	}),
 
 	// Validate whether string passed is a valid IP/Port combination or just a valid Port:  
	validate_ip: function(section_id, value) {
		var ipv4 = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?):(6553[0-5]|655[0-2][0-9]|65[0-4][0-9][0-9]|6[0-4][0-9][0-9][0-9][0-9]|[1-5](\d){4}|[1-9](\d){0,3})$/;
		var ipv6 = /^(?:(?:[a-fA-F\d]{1,4}:){7}(?:[a-fA-F\d]{1,4}|:)|(?:[a-fA-F\d]{1,4}:){6}(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|:[a-fA-F\d]{1,4}|:)|(?:[a-fA-F\d]{1,4}:){5}(?::(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,2}|:)|(?:[a-fA-F\d]{1,4}:){4}(?:(?::[a-fA-F\d]{1,4}){0,1}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,3}|:)|(?:[a-fA-F\d]{1,4}:){3}(?:(?::[a-fA-F\d]{1,4}){0,2}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,4}|:)|(?:[a-fA-F\d]{1,4}:){2}(?:(?::[a-fA-F\d]{1,4}){0,3}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,5}|:)|(?:[a-fA-F\d]{1,4}:){1}(?:(?::[a-fA-F\d]{1,4}){0,4}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,6}|:)|(?::(?:(?::[a-fA-F\d]{1,4}){0,5}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,7}|:)))(?:%[0-9a-zA-Z]{1,})?$/gm;
		var port_only = /^(6553[0-5]|655[0-2][0-9]|65[0-4][0-9][0-9]|6[0-4][0-9][0-9][0-9][0-9]|[1-5](\d){4}|[1-9](\d){0,3})$/;
		if (ipv4.test(value) || ipv6.test(value) || port_only.test(value)) {
			return true;
		} else {
			return _("Invalid IP/Port or Port Range");
		}
	},

	// Loading function:
    load: function () {
        return Promise.all([
            this.cert_valid(),
        ]);
    },

	// Rendering function:
	render: function(data) {
		var m, o, i, s, t, valid = data[0].valid;
		if (!valid) {
			ui.addNotification(null, _("NOTICE: Server certificate missing!  ") + "&quot;" + _("Enable Transparent HTTPS Proxy") + "&quot " + _("setting will be not be shown until the server certificate has been generated!"), 'error' );
		}
		m = new form.Map('squid', _('Transparent Proxy Configuration'));

		s = m.section(form.TypedSection, 'transparent');
		s.anonymous = true;
		
		o = s.option(widgets.NetworkSelect, 'interface', _('Interface'), _('Transparent proxy only works on the specified interface.') + "<br />" + _("Do not use on interfaces controlled by programs like ") + '<a href="https://nodogsplashdocs.readthedocs.io/en/stable/">nodogsplash</a>!"));
		o.multiple = false;
		o.default = 'lan';

		o = s.option(form.Flag, "http_enabled", _("Enable Transparent HTTP Proxy") + ":")

		o = s.option(form.Value, "http_port", _("Bind for Transparent HTTP Proxy:"), _("Specify either IP address and Port combination, or just the Port."))
		o.validate = this.validate_ip;
		o.default = '3126'
		o.placeholder = "0-65535"
		o.depends("http_enabled", '1');

		o = s.option(form.HiddenValue, "cert_valid")
		o.cfgvalue = function(section_id) { return valid; }
		o.write = null;

		o = s.option(form.Flag, "https_enabled", _("Enable Transparent HTTPS Proxy") + ":")
		o.depends("cert_valid", '1')

		o = s.option(form.Value, "https_port", _("Bind for Transparent HTTPS Proxy:"), _("Specify either IP address and Port combination, or just the Port."))
		o.validate = this.validate_ip;
		o.default = '3127'
		o.placeholder = "0-65535"
		o.depends("https_enabled", '1');

		// mac_list = s.option(DynamicList, "transparent_mac", _("Allowed MACs for Transparent HTTPS Proxy:"))
		// nt.mac_hints(function(mac, name) mac_list :value(mac, "%s (%s)" %{ mac, name }) end)

		return m.render();
	},

	handleSaveApply: function(ev, mode) {
		var tasks = [ 
			this.handleSave(ev),
			this.configure_proxies(),
		];
		return Promise.all(tasks).then(function() {
			classes.ui.changes.apply(mode == '0');
		});
	},
})
