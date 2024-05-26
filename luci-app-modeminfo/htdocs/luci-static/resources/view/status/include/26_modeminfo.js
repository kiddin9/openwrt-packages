'use strict';                                                                                              
'require baseclass';
'require form';
'require fs';
'require ui';
'require uci';

/*
	Written by Konstantine Shevlakov at <shevlakov@132lan.ru> 2023

	Licensed to the GNU General Public License v3.0.

	Special Thanks to Vladislav Kadulin aka @Kodo-kakaku
	https://github.com/Kodo-kakaku/ to fix update overview page

*/

return baseclass.extend({
	title: _('Cellular network'),
	
	load: async function() {
		uci.load('modeminfo');
		return L.resolveDefault(fs.exec_direct('/usr/bin/modeminfo'));
	},
	
	render: function(data){
		var json = JSON.parse(data);
		var index = uci.sections('modeminfo', 'general');
		let modemTBL = E('div', { 'class': 'cbi-section' });
		
		if (json.modem && index[0].index == "1"){
			for (var i = 0; i < json.modem.length; i++) {
				var icon;
				var p = (json.modem[i].csq_per);
				var signal = document.createElement('div');
				
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
			
				var per = p+'%';
				
				var ca;
				if (json.modem[i].lteca > 0) {
					ca = "+";
				} else {
					ca = "";
				}
			
				signal.innerHTML = String.format(
					'<span class="ifacebadge">' + json.modem[i].cops  + " " +  
					'<img src="%s"/><b>'+per.fontcolor(json.modem[i].csq_col) + "</b> " + 
					json.modem[i].mode+ca + '</span>', icon, p );
			
				modemTBL.append( 
					E('table', { 'class': 'table' }, [
						E('tr', { 'class': 'tr' }, [
							E('td', { 'class': 'td left', 'width': '33%' }, [ json.modem[i].device ]),
							E('td', { 'class': 'td left', 'id': 'device' }, [ signal ])
						])
					])
				);
			};
			return modemTBL;
		};
	},
});
