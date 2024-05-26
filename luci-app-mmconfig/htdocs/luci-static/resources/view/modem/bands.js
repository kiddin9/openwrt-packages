'use strict';
'require form';
'require fs';
'require ui';
'require uci';
'require view';
'require poll';
'require dom';
'require modemmanager_helper as helper';

/*
	Written by Konstantine Shevlakov <shevlakov@132lan.ru> 2024
*/

return view.extend({
	load: function() {
		return helper.getModems().then(function (modems) {
			return Promise.all(modems.filter(function (modem){
				return modem != null;
			}).map(function (modem) {
				return helper.getModemSims(modem.modem).then(function (sims) {
					modem.sims = sims.filter(function (sim) {
						return sim != null;
					});

					return helper.getModemLocation(modem.modem).then(function (location) {
						modem.location = location;
						return modem;
					});
				});
			}));
		});
	},

	render: function(modems) {
		var m, s, o;
		
		m = new form.Map('mmconfig', _('MMConfig'), _('Manipulate modem bands via mmcli utility'));
		s = m.section(form.TypedSection, 'modem', null);
		s.anonymous = true;
		i=0;
		modems.reverse().forEach(L.bind(function (modem) {
			var generic = modem.modem.generic;
			var modem3gpp = modem.modem['3gpp'];
			o = s.option(form.Value, 'device'+i, generic.manufacturer + ' ' + generic.model);
			o.value(generic.device, generic.device);
			o.default = generic.device;
			o.readonly = true;
			o.rmempty = true;
			o = s.option(form.ListValue, 'network'+i, _('Network Mode'), _('Current')+ ': '+ generic['current-modes']);
			var modes= generic['supported-modes'];
			for (var m = 0; m < modes.length; m++){
				o.value(modes[m],modes[m]);
			};
			o.rmempty = true;
			var bands= generic['supported-bands'];
			if ( bands.length > 0){
				o = s.option(form.MultiValue, 'bands'+i, _('Network Bands'), _('List supported bands.<br />If deselect all bands, then used default band modem config.'));
					for (var b = 0; b < bands.length; b++){
						o.value(bands[b],bands[b]);
				};
			}
			o.rmempty = true;
			i++;
		}, this));
		s.anonymous = true;
		return m.render();
	}
});
