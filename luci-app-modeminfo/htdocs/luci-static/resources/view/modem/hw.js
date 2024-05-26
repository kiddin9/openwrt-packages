'use strict';
'require baseclass';
'require form';
'require fs';
'require view';
'require ui';
'require uci';
'require poll';
'require dom';
'require tools.widgets as widgets';


/*
	Copyright Konstantine Shevlakov <shevlakov@132lan.ru> 2023
	
	Licensed to the GNU General Public License v3.0.
	
*/


return view.extend({

	load: function(data) {
		return L.resolveDefault(fs.exec_direct('/usr/bin/modeminfo'));
	},

	polldata: poll.add(function() {
		return L.resolveDefault(fs.exec_direct('/usr/bin/modeminfo')).then(function(res) {
			var json = JSON.parse(res);
			for (var i = 0; i < json.modem.length; i++) {
				if (document.getElementById('device'+i)) {
					var view = document.getElementById('device'+i);
					if (json.modem[i].device == '--') {
						view = document.getElementById('--');
					} else {
						view.innerHTML = String.format(json.modem[i].device);
					}
				}
				if (document.getElementById('firmware'+i)) {
					var view = document.getElementById('firmware'+i);
					if (json.modem[i].firmware == '--') {
						view = document.getElementById('--');
					} else {
						view.innerHTML = String.format(json.modem[i].firmware);
					}
				}
				if (document.getElementById('imsi'+i)) {
					var view = document.getElementById('imsi'+i);
					if (json.modem[i].imsi == '--') {
						view = document.getElementById('--');
					} else {
						view.innerHTML = String.format(json.modem[i].imsi);
					}
				}
				if (document.getElementById('iccid'+i)) {
					var view = document.getElementById('iccid'+i);
					if (json.modem[i].iccid == '--') {
						view = document.getElementById('--');
					} else {
						view.innerHTML = String.format(json.modem[i].iccid);
					}
				}

				if (document.getElementById('imei'+i)) {
					var view = document.getElementById('imei'+i);
					if (json.modem[i].imei == '--') {
						view = document.getElementById('--');
					} else {
						view.innerHTML = String.format(json.modem[i].imei);
					}
				}

				if (document.getElementById('chiptemp'+i)) {
					var view = document.getElementById('chiptemp'+i);
					if (json.modem[i].chiptemp == '--') {
						view = document.getElementById('--');
					} else {
						view.innerHTML = String.format(json.modem[i].chiptemp+' °C');
					}
				}
			};

		});
	}),

	render: function(data){
		
		var m, s, o;
		m = new form.Map('modeminfo', _('Modeminfo: Hardware'), _('Hardware and sim-card info.'));
		s = m.section(form.TypedSection, 'general', null);
		var json = JSON.parse(data);
		// for future use
		/*
		var vendors = [];
		var duplicate_modem_index = 1;
		json.modem.forEach(obj => {
  			const device = obj.device;
  			if (!vendors.includes(device)) {
    			vendors.push(device);
  			} else {
    			vendors.push(device+" ("+duplicate_modem_index+")");
    			duplicate_modem_index++;
  			}
		});
		*/
		for (var i = 0; i < json.modem.length; i++) {
			let device = 'device'+i;
			let firmware = 'firmware'+i;
			let imsi = 'imsi'+i;
			let iccid = 'iccid'+i;
			let imei = 'imei'+i;
			let chiptemp = 'chiptemp'+i;
			if ( json.modem.length > 1 ) {
				s.tab('modem'+i, _('Modem')+' '+i);
				o = s.taboption('modem'+i, form.HiddenValue, 'generic');
			} else {
				o = s.option(form.HiddenValue, 'generic');
			}
			o.render = L.bind(function(data){
				return (
				E('div', {}, [
					E('h3', { 'class': 'data-tab' }), 
						E('div', { 'class': 'cbi-section', 'data-title': 'modem'+i }, [
							E('table', { 'class': 'table' }, [
								E('tr', { 'class': 'tr cbi-rowstyle-2' }, [
									E('td', { 'class': 'td left', 'width': '50%' }, [ _('Device')]),
									E('td', { 'class': 'td left', 'id': device }, [ '--' ]),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-1' }, [
									E('td', { 'class': 'td left', 'width': '50%' }, [ _('Firmware')]),
									E('td', { 'class': 'td left', 'id': firmware }, [ '--' ]),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-2' }, [
									E('td', { 'class': 'td left', 'width': '50%' }, [ _('IMSI')]),
									E('td', { 'class': 'td left', 'id': imsi }, [ '--' ]),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-1' }, [
									E('td', { 'class': 'td left', 'width': '50%' }, [ _('ICCID')]),
									E('td', { 'class': 'td left', 'id': iccid }, [ '--' ]),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-2' }, [
									E('td', { 'class': 'td left', 'width': '50%' }, [ _('IMEI')]),
									E('td', { 'class': 'td left', 'id': imei }, [ '--' ]),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-1' }, [
									E('td', { 'class': 'td left', 'width': '50%' }, [ _('Chiptemp')]),
									E('td', { 'class': 'td left', 'id': chiptemp }, [ '--' ]),
								])
							])
						]),
					]
				)
			)}, o, this.polldata);
			o.anonymous = true;
			o.rmempty = true;
		};
		s.anonymous = true;
		return m.render();

	},
	handleSaveApply: null,
	handleSave: null,
	handleReset: null
});
