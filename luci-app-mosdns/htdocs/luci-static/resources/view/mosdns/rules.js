'use strict';
'require form';
'require fs';
'require ui';
'require view';

return view.extend({
	render: function () {
		var m, s, o;

		m = new form.Map("mosdns", _("Rule Settings"),
			_('The list of rules only apply to \'Default Config\' profiles.'));

		s = m.section(form.TypedSection);
		s.anonymous = true;
		s.sortable = true;

		s.tab('whitelist', _('White Lists'));
		s.tab('blocklist', _('Block Lists'));
		s.tab('greylist', _('Grey Lists'));
		s.tab('ddnslist', _('DDNS Lists'));
		s.tab('hostslist', _('Hosts'));
		s.tab('redirectlist', _('Redirect'));
		s.tab('localptrlist', _('Block PTR'));
		s.tab('streamingmedialist', _('Streaming Media'));

		o = s.taboption('whitelist', form.TextValue, '_whitelist',
			null,
			'<font color=\'red\'>'
			+ _('Added domain names always permit resolution using \'local DNS\' with the highest priority (one domain per line, supports domain matching rules).')
			+ '</font>'
		);
		o.rows = 25;
		o.cfgvalue = function (section_id) {
			return fs.trimmed('/etc/mosdns/rule/whitelist.txt').catch(function (e) {
				return "";
			});
		};
		o.write = function (section_id, formvalue) {
			return this.cfgvalue(section_id).then(function (value) {
				if (value == formvalue) {
					return;
				}
				return fs.write('/etc/mosdns/rule/whitelist.txt', formvalue.trim().replace(/\r\n/g, '\n') + '\n')
					.then(function (i) {
						ui.addNotification(null, E('p', _('Rules have been saved.')), 'info');
					})
					.catch(function (e) {
						ui.addNotification(null, E('p', _('Unable to save contents: %s').format(e.message)));
					});
			});
		};

		o = s.taboption('blocklist', form.TextValue, '_blocklist',
			null,
			'<font color=\'red\'>'
			+ _('Added domain names will block DNS resolution (one domain per line, supports domain matching rules).')
			+ '</font>'
		);
		o.rows = 25;
		o.cfgvalue = function (section_id) {
			return fs.trimmed('/etc/mosdns/rule/blocklist.txt').catch(function (e) {
				return "";
			});
		};
		o.write = function (section_id, formvalue) {
			return this.cfgvalue(section_id).then(function (value) {
				if (value == formvalue) {
					return;
				}
				return fs.write('/etc/mosdns/rule/blocklist.txt', formvalue.trim().replace(/\r\n/g, '\n') + '\n')
					.then(function (i) {
						ui.addNotification(null, E('p', _('Rules have been saved.')), 'info');
					})
					.catch(function (e) {
						ui.addNotification(null, E('p', _('Unable to save contents: %s').format(e.message)));
					});
			});
		};

		o = s.taboption('greylist', form.TextValue, '_greylist',
			null,
			'<font color=\'red\'>'
			+ _('Added domain names will always use \'Remote DNS\' for resolution (one domain per line, supports domain matching rules).')
			+ '</font>'
		);
		o.rows = 25;
		o.cfgvalue = function (section_id) {
			return fs.trimmed('/etc/mosdns/rule/greylist.txt').catch(function (e) {
				return "";
			});
		};
		o.write = function (section_id, formvalue) {
			return this.cfgvalue(section_id).then(function (value) {
				if (value == formvalue) {
					return;
				}
				return fs.write('/etc/mosdns/rule/greylist.txt', formvalue.trim().replace(/\r\n/g, '\n') + '\n')
					.then(function (i) {
						ui.addNotification(null, E('p', _('Rules have been saved.')), 'info');
					})
					.catch(function (e) {
						ui.addNotification(null, E('p', _('Unable to save contents: %s').format(e.message)));
					});
			});
		};

		o = s.taboption('ddnslist', form.TextValue, '_ddnslist',
			null,
			'<font color=\'red\'>'
			+ _('Added domain names will always use \'Local DNS\' for resolution, with a forced TTL of 5 seconds, and results will not be cached (one domain per line, supports domain matching rules).')
			+ '</font>'
		);
		o.rows = 25;
		o.cfgvalue = function (section_id) {
			return fs.trimmed('/etc/mosdns/rule/ddnslist.txt').catch(function (e) {
				return "";
			});
		};
		o.write = function (section_id, formvalue) {
			return this.cfgvalue(section_id).then(function (value) {
				if (value == formvalue) {
					return;
				}
				return fs.write('/etc/mosdns/rule/ddnslist.txt', formvalue.trim().replace(/\r\n/g, '\n') + '\n')
					.then(function (i) {
						ui.addNotification(null, E('p', _('Rules have been saved.')), 'info');
					})
					.catch(function (e) {
						ui.addNotification(null, E('p', _('Unable to save contents: %s').format(e.message)));
					});
			});
		};

		o = s.taboption('hostslist', form.TextValue, '_hostslist',
			null,
			'<font color=\'red\'>'
			+ _('Custom Hosts rewrite, for example: baidu.com 10.0.0.1 (one rule per line, supports domain matching rules).')
			+ '</font>'
		);
		o.rows = 25;
		o.cfgvalue = function (section_id) {
			return fs.trimmed('/etc/mosdns/rule/hosts.txt').catch(function (e) {
				return "";
			});
		};
		o.write = function (section_id, formvalue) {
			return this.cfgvalue(section_id).then(function (value) {
				if (value == formvalue) {
					return;
				}
				return fs.write('/etc/mosdns/rule/hosts.txt', formvalue.trim().replace(/\r\n/g, '\n') + '\n')
					.then(function (i) {
						ui.addNotification(null, E('p', _('Rules have been saved.')), 'info');
					})
					.catch(function (e) {
						ui.addNotification(null, E('p', _('Unable to save contents: %s').format(e.message)));
					});
			});
		};

		o = s.taboption('redirectlist', form.TextValue, '_redirectlist',
			null,
			'<font color=\'red\'>'
			+ _('Redirecting requests for domain names. Request domain A, but return records for domain B, for example: baidu.com qq.com (one rule per line).')
			+ '</font>'
		);
		o.rows = 25;
		o.cfgvalue = function (section_id) {
			return fs.trimmed('/etc/mosdns/rule/redirect.txt').catch(function (e) {
				return "";
			});
		};
		o.write = function (section_id, formvalue) {
			return this.cfgvalue(section_id).then(function (value) {
				if (value == formvalue) {
					return;
				}
				return fs.write('/etc/mosdns/rule/redirect.txt', formvalue.trim().replace(/\r\n/g, '\n') + '\n')
					.then(function (i) {
						ui.addNotification(null, E('p', _('Rules have been saved.')), 'info');
					})
					.catch(function (e) {
						ui.addNotification(null, E('p', _('Unable to save contents: %s').format(e.message)));
					});
			});
		};

		o = s.taboption('localptrlist', form.TextValue, '_localptrlist',
			null,
			'<font color=\'red\'>'
			+ _('Added domain names will block PTR requests (one domain per line, supports domain matching rules).')
			+ '</font>'
		);
		o.rows = 25;
		o.cfgvalue = function (section_id) {
			return fs.trimmed('/etc/mosdns/rule/local-ptr.txt').catch(function (e) {
				return "";
			});
		};
		o.write = function (section_id, formvalue) {
			return this.cfgvalue(section_id).then(function (value) {
				if (value == formvalue) {
					return;
				}
				return fs.write('/etc/mosdns/rule/local-ptr.txt', formvalue.trim().replace(/\r\n/g, '\n') + '\n')
					.then(function (i) {
						ui.addNotification(null, E('p', _('Rules have been saved.')), 'info');
					})
					.catch(function (e) {
						ui.addNotification(null, E('p', _('Unable to save contents: %s').format(e.message)));
					});
			});
		};

		o = s.taboption('streamingmedialist', form.TextValue, '_streamingmedialist',
			null,
			'<font color=\'red\'>'
			+ _('When enabling \'Custom Stream Media DNS\', added domains will always use the \'Streaming Media DNS server\' for resolution (one domain per line, supports domain matching rules).')
			+ '</font>'
		);
		o.rows = 25;
		o.cfgvalue = function (section_id) {
			return fs.trimmed('/etc/mosdns/rule/streaming.txt').catch(function (e) {
				return "";
			});
		};
		o.write = function (section_id, formvalue) {
			return this.cfgvalue(section_id).then(function (value) {
				if (value == formvalue) {
					return;
				}
				return fs.write('/etc/mosdns/rule/streaming.txt', formvalue.trim().replace(/\r\n/g, '\n') + '\n')
					.then(function (i) {
						ui.addNotification(null, E('p', _('Rules have been saved.')), 'info');
					})
					.catch(function (e) {
						ui.addNotification(null, E('p', _('Unable to save contents: %s').format(e.message)));
					});
			});
		};

		return m.render();
	},

	handleSaveApply: function (ev) {
		onclick = L.bind(this.handleSave, this, m);
		return fs.exec('/etc/init.d/mosdns', ['restart']);
	},
	handleReset: null
});
