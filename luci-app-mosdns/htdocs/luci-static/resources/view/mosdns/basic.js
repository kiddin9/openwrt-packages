'use strict';
'require form';
'require fs';
'require poll';
'require rpc';
'require uci';
'require ui';
'require view';

var callServiceList = rpc.declare({
	object: 'service',
	method: 'list',
	params: ['name'],
	expect: { '': {} }
});

function getServiceStatus() {
	return L.resolveDefault(callServiceList('mosdns'), {}).then(function (res) {
		var isRunning = false;
		try {
			isRunning = res['mosdns']['instances']['mosdns']['running'];
		} catch (e) { }
		return isRunning;
	});
}

function renderStatus(isRunning) {
	var spanTemp = '<em><span style="color:%s"><strong>%s %s</strong></span></em>';
	var renderHTML;
	if (isRunning) {
		renderHTML = spanTemp.format('green', _('MosDNS'), _('RUNNING'));
	} else {
		renderHTML = spanTemp.format('red', _('MosDNS'), _('NOT RUNNING'));
	}

	return renderHTML;
}

return view.extend({
	handleFlushCache: function (m, section_id, ev) {
		return fs.exec('/usr/share/mosdns/mosdns.sh', ['flush'])
			.then(function (lazy_cache) {
				var res = lazy_cache.code;
				if (res === 0) {
					ui.addNotification(null, E('p', _('Flushing DNS Cache Success.')), 'info');
				} else {
					ui.addNotification(null, E('p', _('Flushing DNS Cache Failed, Please check if MosDNS is running.')), 'error');
				}
			});
	},

	render: function () {
		var m, s, o;

		m = new form.Map('mosdns', _('MosDNS'),
			_('MosDNS is a plugin-based DNS forwarder/traffic splitter.'));

		s = m.section(form.TypedSection);
		s.anonymous = true;
		s.render = function () {
			poll.add(function () {
				return L.resolveDefault(getServiceStatus()).then(function (res) {
					var view = document.getElementById('service_status');
					view.innerHTML = renderStatus(res);
				});
			});

			return E('div', { class: 'cbi-section', id: 'status_bar' }, [
				E('p', { id: 'service_status' }, _('Collecting data...'))
			]);
		}

		s = m.section(form.NamedSection, 'config', 'mosdns');

		s.tab('basic', _('Basic Options'));
		s.tab("advanced", _("Advanced Options"));
		s.tab("cloudflare", _("Cloudflare Options"));
		s.tab("api", _("API Options"));
		s.tab('geodata', _('GeoData Export'));

		/* basic */
		o = s.taboption('basic', form.Flag, 'enabled', _('Enabled'));
		o.default = o.disabled;
		o.rmempty = false;

		o = s.taboption('basic', form.ListValue, 'configfile', _('Config File'));
		o.value('/var/etc/mosdns.json', _('Default Config'));
		o.value('/etc/mosdns/config_custom.yaml', _('Custom Config'));
		o.default = '/var/etc/mosdns.json';

		o = s.taboption('basic', form.Value, 'listen_port', _('Listen port'));
		o.default = '5335';
		o.datatype = 'port';
		o.depends('configfile', '/var/etc/mosdns.json');

		o = s.taboption('basic', form.ListValue, 'log_level', _('Log Level'));
		o.value('debug', _('Debug'));
		o.value('info', _('Info'));
		o.value('warn', _('Warning'));
		o.value('error', _('Error'));
		o.default = 'info';
		o.depends('configfile', '/var/etc/mosdns.json');

		o = s.taboption('basic', form.Value, 'log_file', _('Log File'));
		o.placeholder = '/var/log/mosdns.log';
		o.default = '/var/log/mosdns.log';
		o.depends('configfile', '/var/etc/mosdns.json');

		o = s.taboption('basic', form.Flag, 'redirect', _('DNS Forward'), _('Forward Dnsmasq Domain Name resolution requests to MosDNS'));
		o.default = false;

		o = s.taboption('basic', form.Flag, 'prefer_ipv4', _('Remote DNS prefer IPv4'),
			_('IPv4 is preferred for Remote / Streaming Media DNS resolution of dual-stack addresses, and is not affected when the destination is IPv6 only'));
		o.depends('configfile', '/var/etc/mosdns.json');
		o.default = false;

		o = s.taboption('basic', form.Flag, 'custom_local_dns', _('Custom China DNS'), _('Follow WAN interface DNS if not enabled'));
		o.depends('configfile', '/var/etc/mosdns.json');
		o.default = false;

		o = s.taboption('basic', form.Flag, 'apple_optimization', _('Apple domains optimization'),
			_('For Apple domains equipped with Chinese mainland CDN, always responsive to Chinese CDN IP addresses'));
		o.depends('custom_local_dns', '1');
		o.default = false;

		o = s.taboption('basic', form.DynamicList, 'local_dns', _('China DNS server'));
		o.value('119.29.29.29', _('Tencent Public DNS (119.29.29.29)'));
		o.value('119.28.28.28', _('Tencent Public DNS (119.28.28.28)'));
		o.value('223.5.5.5', _('Aliyun Public DNS (223.5.5.5)'));
		o.value('223.6.6.6', _('Aliyun Public DNS (223.6.6.6)'));
		o.value('180.184.1.1', _('TrafficRoute Public DNS (180.184.1.1)'));
		o.value('180.184.2.2', _('TrafficRoute Public DNS (180.184.2.2)'));
		o.value('114.114.114.114', _('Xinfeng Public DNS (114.114.114.114)'));
		o.value('114.114.115.115', _('Xinfeng Public DNS (114.114.115.115)'));
		o.value('180.76.76.76', _('Baidu Public DNS (180.76.76.76)'));
		o.value('https://doh.pub/dns-query', _('Tencent Public DNS (DNS over HTTPS)'));
		o.value('quic://dns.alidns.com', _('Aliyun Public DNS (DNS over QUIC)'));
		o.value('https://dns.alidns.com/dns-query', _('Aliyun Public DNS (DNS over HTTPS)'));
		o.value('h3://dns.alidns.com/dns-query', _('Aliyun Public DNS (DNS over HTTPS/3)'));
		o.value('https://doh.360.cn/dns-query', _('360 Public DNS (DNS over HTTPS)'));
		o.default = '119.29.29.29';
		o.depends('custom_local_dns', '1');

		o = s.taboption('basic', form.DynamicList, 'remote_dns', _('Remote DNS server'));
		o.value('tls://1.1.1.1', _('CloudFlare Public DNS (1.1.1.1)'));
		o.value('tls://1.0.0.1', _('CloudFlare Public DNS (1.0.0.1)'));
		o.value('tls://8.8.8.8', _('Google Public DNS (8.8.8.8)'));
		o.value('tls://8.8.4.4', _('Google Public DNS (8.8.4.4)'));
		o.value('tls://9.9.9.9', _('Quad9 Public DNS (9.9.9.9)'));
		o.value('tls://149.112.112.112', _('Quad9 Public DNS (149.112.112.112)'));
		o.value('tls://208.67.222.222', _('Cisco Public DNS (208.67.222.222)'));
		o.value('tls://208.67.220.220', _('Cisco Public DNS (208.67.220.220)'));
		o.default = 'tls://8.8.8.8';
		o.depends('configfile', '/var/etc/mosdns.json');

		o = s.taboption('basic', form.Flag, 'custom_stream_media_dns', _('Custom Stream Media DNS'),
			_('Netflix, Disney+, Hulu and streaming media rules list will use this DNS'));
		o.depends('configfile', '/var/etc/mosdns.json');
		o.default = false;

		o = s.taboption('basic', form.DynamicList, 'stream_media_dns', _('Streaming Media DNS server'));
		o.value('tls://1.1.1.1', _('CloudFlare Public DNS (1.1.1.1)'));
		o.value('tls://1.0.0.1', _('CloudFlare Public DNS (1.0.0.1)'));
		o.value('tls://8.8.8.8', _('Google Public DNS (8.8.8.8)'));
		o.value('tls://8.8.4.4', _('Google Public DNS (8.8.4.4)'));
		o.value('tls://9.9.9.9', _('Quad9 Public DNS (9.9.9.9)'));
		o.value('tls://149.112.112.112', _('Quad9 Public DNS (149.112.112.112)'));
		o.value('tls://208.67.222.222', _('Cisco Public DNS (208.67.222.222)'));
		o.value('tls://208.67.220.220', _('Cisco Public DNS (208.67.220.220)'));
		o.default = 'tls://8.8.8.8';
		o.depends('custom_stream_media_dns', '1');

		o = s.taboption('basic', form.ListValue, 'bootstrap_dns', _('Bootstrap DNS servers'),
			_('Bootstrap DNS servers are used to resolve IP addresses of the DoH/DoT resolvers you specify as upstreams'));
		o.value('119.29.29.29', _('Tencent Public DNS (119.29.29.29)'));
		o.value('119.28.28.28', _('Tencent Public DNS (119.28.28.28)'));
		o.value('223.5.5.5', _('Aliyun Public DNS (223.5.5.5)'));
		o.value('223.6.6.6', _('Aliyun Public DNS (223.6.6.6)'));
		o.value('114.114.114.114', _('Xinfeng Public DNS (114.114.114.114)'));
		o.value('114.114.115.115', _('Xinfeng Public DNS (114.114.115.115)'));
		o.value('180.76.76.76', _('Baidu Public DNS (180.76.76.76)'));
		o.value('8.8.8.8', _('Google Public DNS (8.8.8.8)'));
		o.value('1.1.1.1', _('CloudFlare Public DNS (1.1.1.1)'));
		o.default = '119.29.29.29';
		o.depends('configfile', '/var/etc/mosdns.json');

		/* advanced */
		o = s.taboption('advanced', form.Value, 'concurrent', _('Concurrent'),
			_('DNS query request concurrency, The number of upstream DNS servers that are allowed to initiate requests at the same time'));
		o.datatype = 'and(uinteger,min(1),max(3))';
		o.default = '2';
		o.depends('configfile', '/var/etc/mosdns.json');

		o = s.taboption('advanced', form.Value, 'idle_timeout', _('Idle Timeout'),
			_('DoH/TCP/DoT Connection Multiplexing idle timeout (default 30 seconds)'))
		o.datatype = 'and(uinteger,min(1))';
		o.default = '30';
		o.depends('configfile', '/var/etc/mosdns.json');

		o = s.taboption('advanced', form.Flag, 'enable_pipeline', _('TCP/DoT Connection Multiplexing'),
			_('Enable TCP/DoT RFC 7766 new Query Pipelining connection multiplexing mode'))
		o.rmempty = false;
		o.default = false;
		o.depends('configfile', '/var/etc/mosdns.json');

		o = s.taboption('advanced', form.Flag, 'insecure_skip_verify', _('Disable TLS Certificate'),
			_('Disable TLS Servers certificate validation, Can be useful if system CA certificate expires or the system time is out of order'));
		o.rmempty = false;
		o.default = false;
		o.depends('configfile', '/var/etc/mosdns.json');

		o = s.taboption('advanced', form.Flag, 'enable_ecs_remote',
			_('Enable EDNS client subnet'));
		o.rmempty = false;
		o.default = false;
		o.depends('configfile', '/var/etc/mosdns.json');

		o = s.taboption('advanced', form.Value, 'remote_ecs_ip', _('IP Address'),
			_('Please provide the IP address you use when accessing foreign websites. This IP subnet (0/24) will be used as the ECS address for Remote / Streaming Media DNS requests') +
			_('This feature is typically used when using a self-built DNS server as an Remote / Streaming Media DNS upstream (requires support from the upstream server)'));
		o.datatype = 'ipaddr';
		o.depends('enable_ecs_remote', '1');

		o = s.taboption('advanced', form.Flag, 'dns_leak', _('Prevent DNS Leaks'),
			_('Enable this option fallback policy forces forwarding to remote DNS'));
		o.rmempty = false;
		o.default = false;
		o.depends('configfile', '/var/etc/mosdns.json');

		o = s.taboption('advanced', form.Flag, 'cache', _('Enable DNS Cache'));
		o.rmempty = false;
		o.default = false;
		o.depends('configfile', '/var/etc/mosdns.json');

		o = s.taboption('advanced', form.Value, 'cache_size', _('DNS Cache Size'),
			_('DNS cache size (in piece). To disable caching, please set to 0.'));
		o.datatype = 'and(uinteger,min(0))';
		o.default = 8000;
		o.depends('cache', '1');

		o = s.taboption('advanced', form.Value, 'lazy_cache_ttl', _('Lazy Cache TTL'),
			_('Lazy cache survival time (in second). To disable Lazy Cache, please set to 0.'));
		o.datatype = 'and(uinteger,min(0))';
		o.default = 86400;
		o.depends('cache', '1');

		o = s.taboption('advanced', form.Flag, 'dump_file', _('Cache Dump'),
			_('Save the cache locally and reload the cache dump on the next startup'));
		o.rmempty = false;
		o.default = false;
		o.depends('cache', '1');

		o = s.taboption('advanced', form.Value, 'dump_interval',
			_('Auto Save Cache Interval'));
		o.datatype = 'and(uinteger,min(0))';
		o.default = 3600;
		o.depends('dump_file', '1');

		o = s.taboption('advanced', form.Value, 'minimal_ttl', _('Minimum TTL'),
			_('Modify the Minimum TTL value (seconds) for DNS answer results, 0 indicating no modification'));
		o.datatype = 'and(uinteger,min(0),max(604800))';
		o.default = 0;
		o.depends('configfile', '/var/etc/mosdns.json');

		o = s.taboption('advanced', form.Value, 'maximum_ttl', _('Maximum TTL'),
			_('Modify the Maximum TTL value (seconds) for DNS answer results, 0 indicating no modification'));
		o.datatype = 'and(uinteger,min(0),max(604800))';
		o.default = 0;
		o.depends('configfile', '/var/etc/mosdns.json');

		o = s.taboption('advanced', form.Flag, 'adblock', _('Enable DNS ADblock'));
		o.depends('configfile', '/var/etc/mosdns.json');
		o.default = false;

		o = s.taboption('advanced', form.DynamicList, 'ad_source', _('ADblock Source'),
			_('When using custom rule sources, please use rule types supported by MosDNS (domain lists).') +
			'<br>' +
			_('Support for local files, such as: file:///var/mosdns/example.txt'));
		o.depends('adblock', '1');
		o.default = 'geosite.dat';
		o.value('geosite.dat', 'v2ray-geosite');
		o.value('https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-domains.txt', 'anti-AD')
		o.value('https://raw.githubusercontent.com/Cats-Team/AdRules/main/mosdns_adrules.txt', 'Cats-Team/AdRules')
		o.value('https://raw.githubusercontent.com/neodevpro/neodevhost/master/domain', 'NEO DEV HOST')

		/* cloudflare */
		o = s.taboption('cloudflare', form.Flag, 'cloudflare', _('Enabled'),
			_('Match the parsing result with the Cloudflare IP ranges, and when there is a successful match, \
				use the \'Custom IP\' as the parsing result (experimental feature)'));
		o.rmempty = false;
		o.default = false;
		o.depends('configfile', '/var/etc/mosdns.json');

		o = s.taboption('cloudflare', form.DynamicList, 'cloudflare_ip', _('Custom IP'));
		o.datatype = 'ipaddr';
		o.depends('configfile', '/var/etc/mosdns.json');

		o = s.taboption('cloudflare', form.TextValue, '_cloudflare',
			_('Cloudflare IP Ranges'),
			_('IPv4 CIDR: <a href="https://www.cloudflare.com/ips-v4" target="_blank">https://www.cloudflare.com/ips-v4</a> <br /> IPv6 CIDR: <a href="https://www.cloudflare.com/ips-v6" target="_blank">https://www.cloudflare.com/ips-v6</a>'));
		o.rows = 15;
		o.depends('configfile', '/var/etc/mosdns.json');
		o.cfgvalue = function (section_id) {
			return fs.trimmed('/etc/mosdns/rule/cloudflare-cidr.txt');
		};
		o.write = function (section_id, formvalue) {
			return fs.write('/etc/mosdns/rule/cloudflare-cidr.txt', formvalue.trim().replace(/\r\n/g, '\n') + '\n')
				.then(function (i) {
					return fs.exec('/etc/init.d/mosdns', ['restart']);
				});
		};

		/* api */
		o = s.taboption('api', form.Value, 'listen_port_api', _('API Listen port'));
		o.datatype = 'and(port,min(1))';
		o.default = 9091;
		o.depends('configfile', '/var/etc/mosdns.json');

		o = s.taboption('api', form.Button, '_flush_cache', null,
			_('Flushing DNS Cache will clear any IP addresses or DNS records from MosDNS cache.'));
		o.title = '&#160;';
		o.inputtitle = _('Flush DNS Cache');
		o.inputstyle = 'apply';
		o.onclick = L.bind(this.handleFlushCache, this, m);
		o.depends('cache', '1');

		/* configuration */
		o = s.taboption('basic', form.TextValue, '_custom', _('Configuration Editor'),
			_('This is the content of the file \'/etc/mosdns/config_custom.yaml\' from which your MosDNS configuration will be generated. \
			Only accepts configuration content in yaml format.'));
		o.rows = 25;
		o.depends('configfile', '/etc/mosdns/config_custom.yaml');
		o.cfgvalue = function (section_id) {
			return fs.trimmed('/etc/mosdns/config_custom.yaml');
		};
		o.write = function (section_id, formvalue) {
			return fs.write('/etc/mosdns/config_custom.yaml', formvalue.trim().replace(/\r\n/g, '\n') + '\n')
				.then(function (i) {
					ui.addNotification(null, E('p', _('Configuration have been saved.')), 'info');
					return fs.exec('/etc/init.d/mosdns', ['restart']);
				})
				.catch(function (e) {
					ui.addNotification(null, E('p', _('Unable to save contents: %s').format(e.message)));
				});
		};

		o = s.taboption('geodata', form.DynamicList, 'geosite_tags', _('GeoSite Tags'),
			_('Enter the GeoSite.dat category to be exported, Allow add multiple tags'),
			_('Export directory: /var/mosdns'));
		o.depends('configfile', '/etc/mosdns/config_custom.yaml');

		o = s.taboption('geodata', form.DynamicList, 'geoip_tags', _('GeoIP Tags'),
			_('Enter the GeoIP.dat category to be exported, Allow add multiple tags'),
			_('Export directory: /var/mosdns'));
		o.depends('configfile', '/etc/mosdns/config_custom.yaml');

		return m.render();
	}
});
