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
		L.resolveDefault(fs.exec_direct('/usr/share/modeminfo/scripts/rmtmp'));
		return L.resolveDefault(fs.exec_direct('/usr/bin/modeminfo'));
	},

	polldata: poll.add(function() {
		return L.resolveDefault(fs.exec_direct('/usr/bin/modeminfo')).then(function(res) {
			var json = JSON.parse(res);
			for (var i = 0; i < json.modem.length; i++) {
				// progressbar cellular metric
				function rssi_bar(v, m) {
					var pg = document.querySelector('#rssi'+i)
					var vn = parseInt(v) || 0;
					var mn = parseInt(m) || 100;
					if (vn > -50) { vn = -50 };
					if (vn < -110) { vn = -110 };
					var pc =  Math.floor(100*(1-(-50 - vn)/(-50 - mn)));
					pg.firstElementChild.style.width = pc + '%';
					pg.style.width = '%d%%';
					pg.firstElementChild.style.animationDirection = "reverse";
					pg.setAttribute('title', '%s'.format(v));
				}
				function rsrp_bar(v, m) {
					var pg = document.querySelector('#rsrp'+i)
					var vn = parseInt(v) || 0;
					var mn = parseInt(m) || 100;
					if (vn > -50) { vn = -50 };
					if (vn < -140) { vn = -140 };
					var pc =  Math.floor(120*(1-(-50 - vn)/(-70 - mn)));
					pg.firstElementChild.style.width = pc + '%';
					pg.style.width = '%d%%';
					pg.firstElementChild.style.animationDirection = "reverse";
					pg.setAttribute('title', '%s'.format(v));
				}
				function sinr_bar(v, m) {
					var pg = document.querySelector('#sinr'+i)
					var vn = parseInt(v) || 0;
					var mn = parseInt(m) || 100;
					var pc = Math.floor(100-(100*(1-((mn - vn)/(mn - 40)))));
					pg.firstElementChild.style.width = pc + '%';
					pg.style.width = '%d%%';
					pg.firstElementChild.style.animationDirection = "reverse";
					pg.setAttribute('title', '%s'.format(v));
				}
				function rsrq_bar(v, m) {
					var pg = document.querySelector('#rsrq'+i)
					var vn = parseInt(v) || 0;
					var mn = parseInt(m) || 100;
					var pc = Math.floor(115-(100/mn)*vn);
					pg.firstElementChild.style.width = pc + '%';
					pg.style.width = '%d%%';
					pg.firstElementChild.style.animationDirection = "reverse";
					pg.setAttribute('title', '%s'.format(v));
				}
				// icon signal streigh
				var icon;
				var p = (json.modem[i].csq_per);
				if (p < 0)
					icon = L.resource('icons/signal-none.png');
				else if (p == 0)
					icon = L.resource('icons/signal-none.png');
				else if (p < 10)
					icon = L.resource('icons/signal-0.png');
				else if (p < 25)
					icon = L.resource('icons/signal-0-25.png');
				else if (p < 50)
					icon = L.resource('icons/signal-25-50.png');
				else if (p < 75)
					icon = L.resource('icons/signal-50-75.png');
				else
					icon = L.resource('icons/signal-75-100.png');
				// get reg state
				var reg;
				var rg = (json.modem[i].reg)
				if (rg == 0)
					reg = _('No Registration');
				else if (rg == 2 || rg == 8)
					reg = _('Searching');
				else if (rg == 3)
					reg = _('Denied');
				else if (rg == 4)
					reg = _('Unknown');
				else if (rg == 5 || rg == 7 || rg == 10)
					reg = _('Roaming');
				else
					reg = _('No Data');
				// frequency band calculator
				var frul;
				var frdl;
				var offset;
				var band;
				var netmode = (json.modem[i].mode)
				var rfcn = (json.modem[i].arfcn)
				if (netmode == "LTE") {
					if (rfcn >= 0 && rfcn <= 599) {
						var frdl = 2110;
						var frul = 1920;
						var offset = 0;
						var band = "1";
					} else if (rfcn >= 600 && rfcn <= 1199) {
						var frdl = 1930;
						var frul = 1850;
						var offset = 600;
						var band = "2";
					} else if (rfcn >= 1200 && rfcn <= 1949) {
						var frdl = 1805;
						var frul = 1710;
						var offset = 1200;
						var band = "3";
					} else if (rfcn >= 1950 && rfcn <= 2399) {
						var frdl = 2110;
						var frul = 1710;
						var offset = 1950;
						var band = "4";
					} else if (rfcn >= 2400 && rfcn <= 2469) {
						var rfdl = 869;
						var frul = 824;
						var offset = 2400;
						var band = "5";
					} else if (rfcn >= 2750 && rfcn <= 3449) {
						var frdl = 2620;
						var frul = 2500;
						var offset = 2750;
						var band = "7";
					} else if (rfcn >= 3450 && rfcn <= 3799) {
						var frdl = 925;
						var frul = 880;
						var offset = 3450;
						var band = "8";
					} else if (rfcn >= 6150 && rfcn <= 6449) {
						var frdl = 791;
						var frul = 832;
						var offset = 6150;
						var band = "20";
					} else if (rfcn >= 9210 && rfcn <= 9659) {
						var frdl = 758;
						var frul = 703;
						var offset = 9210;
						var band = "28";
					} else if (rfcn >= 9870 && rfcn <= 9919) {
						var frdl = 452.5;
						var frul = 462.5;
						var offset = 9870;
						var band = "31";
					} else if (rfcn >= 37750 && rfcn <= 38249) {
						var frdl = 2570;
						var frul = 2570;
						var offset = 37750;
						var band = "38";
					} else if (rfcn >= 38650 && rfcn <= 39649) {
						var frdl = 2300;
						var frul = 2300;
						var offset = 38650;
						var band = "40";
					} else {
						var offset = 0;
						var frdl = 0;
						var frul = 0;
						var rfcn = 0;
						var band = (rfcn);
					}
					var bwdld = (json.modem[i].bwdl);
					if (bwdld == 0) {
						var bw = 1.4;
					} else if (bwdld == 1) {
						var bw = 3;
					} else if (bwdld == 2) {
						var bw = 5;
					} else if (bwdld == 3) {
						var bw = 10;
					} else if (bwdld == 4) {
						var bw = 15;
					} else if (bwdld == 5) {
						var bw = 20;
					} else {
						var bw = "";
					}
						var dlfreq = (frdl + (rfcn - offset)/10);
						var ulfreq = (frul + (rfcn - offset)/10);
					} else {
						if (rfcn >= 10562 && rfcn <= 10838) {
							var offset = 950;
							var dlfreq = (rfcn/5);
							var ulfreq = ((rfcn - offset)/5);
							var band = "IMT2100";
						} else if (rfcn >= 2937 && rfcn <= 3088) {
							var frul = 925;
							var offset = 340;
							var ulfreq = (offset + (rfcn/5));
							var dlfreq = (ulfreq - 45);
							var band = "UMTS900";
						} else if (rfcn >= 955 && rfcn <= 1023) {
							var frul = 890;
							var ulfreq = (frul + ((rfcn - 1024)/5));
							var dlfreq = (ulfreq + 45);
							var band = "DSC900";
						} else if (rfcn >= 512 && rfcn <= 885) {
							var frul = 1710;
							var ulfreq = (frul + (rfcn - 512)/5);
							var dlfreq = (ulfreq + 95);
							var band = "DCS1800";
						} else if (rfcn >= 1 && rfcn <= 124) {
							var frul = 890;
							var ulfreq = (frul + (rfcn/5));
							var dlfreq = (ulfreq + 45);
							var band = "GSM900";
						} else {
							var ulfreq = 0;
							var dlfreq = 0;
							var band = (rfcn);
						}
					}
					var carrier = "";
					var bcc;
					var freq;
					var distance;
					var lactac;
					var calte;
					var namebnd;
					var dist = (json.modem[i].distance)
					if (json.modem[i].enbid && json.modem[i].cell && json.modem[i].pci) {
						var namecid = "LAC/CID/eNB ID-Cell/PCI";
						var lactac = json.modem[i].lac + " / " + json.modem[i].cid + " / " + json.modem[i].enbid + "-" + json.modem[i].cell +" / " +json.modem[i].pci;
					} else if (json.modem[i].enbid && json.modem[i].cell) { 
						var namecid = "LAC/CID/eNB ID-Cell";
						var lactac = json.modem[i].lac + " / " + json.modem[i].cid + " / " + json.modem[i].enbid + "-" + json.modem[i].cell;
					} else if (json.modem[i].enbid) {
						var namecid = "LAC/CID/eNB ID";
						var lactac = json.modem[i].lac + " / " + json.modem[i].cid + " / " + json.modem[i].enbid;
					} else {
						var namecid = "LAC/CID";
						var lactac = json.modem[i].lac + " / " + json.modem[i].cid;
					}
					var carrier;
					var bcc;
					var bca = "";
					var scc;
					var cid;
					var arfcn = json.modem[i].arfcn + " (" + dlfreq + " / " + ulfreq + " MHz)";
					// name channels and signal/noise  
					if (netmode == "LTE") {
						var calte = (json.modem[i].lteca)
						var carrier;
						var scc;
						var bwca = json.modem[i].bwca;
						distance = " ~"+ dist +" km";
						if (calte > 0) {
							carrier = "+";
							scc = json.modem[i].scc;
							bw = bwca;
							bca = " / " + bw + " MHz";
							bcc = " B" + band + "" + scc;
						} else {
							scc = "";
							bcc = " B" + band;
							if (bw) {
								bca = " / " + bw + " MHz";
							} else{
								bca = ""
							}
						}
						var namech = "EARFCN";
						var namesnr = "SINR";
					} else if (netmode == 
						"3G" || netmode == 
						"UMTS" || netmode == 
						"HSPA" || netmode == 
						"HSUPA" || netmode == 
						"HSDPA" || netmode == 
						"HSPA+" || netmode == 
						"WCDMA" || netmode == 
						"DC-HSPA+" || netmode == 
						"HSDPA+HSUPA" || netmode ==
						"HSDPA,HSUPA") {
						var namech = "UARFCN";
						var namesnr = "ECIO";
						var namecid = "LAC/CID";
						var lactac = json.modem[i].lac + " / " + json.modem[i].cid;
						var bcc = " " + band;
					} else {
						var namech = "ARFCN";
						var namesnr = "SINR/ECIO";
						var namecid = "LAC/CID";
						var lactac = json.modem[i].lac + " / " + json.modem[i].cid;
						var bcc = " " + band;
					}
					if (bw) { 
						namebnd = _('Network/Band/Bandwidth');
					} else {
						namebnd = _('Network/Band');
				}
				
				if (document.getElementById('status'+i)){
					var view = document.getElementById('status'+i);
					if (rg == 1 || rg == 6 || rg == 9) {
						if( dist== "--" || dist == "" || dist == "0.00"){
							view.innerHTML = String.format(json.modem[i].cops +'<img style="padding-left: 10px;" src="%s"/>'  + " " +  '<span class="ifacebadge"><p style="color:'+ json.modem[i].csq_col +'"><b>%d%%</b></p></span>', icon, p);
						} else {
							view.innerHTML = String.format(json.modem[i].cops +'<img style="padding-left: 10px;" src="%s"/>'  + " " +  '<span class="ifacebadge"><p style="color:'+ json.modem[i].csq_col +'"><b>%d%%</b></p></span>' + distance, icon, p);
						}
					} else if (rg == 5 || rg == 7 || rg == 10) {
						if( dist== "--" || dist == "" || dist == "0.00"){
							view.innerHTML = String.format(json.modem[i].cops + "(" + reg + ')<img style="padding-left: 10px;" src="%s"/>'  + " " +  '<span class="ifacebadge"><p style="color:'+ json.modem[i].csq_col +'"><b>%d%%</b></p></span>', icon, p);
						} else {
							viev.innerHTML = String.format(json.modem[i].cops + "(" + reg + ')<img style="padding-left: 10px;" src="%s"/>'  + " " +  '<span class="ifacebadge"><p style="color:'+ json.modem[i].csq_col +'"><b>%d%%</b></p></span>' + distance, icon, p);
						}
					} else {
						view.innerHTML = String.format(reg);
					}
				}

				if (document.getElementById('mode'+i)){
					var view = document.getElementById('mode'+i);
					if (json.modem[i].signal = 0 || json.modem[i].signal == '') {
						view.textContent = '--';
					} else {
						if (json.modem[i].mode == '') { 
							view.textContent = '--';
						} else {
							view.innerHTML = String.format(json.modem[i].mode + "" + carrier + " /"+ bcc +""+ bca);
						}
					}
				}

				if (document.getElementById('namebnd'+i)){
					var view = document.getElementById('namebnd'+i);
					view.innerHTML = String.format(namebnd);
				}

				if (document.getElementById('chname'+i)){
					var view = document.getElementById('chname'+i);
					view.innerHTML = String.format(namech);
				}

				if (document.getElementById('namecid'+i)){
					var view = document.getElementById('namecid'+i);
					view.innerHTML = String.format(namecid);
				}

				if (document.getElementById('arfcn'+i)){
					var view = document.getElementById('arfcn'+i);
					view.innerHTML = String.format(arfcn);
				}

				if (document.getElementById('lac'+i)){
					var view = document.getElementById('lac'+i);
					view.innerHTML = String.format(lactac);
				}

				if (document.getElementById('snrname'+i)) {
					var view = document.getElementById('snrname'+i);
					view.innerHTML = String.format(namesnr);
				}

				if (document.getElementById('rssi'+i)) {
					var view = document.getElementById('rssi'+i);
					if (json.modem[i].rssi == '') {
						view = document.getElementById('--');
					} else {
						var rssi_min = -110;
						rssi_bar(json.modem[i].rssi + ' dBm', rssi_min);
					}
				}
				if (document.getElementById('sinr'+i)) {
					var view = document.getElementById('sinr'+i);
					if (json.modem[i].sinr == "--" || netmode == "--") {
						view = document.getElementById('--');
					} else {
						if (netmode == "LTE") {
							var sinr_min = -20;
							sinr_bar(json.modem[i].sinr + " dB", sinr_min);
						} else {
							var sinr_min = -24;
							sinr_bar(json.modem[i].sinr + " dB", sinr_min);
						}
					}
				}
				
				if (document.getElementById('rsrp'+i)) {
					var view = document.getElementById('rsrp'+i);
					if (json.modem[i].rsrp == "--") {
						view = document.getElementById('--');
					} else {
						var rsrp_min = -140;
						rsrp_bar(json.modem[i].rsrp + " dBm", rsrp_min);
					}
				}

				if (document.getElementById('rsrq'+i)) {
					var view = document.getElementById('rsrq'+i);
					if (json.modem[i].rsrq == "--") {
						view = document.getElementById('--');
					} else {
						var rsrq_min = -20;
						rsrq_bar(json.modem[i].rsrq + " dB", rsrq_min);
					}
				}
			};

		});
	}),

	render: function(data){
		var m, s, o;

		m = new form.Map('modeminfo', _('Modeminfo: Network'), _('Cellular network'));
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
			let status = 'status'+i;
			let mode = 'mode'+i;
			let namebnd = 'namebnd'+i;
			let chname = 'chname'+i;
			let namecid = 'namecid'+i;
			let arfcn = 'arfcn'+i;
			let lac = 'lac'+i;
			let rssi = 'rssi'+i;
			let sinr = 'sinr'+i;
			let snrname = 'snrname'+i;
			let rsrp = 'rsrp'+i;
			let rsrq = 'rsrq'+i;
			//s.tab("modem" + i, vendors[i]);
			//o = json.modem.length > 1 ? s.taboption('modem'+i, form.HiddenValue, 'generic') : s.option(form.HiddenValue, 'generic');

			if ( json.modem.length > 1 ) {
				s.tab("modem" + i, _('Modem')+' '+i);
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
									E('td', { 'class': 'td left', 'width': '50%' }, [ _('Operator')]),
									E('td', { 'class': 'td left', 'id': status }, [ '--' ]),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-1' }, [
									E('td', { 'class': 'td left', 'width': '50%', 'id': namebnd }, [ _('Network/band')]),
									E('td', { 'class': 'td left', 'id': mode }, [ '--' ]),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-2' }, [
									E('td', { 'class': 'td left', 'width': '50%', 'id': chname }, [ _('E/U/ARFCN')]),
									E('td', { 'class': 'td left', 'id': arfcn }, [ '--' ]),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-1' }, [
									E('td', { 'class': 'td left', 'width': '50%', 'id': namecid }, [ _('LAC/CID')]),
									E('td', { 'class': 'td left', 'id': lac }, [ '--' ]),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-2' }, [
									E('td', { 'class': 'td left', 'width': '50%' }, [ _('RSSI')]),
									E('td', { 'class': 'td left'}, E('div', {'id': rssi, 'class': 'cbi-progressbar', 'title': '--' }, E('div'))),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-1' }, [
									E('td', { 'class': 'td left', 'width': '50%', 'id': snrname }, [ _('SINR/EcIO')]),
									E('td', { 'class': 'td left'}, E('div', {'id': sinr, 'class': 'cbi-progressbar', 'title': '--'}, E('div'))),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-2' }, [
									E('td', { 'class': 'td left', 'width': '50%' }, [ _('RSRP')]),
									E('td', { 'class': 'td left'}, E('div', {'id': rsrp, 'class': 'cbi-progressbar', 'title': '--'}, E('div'))),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-1' }, [
									E('td', { 'class': 'td left', 'width': '50%' }, [ _('RSRQ')]),
									E('td', { 'class': 'td left'}, E('div', {'id': rsrq, 'class': 'cbi-progressbar', 'title': '--'}, E('div'))),
								])
							])
						])
					])
				)
			}, this.polldata);
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
