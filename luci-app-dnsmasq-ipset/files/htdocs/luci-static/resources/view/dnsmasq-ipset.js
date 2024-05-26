'use strict'
'require form'

return L.view.extend({
	load: function() {

	},

	render: function(data) {
		var m, s, o, p;

		m = new form.Map("dnsmasq-ipset", _("DNSmasq IP-Set"), _("IP-Set settings for DNSMasq-full"));
		s = m.section(form.TypedSection, "ipsets", _("IP-Set Settings"));
		s.anonymous = true;
		s.addremove = true;

		o = s.option(form.Value, "ipset_name", _("IP-Set Name"));
		o.placeholder = "target ipset";
		o.default = "gfwlist";
		o.rmempty = false;

		o = s.option(form.Flag, "enabled", _("Enabled"));

		o = s.option(form.Flag, "dns_forward", _("Forward DNS Lookups"));

		p = s.option(form.Value, "upstream_dns_server", _("Upstream DNS Server"));
		p.placeholder = "Upstream DNS Server";
		p.default = "127.0.0.1#5353";
		p.rmempty = true;

		p.depends("dns_forward", "1");

		o = s.option(form.DynamicList, "managed_domain", _("Managed Domain List"));
		o.datatype = "host";

		return m.render();
	}
});
