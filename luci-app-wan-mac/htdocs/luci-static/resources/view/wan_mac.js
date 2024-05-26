'use strict';
'require view';
'require uci';
'require form';
'require dom';

var CBIMacAddress = form.Value.extend({
    renderWidget: function(section_id, option_index, cfgvalue) {
        var node = this.super('renderWidget', [section_id, option_index, cfgvalue]);
        dom.append(node, [
            E('br'),
            E('span', { 'class': 'control-group' },
                E('button', {
                    'class': 'btn cbi-button cbi-button-neutral',
                    'click': this.clickFn.bind(this, section_id, node)
                }, this.btnTitle)
            )
        ]);
        return node;
    }
});

var genMAC = function(section_id, node) {
    var getOptVal = L.bind(function(opt, default_val) {
        default_val = default_val || null;
        return this.section.formvalue(section_id, opt) || default_val;
    }, this);

    var prefix = getOptVal('prefix');
    if (prefix === null || prefix === "") {
        alert(_('Select or input Prefix first!'));
        return;
    }
    var macb = prefix.match(/[a-fA-F0-9]{2}/g).map(function(b){return parseInt(b,16);});
    if ((macb[0] & 1) === 1) {
        alert(_('Prefix is a Multicast address!'));
        return;
    }
    while (macb.length < 5) {
        macb.push(parseInt(Math.random()*255.9));
    }
    macb[5] = (parseInt(Math.random()*15.9) << 4) + parseInt(Math.random()*8);

    var mac = "";
    for (var i=0; i<6; ++i) {
        var b = macb[i].toString(16).toUpperCase();
        if (b.length === 1) {
            b = '0' + b;
        }
        mac = mac + ':' + b;
    }
    mac = mac.substring(1);
    /*
    var inputEl = node.querySelector('input[type="text"]');
    inputEl.value = mac;
    // this.triggerValidation(section_id);
    inputEl.dispatchEvent(new Event('input'));
    inputEl.dispatchEvent(new Event('blur'));
    */
    dom.callClassMethod(node, "setValue", mac);
    dom.callClassMethod(node, "triggerValidation");
};

return view.extend({
    load: function() {
        return Promise.all([
            uci.load('wan_mac')
        ]);
    },

    render: function() {

        var m, s, o;

        m = new form.Map('wan_mac', _('WAN MAC address'),
            _('Change the MAC address of WAN port. <br>Note that modifying the MAC address may cause the IP address to change.'));

        s = m.section(form.NamedSection, 'config', 'wan_mac', _('Global Settings'));
        s.anonymous = true;
        s.addremove = false;

        o = s.option(form.Flag, 'enabled', _('Enable'));
        o.rmempty   = false;

        s = m.section(form.NamedSection, 'config', 'wan_mac', _('MAC Address Settings'),
            _('Select a prefix and click the "Randomly Generate Using Prefix" button to generate a MAC address'));
        s.anonymous = true;
        s.addremove = false;

        o = s.option(form.Value, 'prefix', _('MAC address prefix'), _('Supports "000000" format'))
        o.datatype  = 'and(hexstring,rangelength(2,8))';
        [
            ["044A6C", "Huawei"],
            ["3CCD57", "Xiaomi"],
            ["603A7C", "TP-LINK"],
            ["00E04C", "Realtek"],
            ["68ECC5", "Intel"],
            ["8086F2", "Intel"],
            ["3C3786", "NETGEAR"],
            ["7C10C9", "ASUS"],
            ["68DB54", "Phicomm"],
            ["020000", "Private"],
            ["021234", "Private"],
            ["02AABB", "Private"],
        ].forEach(function(oui){
            o.value(oui[0], oui[0] + ' (' + oui[1] + ')');
        });

        o = s.option(CBIMacAddress, 'macaddr', _('MAC address'), _('Supports "00:00:00:00:00:00" format'))
        o.datatype   = 'macaddr';
        o.rmempty    = false;
        o.placeholder = '02:00:00:00:00:00';
        o.btnTitle = _('Randomly Generate Using Prefix');
        o.clickFn = genMAC;

        return m.render();
    }
});
