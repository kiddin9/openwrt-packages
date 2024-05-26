'use strict';
'require form';
'require fs';
'require view';
'require ui';
'require uci';
'require poll';
'require dom';
'require tools.widgets as widgets';

/*
	Copyright 2022-2024 Rafał Wabik - IceG - From eko.one.pl forum
*/


var CBISelectswitch = form.DummyValue.extend({                                                                                         
    renderWidget: function(section_id, option_id, cfgvalue) {                                                                          
        var section = this.section;                                                                                                    
        return E([], [                                                                                                                 
            E('span', { 'class': 'control-group' }, [                                                                                  
                E('button', {                                                                                                          
                    'class': 'cbi-button cbi-button-apply',                                                                            
                    'click': ui.createHandlerFn(this, function() {                                                                     
                        var dropdown = section.getUIElement(section_id, 'set_5gsabands');                                              
                        dropdown.setValue([]);                                                                                         
                    }),                                                                                                                
                }, _('Deselect all')),                                                                                                 
                ' ',                                                                                                                   
                E('button', {                                                                                                          
                    'class': 'cbi-button cbi-button-action important',                                                                 
                    'click': ui.createHandlerFn(this, function() {                                                                     
                        var dropdown = section.getUIElement(section_id, 'set_5gsabands');                                              
                        dropdown.setValue(Object.keys(dropdown.choices));                                                              
                    })                                                                                                                 
                }, _('Select all'))                                                                                                    
            ])                                                                                                                         
        ]);                                                                                                                            
    },                                                                                                                                 
});


var BANDmagic = form.DummyValue.extend({

	load: function() {
		var setupButton = E('button', {
				'class': 'cbi-button cbi-button-neutral',
				'click': ui.createHandlerFn(this, function() {
							return handleAction('reload');
						}),
			}, _('Refresh'));

		var restoreButton = E('button', {
				'class': 'btn cbi-button cbi-button-reset',
				'click': ui.createHandlerFn(this, function() {
							return handleAction('resetbandz');
						}),
			}, _('Restore'));

		return L.resolveDefault(fs.exec_direct('/usr/bin/modemband.sh'), 'null').then(L.bind(function(html) {
				if (html == null) {
					this.default = E('em', {}, [ _('The modemband error.') ]);
				}
				else {
					this.default = E([
					E('div', { 'class': 'cbi-value' }, [
						E('label', { 'class': 'cbi-value-title' },
							_('Bands configuration')
						),
						E('div', { 'class': 'cbi-value-field', 'style': 'width:25vw' },
								E('div', { 'class': 'cbi-section-node' }, [
									setupButton,
								]),
						),
					]),
					E('div', { 'class': 'cbi-value' }, [
						E('label', { 'class': 'cbi-value-title' },
							_('Restore default bands')
						),
						E('div', { 'class': 'cbi-value-field', 'style': 'width:25vw' },
								E('div', { 'class': 'cbi-section-node' }, [
									restoreButton,
								]),
						),
					]),
				]);
					}
			}, this));
	}
});

var SYSTmagic = form.DummyValue.extend({

	load: function() {
		var restartButton = E('button', {
				'class': 'btn cbi-button cbi-button-neutral',
				'click': ui.createHandlerFn(this, function() {
							return handleAction('restartwan');
						}),
			}, _('Restart'));

		var rebootButton = E('button', {
				'class': 'btn cbi-button cbi-button-neutral',
				'click': ui.createHandlerFn(this, function() {
							return handleAction('rebootdev');
						}),
			}, _('Perform reboot'));

		return L.resolveDefault(fs.exec_direct('/usr/bin/modemband.sh'), 'null').then(L.bind(function(html) {
				if (html == null) {
					this.default = E('em', {}, [ _('The modemband error.') ]);
				}
				else {
					this.default = E([
					E('div', { 'class': 'cbi-value' }, [
						E('label', { 'class': 'cbi-value-title' },
							_('Restart WAN')
						),
						E('div', { 'class': 'cbi-value-field', 'style': 'width:25vw' },
								E('div', { 'class': 'cbi-section-node' }, [
									restartButton,
								]),
						),
					]),
					E('div', { 'class': 'cbi-value' }, [
						E('label', { 'class': 'cbi-value-title' },
							_('Reboot')
						),
						E('div', { 'class': 'cbi-value-field', 'style': 'width:25vw' },
								E('div', { 'class': 'cbi-section-node' }, [
									rebootButton,
								]),
						),
					]),

				]);
					}
			}, this));
	}
});


var cbiRichListValue = form.ListValue.extend({
	renderWidget: function(section_id, option_index, cfgvalue) {
		var choices = this.transformChoices();
		var widget = new ui.Dropdown((cfgvalue != null) ? cfgvalue : this.default, choices, {
			id: this.cbid(section_id),
			sort: this.keylist,
			optional: true,
			multiple: true,
			display_items: 5,
			dropdown_items: 10,
			select_placeholder: this.select_placeholder || this.placeholder,
			custom_placeholder: this.custom_placeholder || this.placeholder,
			validate: L.bind(this.validate, this, section_id),
			disabled: (this.readonly != null) ? this.readonly : this.map.readonly
		});
		return widget.render();
	},

	value: function(value, title, description) {
		if (description) {
			form.ListValue.prototype.value.call(this, value, E([], [
				E('span', { 'class': 'hide-open' }, [ title ]),
				E('div', { 'class': 'hide-close', 'style': 'min-width:25vw' }, [
					E('strong', [ title ]),
					E('br'),
					E('span', { 'style': 'white-space:normal' }, description)
				])
			]));
		}
		else {
			form.ListValue.prototype.value.call(this, value, title);
		}
	}
});

function handleAction(ev) {
	if (ev === 'reload') {
		location.reload();
	}
	if (ev === 'resetbandz') {		
		if (confirm(_('Do you really want to set up all possible bands for the modem?')))
			{
			fs.exec_direct('/usr/bin/modemband.sh', [ 'setbands5gsa', 'default' ]);

			return uci.load('modemband').then(function() {
				var nuser = (uci.get('modemband', '@modemband[0]', 'notify'));
				
				if ( nuser != '1' || nuser == null ) {
				ui.addNotification(null, E('p', _('The new bands settings have been sent to the modem. If the changes are not visible, a restart of the connection, modem or router may be required.')), 'info');
				}
    			});
			}
	}
	if (ev === 'rebootdev') {
		if (confirm(_('Do you really want to restart the device?')))
		{
			L.ui.showModal(_('Rebooting…'), [
				E('p', { 'class': 'spinning' }, _('Waiting for device...'))
			]);
			fs.exec('/sbin/reboot');
		}
	}
	if (ev === 'restartwan') {
		return uci.load('modemband').then(function() {
		var wname = (uci.get('modemband', '@modemband[0]', 'iface'));
		
			if (wname.includes('@')) {
				wname = wname.replace(/@/g, '')
			};

			fs.exec('/sbin/ifdown', [ wname ]);
			fs.exec('sleep 3');
			fs.exec('/sbin/ifup', [ wname ]);
    		});
	}
}

return view.extend({
	formdata: { modemband: {} },

	load: function() {
		return L.resolveDefault(fs.exec_direct('/usr/bin/modemband.sh', [ 'json' ]));
	},

	render: function(data) {
		var m, s, o;

		if (data != null){
		try {

		var json = JSON.parse(data);
		var modemen, sbands;

		if(!json.hasOwnProperty('error')){

		if (json.supported5gsa === undefined && json.enabled5gsa === undefined) {

			ui.addNotification(null, E('p', _('5G bands cannot be read. Check if your modem supports this technology and if it is in the list of supported modems.')), 'info');
			modemen = '-';
			sbands = '-';
		}
		else {

		var modem = json.modem;
		for (var i = 0; i < json.enabled5gsa.length; i++) 
		{
				var txtband = json.enabled5gsa[i].toString();
				var numb = txtband.match(/\d+$/);
				modemen += 'n' + numb + '  ';
				modemen = modemen.replace('undefined', '');
		}
		modemen = modemen.includes('n0') == true ? modemen = _('Bands are disabled...') : modemen = modemen.trim();

		for (var i = 0; i < json.supported5gsa.length; i++) 
		{
				var txtband = json.supported5gsa[i].band.toString();
				var numb = txtband.match(/\d+$/);
				sbands += 'n' + numb + '  ';
				sbands = sbands.replace('undefined', '');
		}
		sbands = sbands.trim();
		
		pollData: poll.add(function() {
			return L.resolveDefault(fs.exec_direct('/usr/bin/modemband.sh', [ 'json' ]))
			.then(function(res) {
				var json = JSON.parse(res);
				//modemen = _('Waiting for device...');
				if ( json != null ) { 

				var renderHTML = "";
				var view = document.getElementById("modemlteb");
				for (var i = 0; i < json.enabled5gsa.length; i++) 
				{
				var txtband = json.enabled5gsa[i].toString();
				var numb = txtband.match(/\d+$/);
				renderHTML += 'n' + numb + '  ';
				view.innerHTML  = '';
  				view.innerHTML  = renderHTML.trim();
				}
				view.innerHTML = view.innerHTML.includes('n0') == true ? view.innerHTML = _('Bands are disabled...') : view.innerHTML  = renderHTML.trim();
				}
				else {
				var view = document.getElementById("modemlteb");
				view.innerHTML = _('Waiting for device...');
				}

			});
		});
		}
		}		
		else {
			if (json.error.includes('No supported') == true) {
			modemen = '-';
			sbands = '-';
			ui.addNotification(null, E('p', _('No supported modem was found, quitting...')), 'error');
			}
			if (json.error.includes('Port not found') == true) {
			modemen = '-';
			sbands = '-';
			ui.addNotification(null, E('p', _('Port not found, quitting...')), 'error');
			}

		}
			} catch (err) {
  				console.log('Error: ', err.message);
			}
		}		

		var info = _('Configuration modem frequency bands. More information about the modemband application on the %seko.one.pl forum%s.').format('<a href="https://eko.one.pl/?p=openwrt-modemband" target="_blank">', '</a>');

		m = new form.JSONMap(this.formdata, _('5G SA Bands Configuration'), info);

		s = m.section(form.TypedSection, 'modemband', '', _(''));
		s.anonymous = true;

		s.render = L.bind(function(view, section_id) {
			return E('div', { 'class': 'cbi-section' }, [
				E('h3', _('Modem information')),
					E('table', { 'class': 'table' }, [
						E('tr', { 'class': 'tr' }, [
						E('td', { 'class': 'td left', 'width': '33%' }, [ _('Modem')]),
						E('td', { 'class': 'td left', 'id': 'modem' }, [ modem || '-' ]),
					]),

						E('tr', { 'class': 'tr' }, [
						E('td', { 'class': 'td left', 'width': '33%' }, [ _('Currently set 5G SA bands')]),
						E('td', { 'class': 'td left', 'id': 'modemlteb' }, [ modemen || '-' ]),
					]),

						E('tr', { 'class': 'tr' }, [
						E('td', { 'class': 'td left', 'width': '33%' }, [ _('Supported 5G SA bands')]),
						E('td', { 'class': 'td left', 'id': 'sbands' }, [ sbands || '-' ]),
					]),
				])
			]);
		}, o, this);

		s = m.section(form.TypedSection, 'modemband', _(''));
		s.anonymous = true;
		s.addremove = false;

		if (json.supported5gsa === undefined && json.enabled5gsa === undefined) {
			modemen = '-';
			sbands = '-';
		}
		else {

		s.tab('bandset', _('Preferred bands settings'));
 
		o = s.taboption('bandset', cbiRichListValue, 'set_5gsabands',
		_('Modification of the bands'), 
		_("Select the preferred band(s) for the modem."));
		for (var i = 0; i < json.supported5gsa.length; i++) 
		{
			o.value(json.supported5gsa[i].band, _('n')+json.supported5gsa[i].band,json.supported5gsa[i].txt);
		}
		
		o.multiple = true;
		o.placeholder = _('Please select a band(s)');
		o.cfgvalue = function(section_id) {
			return L.toArray((json.enabled5gsa).join(' '));
		};

		o = s.taboption('bandset', CBISelectswitch, '_switch', _('Band selection switch'));

		s = m.section(form.TypedSection);
		s.anonymous = true;
		o = s.option(BANDmagic);

		s = m.section(form.TypedSection, 'modemband',
			_('Additional options'),
			_('Additional options useful for modem configuration.'));

		s.tab('opt1', _('Connection / router restart'));
		s.anonymous = true;

		o = s.taboption('opt1', form.DummyValue, '_dummy');
			o.rawhtml = true;
			o.default = '<div class="cbi-section-descr">' +
				_('Hint: The name of the WAN section can be changed in the package settings panel.') +
				'</div>';

		o = s.taboption('opt1', SYSTmagic);
		}
		
		return m.render();
	},

	handleBANDZSETup: function(ev) {
		var map = document.querySelector('#maincontent .cbi-map'),
		    data = this.formdata;

		return dom.callClassMethod(map, 'save').then(function() {
			var args = [];
			args.push(data.modemband.set_5gsabands);
			var ax = args.toString();
			ax = ax.replace(/,/g, ' ')
			
			ax.length >= 1 ? fs.exec_direct('/usr/bin/modemband.sh', [ 'setbands5gsa', ax ]) : ui.addNotification(null, E('p', _('Check if you have selected the bands correctly.')), 'info');

			return uci.load('modemband').then(function() {
				var wrestart = (uci.get('modemband', '@modemband[0]', 'wanrestart'));
				var mrestart = (uci.get('modemband', '@modemband[0]', 'modemrestart'));
				var cmdrestart = (uci.get('modemband', '@modemband[0]', 'restartcmd'));
				var wname = (uci.get('modemband', '@modemband[0]', 'iface'));
				
				if (wname.includes('@')) {
					wname = wname.replace(/@/g, '')
				};
				
				var sport = (uci.get('modemband', '@modemband[0]', 'set_port'));
				var nuser = (uci.get('modemband', '@modemband[0]', 'notify'));
				
				if ( ax.length >= 1 ) {
					if ( nuser != '1' || nuser == null ) {
					ui.addNotification(null, E('p', _('The new bands settings have been sent to the modem. If the changes are not visible, a restart of the connection, modem or router may be required.')), 'info');
					}
				}
				
				if (wrestart == '1') {
				fs.exec('/sbin/ifdown', [ wname ]);
				fs.exec('sleep 3');
				fs.exec('/sbin/ifup', [ wname ]);
				}

				if (mrestart == '1') {
				fs.exec('sleep 20');
				//sms_tool -d $_DEVICE at "cmd"
				fs.exec_direct('/usr/bin/sms_tool', [ '-d' , sport , 'at' , cmdrestart ]);
				}
    			});
		});
	},

	addFooter: function() {
		return E('div', { 'class': 'cbi-page-actions' }, [
			E('button', {
				'class': 'cbi-button cbi-button-save',
				'click': L.ui.createHandlerFn(this, 'handleBANDZSETup')
			}, [ _('Apply changes') ])
		]);
	}
});
