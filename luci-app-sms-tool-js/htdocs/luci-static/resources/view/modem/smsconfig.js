'use strict';
'require form';
'require fs';
'require view';
'require uci';
'require ui';
'require tools.widgets as widgets'

/*
	Copyright 2022-2024 Rafał Wabik - IceG - From eko.one.pl forum
	
	Licensed to the GNU General Public License v3.0.
*/


return view.extend({
	load: function() {
		return fs.list('/dev').then(function(devs) {
			return devs.filter(function(dev) {
				return dev.name.match(/^ttyUSB/) || dev.name.match(/^cdc-wdm/) || dev.name.match(/^ttyACM/) || dev.name.match(/^mhi_/) || dev.name.match(/^wwan/);
			});
		});
	},

	render: function(devs) {
		var m, s, o;
		m = new form.Map('sms_tool_js', _('Configuration sms-tool'), _('Configuration panel for sms-tool and gui application.'));

		s = m.section(form.TypedSection, 'sms_tool_js', '', null);
		s.anonymous = true;

		//TAB SMS

		s.tab('smstab' , _('SMS Settings'));
		s.anonymous = true;

		o = s.taboption('smstab' , form.Value, 'readport', _('SMS reading port'), 
			_('Select one of the available ttyUSBX ports.'));
		devs.sort((a, b) => a.name > b.name);
		devs.forEach(dev => o.value('/dev/' + dev.name));
		
		o.placeholder = _('Please select a port');
		o.rmempty = false;
		
		o = s.taboption('smstab', form.ListValue, 'storage', _('Message storage area'),
		_('Messages are stored in a specific location (for example, on the SIM card or modem memory), but other areas may also be available depending on the type of device.'));
		o.value('SM', _('SIM card'));
		o.value('ME', _('Modem memory'));
		o.default = 'SM';

		o = s.taboption('smstab', form.Flag, 'mergesms', _('Merge split messages'),
		_('Checking this option will make it easier to read the messages, but it will cause a discrepancy in the number of messages shown and received.')
		);
		o.rmempty = false;

		o = s.taboption('smstab' , form.ListValue, 'algorithm', _('Merge algorithm'),
			_(''));
		o.value('Simple', _('Simple (merge without sorting)'));
		o.value('Advanced', _('Advanced (merges with sorting)'));
		o.default = 'Advanced';
		o.depends('mergesms', '1');

		o = s.taboption('smstab' , form.ListValue, 'direction', _('Direction of message merging'),
			_(''));
		o.value('Start', _('From beginning to end'));
		o.value('End', _('From end to beginning'));
		o.default = 'Start';
		o.depends('algorithm', 'Advanced');

		o = s.taboption('smstab', form.Value, 'bnumber', _('Phone number to be blurred'),
		_('The last 5 digits of this number will be blurred.')
		);
		o.password = true;

		o = s.taboption('smstab', form.Button, '_fsave');
		o.title      = _('Save messages to a text file');
		o.description      = _('This option allows to backup SMS messages or, for example, save messages that are not supported by the sms-tool.');
		o.inputtitle = _('Save as .txt file');
		o.onclick = function() {
			return uci.load('sms_tool_js').then(function() {
					var portES = (uci.get('sms_tool_js', '@sms_tool_js[0]', 'readport'));
						L.resolveDefault(fs.exec_direct('/usr/bin/sms_tool', [ '-d' , portES , '-f' , '%Y-%m-%d %H:%M' , 'recv' , '2>/dev/null']))
							.then(function(res) {
								if (res) {
									fs.write('/tmp/mysms.txt', res.trim().replace(/\r\n/g, '\n') + '\n');
  									var fileName = 'mysms.txt';
  									var filePath = '/tmp/' + fileName;

  									fs.stat(filePath)
    									.then(function () {

									if (confirm(_('Save sms to txt file?')))
									{
										L.resolveDefault(fs.read_direct('/tmp/mysms.txt'), null).then(function (restxt) {
											if (restxt) {
												L.ui.showModal(_('Saving...'), [
													E('p', { 'class': 'spinning' }, _('Please wait.. Process of saving SMS message to a text file is in progress.'))
												]);
											var link = E('a', {
												'download': 'mysms.txt',
												'href': URL.createObjectURL(
												new Blob([ restxt ], { type: 'text/plain' })),
											});
												window.setTimeout(function() {
													link.click();
													URL.revokeObjectURL(link.href);
													L.hideModal();
												}, 2000).finally();
											} else {
												ui.addNotification(null, E('p', {}, _('Saving SMS messages to a file failed. Please try again.')));
											}
											
										}).catch(() => {
											ui.addNotification(null, E('p', {}, _('Download error') + ': ' + err.message));
										});
									}
									});
								}
				});

    			});
			
		};

		o = s.taboption('smstab', form.Button, '_fdelete');
		o.title      = _('Delete all messages');
		o.description      = _("This option allows you to delete all SMS messages when they are not visible in the 'Received Messages' tab.");
		o.inputtitle = _('Delete all');
		o.onclick = function() {
			if (confirm(_('Delete all the messages?')))
			{
				return uci.load('sms_tool_js').then(function() {
					var portFD = (uci.get('sms_tool_js', '@sms_tool_js[0]', 'readport'));
					fs.exec_direct('/usr/bin/sms_tool', [ '-d' , portFD , 'delete' , 'all' ]);
    				});
			}
		};

		o = s.taboption('smstab', form.Value, 'sendport', _('SMS sending port'), 
			_("Select one of the available ttyUSBX ports."));
		devs.sort((a, b) => a.name > b.name);
		devs.forEach(dev => o.value('/dev/' + dev.name));
		
		o.placeholder = _('Please select a port');
		o.rmempty = false;

		o = s.taboption('smstab', form.Value, 'pnumber', _('Prefix number'),
			_("The phone number should be preceded by the country prefix (for Poland it is 48, without '+'). If the number is 5, 4 or 3 characters, it is treated as 'short' and should not be preceded by a country prefix."));
		o.default = '48';
		o.validate = function(section_id, value) {

			if (value.match(/^[0-9]+(?:\.[0-9]+)?$/))
				return true;

			return _('Expect a decimal value');
		};

		o = s.taboption('smstab', form.Flag, 'prefix', _('Add prefix to phone number'),
		_('Automatically add prefix to the phone number field.')
		);
		o.rmempty = false;
		//o.default = true;
		
		o = s.taboption('smstab', form.Flag, 'sendingroup', _('Enable group messaging'),
		_("This option allows you to send one message to all contacts in the user's contact list."));
		o.rmempty = false;
		o.default = false;

		o = s.taboption('smstab', form.Value, 'delay', _('Message sending delay'), 
			_("[3 - 59] second(s) \
			<br /><br /><b>Important</b> \
				<br />Messages are sent without verification and confirmation delivery of the message. \
				Therefore, there is a risk of non-delivery of the message."));
		o.default = "3";
		o.rmempty = false;
		o.validate = function(section_id, value) {

			if (value.match(/^[0-9]+(?:\.[0-9]+)?$/) && +value >= 3 && +value < 60)
				return true;

			return _('Expect a decimal value between three and fifty-nine');
		};
		o.depends("sendingroup", "1");
		o.datatype = 'range(3, 59)';

		o = s.taboption('smstab', form.Flag, 'information', _('Explanation of number and prefix'),
		_('In the tab for sending SMSes, show an explanation of the prefix and the correct phone number.')
		);
		o.rmempty = false;
		//o.default = true;

		o = s.taboption('smstab', form.TextValue, '_tmp2', _('User contacts'),
			_("Each line must have the following format: 'Contact name;phone number'. For user convenience, the file is saved to the location <code>/etc/modem/phonebook.user</code>."));
		o.rows = 7;
		o.cfgvalue = function(section_id) {
			return fs.trimmed('/etc/modem/phonebook.user');
		};
		o.write = function(section_id, formvalue) {
			return fs.write('/etc/modem/phonebook.user', formvalue.trim().replace(/\r\n/g, '\n') + '\n');
		};

		//TAB USSD

		s.tab('ussd', _('USSD Codes Settings'));
		s.anonymous = true;

		o = s.taboption('ussd', form.Value, 'ussdport', _('USSD sending port'), 
			_('Select one of the available ttyUSBX ports.'));
		devs.sort((a, b) => a.name > b.name);
		devs.forEach(dev => o.value('/dev/' + dev.name));
		
		o.placeholder = _('Please select a port');
		o.rmempty = false;

		o = s.taboption('ussd', form.Flag, 'ussd', _('Sending USSD code in plain text'),
		_('Send the USSD code in plain text. Command is not being coded to the PDU.')
		);
		o.rmempty = false;

		o = s.taboption('ussd', form.Flag, 'pdu', _('Receive message without PDU decoding'),
		_('Receive and display the message without decoding it as a PDU.')
		);
		o.rmempty = false;

		o = s.taboption('ussd', form.TextValue, '_tmp4', _('User USSD codes'),
			_("Each line must have the following format: 'Code description;code'. For user convenience, the file is saved to the location <code>/etc/modem/ussdcodes.user</code>."));
		o.rows = 7;
		o.cfgvalue = function(section_id) {
			return fs.trimmed('/etc/modem/ussdcodes.user');
		};
		o.write = function(section_id, formvalue) {
			return fs.write('/etc/modem/ussdcodes.user', formvalue.trim().replace(/\r\n/g, '\n') + '\n');
		};

		//TAB AT

		s.tab('attab', _('AT Commands Settings'));
		s.anonymous = true;

		o = s.taboption('attab' , form.Value, 'atport', _('AT commands sending port'), 
			_('Select one of the available ttyUSBX ports.'));
		devs.sort((a, b) => a.name > b.name);
		devs.forEach(dev => o.value('/dev/' + dev.name));
		
		o.placeholder = _('Please select a port');
		o.rmempty = false;

		o = s.taboption('attab' , form.TextValue, '_tmp6', _('User AT commands'),
			_("Each line must have the following format: 'At command description;AT command'. For user convenience, the file is saved to the location <code>/etc/modem/atcmmds.user</code>."));
		o.rows = 20;
		o.cfgvalue = function(section_id) {
			return fs.trimmed('/etc/modem/atcmmds.user');
		};
		o.write = function(section_id, formvalue) {
			return fs.write('/etc/modem/atcmmds.user', formvalue.trim().replace(/\r\n/g, '\n') + '\n');
		};

		//TAB INFO

		s.tab('notifytab', _('Notification Settings'));
		s.anonymous = true;

		o = s.taboption('notifytab', form.Flag, 'lednotify', _('Notify new messages'),
		_('The LED informs about a new message. Before activating this function, please config and save the SMS reading port, time to check SMS inbox and select the notification LED.')
		);
		o.rmempty = false;
		o.default = true;
		o.write = function(section_id, value) {

			uci.load('sms_tool_js').then(function() {
				var storeL = (uci.get('sms_tool_js', '@sms_tool_js[0]', 'storage'));
				var portR = (uci.get('sms_tool_js', '@sms_tool_js[0]', 'readport'));
				var dsled = (uci.get('sms_tool_js', '@sms_tool_js[0]', 'ledtype'));

					L.resolveDefault(fs.exec_direct('/usr/bin/sms_tool', [ '-s' , storeL , '-d' , portR , 'status' ]))
						.then(function(res) {
							if (res) {
								var total = res.substring(res.indexOf('total'));
								var t = total.replace ( /[^\d.]/g, '' );
								var used = res.substring(17, res.indexOf('total'));
								var u = used.replace ( /[^\d.]/g, '' );

								var sections = uci.sections('sms_tool_js');
								var led = sections[0].smsled;

								if (value == '1')
								{
									uci.set('sms_tool_js', '@sms_tool_js[0]', 'sms_count', L.toArray(u).join(' '));
									uci.set('sms_tool_js', '@sms_tool_js[0]', 'lednotify', "1");
									uci.save();
									fs.exec_direct('/sbin/new_cron_sync.sh');
									fs.exec_direct('/etc/init.d/my_new_sms', [ 'enable' ]);
									fs.exec('sleep 2');
									fs.exec_direct('/etc/init.d/my_new_sms', [ 'start' ]);
								}

								if (value == '0')
								{
									uci.set('sms_tool_js', '@sms_tool_js[0]', 'lednotify', "0");
									uci.save();
									fs.exec_direct('/sbin/new_cron_sync.sh');
									fs.exec_direct('/etc/init.d/my_new_sms', [ 'stop' ]);
									fs.exec('sleep 2');
									fs.exec_direct('/etc/init.d/my_new_sms', [ 'disable' ]);
									fs.exec_direct('/etc/init.d/my_new_sms', [ 'disable' ]);

									if (dsled == 'D')
									{
									fs.write('/sys/class/leds/'+led+'/brightness', '0');
									}
								}
							}
					});
			});

		return form.Flag.prototype.write.apply(this, [section_id, value]);
		};

		o = s.taboption('notifytab', form.Value, 'checktime', _('Check inbox every minute(s)'),
			_('Specify how many minutes you want your inbox to be checked.'));
		o.default = '10';
		o.rmempty = false;
		o.validate = function(section_id, value) {

			if (value.match(/^[0-9]+(?:\.[0-9]+)?$/) && +value >= 5 && +value < 60)
				return true;

			return _('Expect a decimal value between five and fifty-nine');
		};
		o.datatype = 'range(5, 59)';

		o = s.taboption('notifytab' , form.ListValue, 'prestart', _('Restart the inbox checking process every'),
			_('The process will restart at the selected time interval. This will eliminate the delay in checking your inbox.'));
		o.value('4', _('4h'));
		o.value('6', _('6h'));
		o.value('8', _('8h'));
		o.value('12', _('12h'));
		o.default = '6';
		o.rmempty = false;

		o = s.taboption('notifytab' , form.ListValue, 'ledtype',
			_('The diode is dedicated only to these notifications'),
			_("Select 'No' in case the router has only one LED or if the LED is multi-tasking. \
				<br /><br /><b>Important</b> \
				<br />This option requires LED to be defined in the system (if possible) to work properly. \
				This requirement applies when the diode supports multiple tasks."));
		o.value('S', _('No'));
		o.value('D', _('Yes'));
		o.default = 'D';
		o.rmempty = false;

		o = s.taboption('notifytab', form.ListValue, 'smsled',_('<abbr title="Light Emitting Diode">LED</abbr> Name'),
			_('Select the notification LED.'));
		o.load = function(section_id) {
			return L.resolveDefault(fs.list('/sys/class/leds'), []).then(L.bind(function(leds) {
				if(leds.length > 0) {
				leds.sort((a, b) => a.name > b.name);
				leds.forEach(e => o.value(e.name));
				}
				return this.super('load', [section_id]);
			}, this));
		};
		o.exclude = s.section;
		o.nocreate = true;
		o.optional = true;
		o.rmempty = true;

		return m.render();
	}
});
