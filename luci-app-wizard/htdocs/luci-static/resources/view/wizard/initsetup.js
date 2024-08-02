'use strict';
'require view';
'require dom';
'require poll';
'require uci';
'require rpc';
'require form';
'require fs';

return view.extend({
	load: async function () {
		const promises = await Promise.all([
			fs.exec('/etc/init.d/wizard', ['reconfig']),
			uci.changes(),
			L.resolveDefault(uci.load('wireless')),
			uci.load('wizard'),
			L.resolveDefault(fs.stat('/www/luci-static/istorex/style.css'), null),
			L.resolveDefault(fs.stat('/www/luci-static/routerdog/style.css'), null),
			L.resolveDefault(fs.stat('/usr/sbin/nginx'), null)
		]);
	const data = {
			istorex: promises[4],
			routerdog: promises[5],
			nginx: promises[6]
		};
	return data;
	},

	render: function(data) {
		var m, s, o;
		var has_wifi = false;

		if (uci.sections('wireless', 'wifi-device').length > 0) {
			has_wifi = true;
		}

		m = new form.Map('wizard', [_('Initial Router Setup')],
			_('If you are using this router for the first time, please configure it here.'));

		s = m.section(form.NamedSection, 'default', 'wizard');
		s.addremove = false;
		s.tab('netsetup', _('Net Settings'), _('Three different ways to access the Internet, please choose according to your own situation.'));

		o = s.taboption('netsetup', form.ListValue, 'wan_proto', _('Protocol'));
		o.rmempty = false;
		o.value('dhcp', _('DHCP client'));
		o.value('pppoe', _('PPPoE'));

		o = s.taboption('netsetup', form.Value, 'wan_pppoe_user', _('PAP/CHAP username'));
		o.depends('wan_proto', 'pppoe');

		o = s.taboption('netsetup', form.Value, 'wan_pppoe_pass', _('PAP/CHAP password'));
		o.depends('wan_proto', 'pppoe');
		o.password = true;

		o = s.taboption('netsetup', form.Value, 'lan_ipaddr', _('IPv4 address'));
		o.datatype = 'ip4addr';

		o = s.taboption('netsetup', form.Value, 'lan_netmask', _('IPv4 netmask'));
		o.datatype = 'ip4addr';
		o.value('255.255.255.0');
		o.value('255.255.0.0');
		o.value('255.0.0.0');
		o.default = '255.255.255.0';

		o = s.taboption('netsetup', form.DynamicList, 'lan_dns', _('Use custom DNS servers'), _('Leave empty to use ISP DNS'));
		o.datatype = 'ip4addr';
		o.cast = 'string';

		o = s.taboption('netsetup', form.Flag, 'siderouter', _('Siderouter'),
			_('Use as downstream router i.e. it will work like a switch'));
		o.rmempty = false;

		o = s.taboption('netsetup', form.Value, 'lan_gateway', _('IPv4 gateway'));
		o.depends('siderouter', '1');
		o.datatype = 'ip4addr';
		o.placeholder = _('Enter the main router IP');
		o.rmempty = false;

		o = s.taboption('netsetup', form.Flag, 'dhcp', _('DHCP Server'),
			_('To turn on this DHCP, you need to turn off the DHCP of the main router, and to turn off this DHCP, you need to manually change the gateway and DNS of all Internet devices to the IP of this bypass router'));
		o.depends('siderouter', '1');
		o.default = o.enabled;

		o = s.taboption('netsetup', form.Flag, 'ipv6', _('Enable IPv6'), _('Enable/Disable IPv6'));
		o.default = o.enabled;

		s.tab('firmware', _('Firmware Settings'));

		// o = s.taboption('firmware', form.Flag, 'autoupgrade_pkg', _('Packages Auto Upgrade'),_('谨慎开启'));
		// o.rmempty = false;

		o = s.taboption('firmware', form.Flag, 'autoupgrade_fm', _('Firmware Upgrade Notice'));
		o.rmempty = false;

		o = s.taboption('firmware', form.Flag, 'coremark', _('CoreMark'), _('第一次开机后是否运行CPU跑分测试'));
		o.rmempty = false;

		o = s.taboption('firmware', form.Flag, 'cookie_p', _('Persistent cookies'),
			_('Keep the background login state to avoid the need to log in again every time the browser is closed'));
		o.default = o.enabled;
		
		if (data.istorex || data.routerdog){
		o = s.taboption('firmware', form.ListValue, 'landing_page', _('主题模式'));
		o.value('default', _('默认'));
		if (data.routerdog){
		o.value('routerdog', _('路由狗(专业NAS模式)'));
		}
		if (data.istorex){
		o.value('nas', _('NAS模式'));
		o.value('next-nas', _('NEXT-NAS模式'));
		o.value('router', _('路由模式'));
		}
		o.default = 'default';
		}

		if (has_wifi) {
			s.tab('wifisetup', _('Wireless Settings'), _('Set the router\'s wireless name and password. For more advanced settings, please go to the Network-Wireless page.'));
			o = s.taboption('wifisetup', form.Value, 'wifi_ssid', _('<abbr title=\"Extended Service Set Identifier\">ESSID</abbr>'));
			o.datatype = 'maxlength(32)';

			o = s.taboption("wifisetup", form.Value, "wifi_key", _("Key"));
			o.datatype = 'wpakey';
			o.password = true;
		}

		if (data.nginx) {
		s.tab('shortcuts', _('Shortcuts'), _('比如设置google.com的快捷方式为字母g,则在此路由器网络的任何浏览器中输入g/即可访问google.com'));

		o = s.taboption('shortcuts', form.SectionValue, 'shortcuts', form.GridSection, 'shortcuts', null,
			_('Shortcuts'));

		s = o.subsection;
		s.addremove = true;
		s.anonymous = true;

		o = s.option(form.Value, 'shortcut', _('Shortcut'));
		o.rmempty = false;

		o = s.option(form.Value, 'to_url', _('Target URL'));
		o.rmempty = false;
		o.placeholder = 'https://example.com';
		o.validate = function(section_id, value) {
		if (value.match(/^https?:\/\/.+/i)) {
			return true;
		}
    return _('Please enter a valid URL starting with http:// or https://');
};

		o = s.option(form.Value, 'comments', _('Comments'));
		o.optional  = true;
		}

		setTimeout("document.getElementsByClassName('cbi-button-apply')[0].children[3].children[0].value='1'", 1000)

		return m.render();
	}
});
