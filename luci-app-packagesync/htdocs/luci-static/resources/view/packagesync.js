'use strict';
'require view';
'require poll';
'require fs';
'require uci';
'require ui';
'require dom';
'require rpc';
'require form';

var mntpkgs = '/mnt/packagesync';
var mntreg = RegExp(/\/mnt\/packagesync/);
var conf = 'packagesync';
var release = 'release';
var instance = 'sync';

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
		L.resolveDefault(fs.read('/var/packagesync/releaseslist'), null),
		L.resolveDefault(fs.read('/var/packagesync/targetslist'), null),
		L.resolveDefault(fs.read('/var/packagesync/pkgarchslist'), null),
		L.resolveDefault(fs.stat('/var/run/packagesync.pid'), {}),
		L.resolveDefault(fs.exec('/etc/init.d/packagesync', ['checkln']), {}),
		L.resolveDefault(fs.exec('/bin/df', ['-hT']), {}),
		getServiceStatus(),
		uci.load('packagesync')
	]);
	},

	poll_status: function(nodes, stat) {
		var isRunning = stat[0],
			view = nodes.querySelector('#sync_status');

		if (isRunning) {
			view.innerHTML = "<span style=\"color:green;font-weight:bold\">" + _("SYNC IN PROGRESS") + "</span>";
		} else {
			view.innerHTML = "<span style=\"color:red;font-weight:bold\">" + _("SYNC NOT IN PROGRESS") + "</span>";
		}
		return;
	},

	render: function(res) {
		var releaseslist = res[0] ? res[0].trim().split("\n") : [],
			targetslist = res[1] ? res[1].trim().split("\n") : [],
			pkgarchslist = res[2] ? res[2].trim().split("\n") : [],
			locked = res[3].path,
			usedname = res[4].stdout ? res[4].stdout.trim().split("\n") : [],
			storages = res[5].stdout ? res[5].stdout.trim().split("\n") : [],
			isRunning = res[6];

		var storage = [];
		if (storages.length) {
			for (var i = 1; i < storages.length; i++) {
				if (storages[i].match(mntreg)) {
					storage = storages[i].trim().split(/\s+/, 7);
					break;
				}
			}
		};

		var m, s, o;

		m = new form.Map('packagesync');

		s = m.section(form.NamedSection, 'config', 'packagesync', _('Local software source'),
			_('packagesync used to build a local mirror feeds source on the router<br/>\
			To use packagesync, you need to prepare a storage device with a size of at least <b>16G</b> and connect it to the router<br/>\
			then open <a href="%s"><b>Mount Points</b></a>, find the connected device and set its mount point to <b>%s</b>, check <b>Enabled</b> and click <b>Save&Apple</b>')
			.format(L.url('admin', 'system', 'mounts'), mntpkgs));
		s.anonymous = true;

		o = s.option(form.DummyValue, '_status', _('Running Status'));
		o.rawhtml = true;

		if (isRunning) {
			o.cfgvalue = function(s) {
				return E('div', { class: 'cbi-section' }, [
					E('div', { id: 'sync_status' }, [
						E('span', { 'style': 'color:green;font-weight:bold' }, [ _("SYNC IN PROGRESS") ])
					])
				]);
			}
		} else {
			o.cfgvalue = function(s) {
				return E('div', { class: 'cbi-section' }, [
					E('div', { id: 'sync_status' }, [
						E('span', { 'style': 'color:red;font-weight:bold' }, [ _("SYNC NOT IN PROGRESS") ])
					])
				]);
			}
		};

		o = s.option(form.Value, 'home_url', _('Home URL'),
			_('Open <a href="/%s" target="_blank">URL</a>').format(uci.get('packagesync', '@packagesync[0]', 'home_url')));
		o.placeholder = 'packagesync';
		o.rmempty = false;
		o.validate = function(section, value) {
			if (value == null || value == '' || value == 'ignore')
				return _('Expecting: non-empty value');
        
			if (usedname.length)
				for (var i = 0; i < usedname.length; i++)
					if (usedname[i] == value)
						return _('The Name %h is already used').format(value);
        
			return true;
		};
		o.write = function(section, value) {
			uci.set('packagesync', section, 'home_url', value);
			fs.exec('/etc/init.d/packagesync', ['symln', value]);
		};

		o = s.option(form.Button, '_exec_now', _('Execute'));
		o.inputtitle = _('Execute');
		o.inputstyle = 'apply';
		if ((! storage.length) || locked)
			o.readonly = true;
		o.onclick = function() {
			window.setTimeout(function() {
				window.location = window.location.href.split('#')[0];
			}, L.env.apply_display * 500);

			return fs.exec('/etc/init.d/packagesync', ['start'])
				.catch(function(e) { ui.addNotification(null, E('p', e.message), 'error') });
		};

		o = s.option(form.ListValue, 'bwlimit', _('Bandwidth Limit'));
		o.value('0', _('Unlimited'));
		o.value('100', _('100 KB/s'));
		o.value('200', _('200 KB/s'));
		o.value('300', _('300 KB/s'));
		o.value('500', _('500 KB/s'));
		o.value('800', _('800 KB/s'));
		o.value('1000', _('1 MB/s'));
		o.value('2000', _('2 MB/s'));
		o.value('3000', _('3 MB/s'));
		o.value('5000', _('5 MB/s'));
		o.value('8000', _('8 MB/s'));
		o.value('10000', _('10 MB/s'));
		o.value('20000', _('20 MB/s'));
		o.value('30000', _('30 MB/s'));
		o.value('50000', _('50 MB/s'));
		o.value('80000', _('80 MB/s'));
		o.value('100000', _('100 MB/s'));
		o.default = '8000';
		o.rmempty = false;

		o = s.option(form.Flag, 'auto_exec', _('Auto Exec'));
		o.default = o.enabled;
		o.rmempty = false;
		o.write = function(section, value) {
			uci.set('packagesync', section, 'auto_exec', value);
			if (value == 1) {
				fs.exec('/etc/init.d/packagesync', ['setcron', uci.get('packagesync', '@packagesync[0]', 'cron_expression')]);
			} else {
				fs.exec('/etc/init.d/packagesync', ['setcron']);
			}
		};

		o = s.option(form.Value, 'cron_expression', _('Cron expression'),
			_('The default value is 0:00 every day'));
		o.default = '0 0 * * *';
		o.placeholder = '0 0 * * *';
		o.rmempty = false;
		o.retain = true;
		o.depends('auto_exec', '1');
		o.write = function(section, value) {
			uci.set('packagesync', section, 'cron_expression', value);
			fs.exec('/etc/init.d/packagesync', ['setcron', value]);
		};
		o.remove = function(section, value) {
			//uci.unset('packagesync', section, 'cron_expression');
			fs.exec('/etc/init.d/packagesync', ['setcron']);
		};

		o = s.option(form.Flag, 'proxy_enabled', _('Enable proxy'));
		o.rmempty = false;

		o = s.option(form.ListValue, 'proxy_protocol', _('Proxy Protocol'));
		o.value('http', 'HTTP');
		o.value('https', 'HTTPS');
		o.value('socks5', 'SOCKS5');
		o.value('socks5h', 'SOCKS5H');
		o.default = 'socks5';
		o.rmempty = false;
		o.retain = true;
		o.depends('proxy_enabled', '1');

		o = s.option(form.Value, 'proxy_server', _('Proxy Server'));
		o.datatype = "ipaddrport(1)";
		o.placeholder = '192.168.1.10:1080';
		o.rmempty = false;
		o.retain = true;
		o.depends('proxy_enabled', '1');

		o = s.option(form.Button, '_list_invalid', _('List removable versions'));
		o.inputtitle = _('List');
		o.inputstyle = 'apply';
		if (! storage.length)
			o.readonly = true;
		o.onclick = function(ev, section_id) {
			let precontent = document.getElementById('cleanup-output');

			return fs.exec('/etc/init.d/packagesync', ['cleanup'])
				.then(function(res) { dom.content(precontent, [ res.stdout.trim().length ? res.stdout.trim() : _('no objects need to remove.'), res.stderr ? res.stderr : '' ]) })
				.catch(function(err) { ui.addNotification(null, E('p', err.message), 'error') });
		};

		o = s.option(form.DummyValue, '_removable_versions', '　');
		o.rawhtml = true;
		o.cfgvalue = function(section_id) {
			return E('pre', { 'id': 'cleanup-output' }, []);
		};

		s = m.section(form.GridSection, '_storage');

		s.render = L.bind(function(view, section_id) {
			var table = E('table', { 'class': 'table cbi-section-table', 'id': 'storage_device' }, [
				E('tr', { 'class': 'tr table-titles' }, [
					E('th', { 'class': 'th' }, _('Filesystem')),
					E('th', { 'class': 'th' }, _('Type')),
					E('th', { 'class': 'th' }, _('Size')),
					E('th', { 'class': 'th' }, _('Used')),
					E('th', { 'class': 'th' }, _('Available')),
					E('th', { 'class': 'th' }, _('Used') + ' %'),
					E('th', { 'class': 'th' }, _('Mount point')),
					E('th', { 'class': 'th cbi-section-actions' }, '')
				])
			]);
			var rows = [];
			if (storage.length) {
				storage[5] = E('div', { 'class': 'cbi-progressbar', 'title': storage[5], 'style': 'min-width:8em !important' }, E('div', { 'style': 'width:' + storage[5] }))
				//storage[5] = E('div', { 'class': 'cbi-progressbar', 'title': storage[3] + ' / ' + storage[2] + ' (' + storage[5] + ')', 'style': 'min-width:8em !important' }, [
				//	E('div', { 'style': 'width:' + storage[5] })
				//]);
				rows.push(storage);
			};

			cbi_update_table(table, rows, E('em', _('<span style=\'color:red;font-weight:bold\'>Device not exist or mount point in the wrong location<span/>')));
			return E('div', { 'class': 'cbi-section cbi-tblsection' }, [
					E('h3', _('Storage Device')), table ]);
		}, o, this);

		s = m.section(form.GridSection, 'release', _('Mirror Releases'));
		s.sortable  = true;
		s.anonymous = true;
		s.addremove = true;

		o = s.option(form.Value, 'name', _('Nick name'));
		o.datatype = 'uciname';
		o.rmempty = false;
		o.validate = function(section_id, value) {
			if (value == null || value == '' || value == 'ignore')
				return _('Expecting: non-empty value');

			let ss = uci.sections(conf, release);
			for (var i = 0; i < ss.length; i++) {
				let sid = ss[i]['.name'];
				if (sid == section_id)
					continue;
				if (value == uci.get(conf, sid, 'name'))
					return _('The Nick name is already used');
			};

			return true;
		};

		o = s.option(form.Flag, 'enabled', _('Enable'));
		o.default = o.enabled;
		o.editable = true;
		o.rmempty = false;

		o = s.option(form.Button, '_getinfo', _('Get Option Info'));
		o.modalonly = true;
		o.write = function() {};
		o.onclick = function() {
			return fs.exec('/etc/init.d/packagesync', ['getinfo'])
				.then(function(res) { return window.location.reload() })
				.catch(function(e) { ui.addNotification(null, E('p', e.message), 'error') });
		};

		o = s.option(form.Value, 'version', _('Version'));
		o.rmempty = false;
		o.validate = function(section, value) {
			if (value == null || value == '' || value == 'ignore')
				return _('Expecting: non-empty value');
			return true;
		};

		if (releaseslist.length) {
			for (var i = 0; i < releaseslist.length; i++)
				o.value(releaseslist[i]);
		};

		o = s.option(form.Value, 'target', _('Target'));
		o.rmempty = false;
		o.validate = function(section, value) {
			if (value == null || value == '' || value == 'ignore')
				return _('Expecting: non-empty value');
			return true;
		};

		if (targetslist.length) {
			for (var i = 0; i < targetslist.length; i++)
				o.value(targetslist[i]);
		};

		o = s.option(form.Value, 'subtarget', _('SubTarget'));
		o.value('32');
		o.value('64');
		o.value('generic');
		o.value('legacy');
		o.value('nand');
		o.value('mikrotik');
		o.value('armv8');
		o.rmempty = false;
		o.validate = function(section, value) {
			if (value == null || value == '' || value == 'ignore')
				return _('Expecting: non-empty value');
			return true;
		};

		o = s.option(form.Flag, 'extra', _('Supplementary Files'));
		o.default = o.disabled;
		o.rmempty = false;
		o.modalonly = true;

		o = s.option(form.Value, 'pkgarch', _('Arch'));
		o.rmempty = false;
		o.validate = function(section, value) {
			if (value == null || value == '' || value == 'ignore')
				return _('Expecting: non-empty value');
			return true;
		};

		if (pkgarchslist.length) {
			for (var i = 0; i < pkgarchslist.length; i++)
				o.value(pkgarchslist[i]);
		};

		o = s.option(form.Value, 'model', _('Product model'));
		o.rmempty = true;

		o = s.option(form.DummyValue, 'return', _('Last exec result'));
		o.readonly = true;

		o = s.option(form.DummyValue, '_return_log', _('Last Error log'));
		o.editable = true;
		o.readonly = true;
		//o.rawhtml = true;
		//o.modalonly = true;
		o.cfgvalue = function(section_id) {
			let href = uci.get('packagesync', '@packagesync[0]', 'home_url');
			let result = uci.get('packagesync', section_id, 'name');
			return E('span', { 'style': 'font-weight:bold' }, [ E('a', { 'href': '/' + href + '/results/' + result + '.log', 'target': '_blank' }, _('Click to view')) ]);
		};

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
