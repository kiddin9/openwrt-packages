'use strict';
'require ui';
'require view';
'require uci';
'require form';
'require rpc';
'require tools.widgets as widgets';

return view.extend({
	cert_valid: rpc.declare({
		object: 'luci.squid-adv',
		method: 'cert_valid',
	}),

	// Loading function:
    load: function () {
        return Promise.all([
            this.cert_valid(),
        ]);
    },

	// Rendering function:
	render: function(data) {
		var s, o, m, t;
		m = new form.Map('squid', _('Squid Proxy Settings')); 

		s = m.section(form.TypedSection, 'squid');
		s.anonymous = true;

		o = s.option(form.Value, "_notBefore", translate("Current Certificate Not Valid Before:"))
		o.cfgvalue = function() { return data[0].notBefore; }
		o.write = null;
		o.readonly = true;

		o = s.option(form.Value, "_notAfter", translate("Current Certificate Not Valid After:"))
		o.cfgvalue = function() { return data[0].notAfter; }
		o.write = null;
		o.readonly = true;

		//-- generate = s:taboption("openssl", Button, "", "Generate Certificates")

/*-- OpenSSL Configuration

s:taboption("openssl", DummyValue, '', '').template = "squid/openssl-config"

bits= s:taboption("openssl", ListValue, "openssl_rsa_key_bits", translate("RSA Key Bit Size:"))
bits:value("4096", "4096 bits (" .. translate("Best") .. ")")
bits:value("2048", "2048 bits (" .. translate("Better") .. ")")
bits:value("1024", "1024 bits (" .. translate("Not Recommended") .. ")")
bits:value("512", "512 bits (" .. translate("Not Recommended") .. ")")
bits.rmempty = false
bits.default = "4096"

s:taboption("openssl", Value, "openssl_days", translate("Days The Certificate Is Good For:")).default = "3650"

s:taboption("openssl", Value, "openssl_countryName", translate("Country Name:")).default = "US"

s:taboption("openssl", Value, "openssl_stateOrProvinceName", translate("State Or Province Name:")).default = "Unspecified"

s:taboption("openssl", Value, "openssl_localityName", translate("Locality Name:")).default = "Unspecified"

s:taboption("openssl", Value, "openssl_organizationName", translate("Organization Name:")).default = "OpenWrt Router"

		o = s.option(form.Value, 'http_port', _('Regular Squid Proxy Port'));
		o.validate = this.validate_ip;

		o = s.option(form.Value, "visible_hostname", _("Visible Hostname"))
		o.placeholder = "OpenWrt"

		o = s.option(form.Value, "coredump_dir", _("Coredump files directory"))
		o.placeholder = "/tmp/squid"
*/

		return m.render();
	}
})
