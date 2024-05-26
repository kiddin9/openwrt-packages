"use strict";
"require form";
"require fs";
"require rpc";
"require view";
"require tools.widgets as widgets";

var callServiceList = rpc.declare({
  object: "service",
  method: "list",
  params: ["name"],
  expect: { "": {} },
});

function getInstances() {
  return L.resolveDefault(callServiceList("natmap"), {}).then(function (res) {
    try {
      return res.natmap.instances || {};
    } catch (e) {}
    return {};
  });
}

function getStatus() {
  return getInstances().then(function (instances) {
    var promises = [];
    var status = {};
    for (var key in instances) {
      var i = instances[key];
      if (i.running && i.pid) {
        var f = "/var/run/natmap/" + i.pid + ".json";
        (function (k) {
          promises.push(
            fs
              .read(f)
              .then(function (res) {
                status[k] = JSON.parse(res);
              })
              .catch(function (e) {})
          );
        })(key);
      }
    }
    return Promise.all(promises).then(function () {
      return status;
    });
  });
}

return view.extend({
  load: function () {
    return getStatus();
  },
  render: function (status) {
    var m, s, o;

    m = new form.Map("natmap", _("NatMap Settings"));
    s = m.section(form.GridSection, "natmap");
    s.addremove = true;
    s.anonymous = true;
    s.sortable = true;

    s.tab("general", _("General Settings"));
    s.tab("forward", _("Forward Settings"));
    s.tab("notify", _("Notify Settings"));
    s.tab("link", _("Link Settings"));
    s.tab("custom", _("Custom Settings"));

    // o = s.option(form.DummyValue, '_nat_name', _('Name'));
    // o.modalonly = false;
    // o.textvalue = function (section_id) {
    // 	var s = status[section_id];
    // 	if (s) return s.name;
    // };

    // **********************************************************************
    // general
    // **********************************************************************
    o = s.taboption("general", form.Value, "general_nat_name", _("Name"));
    o.datatype = "string";
    // o.modalonly = true;
    o.rmempty = false;

    o = s.taboption(
      "general",
      form.ListValue,
      "general_nat_protocol",
      _("Protocol")
    );
    o.default = "tcp";
    o.value("tcp", _("TCP"));
    o.value("udp", _("UDP"));

    o = s.taboption(
      "general",
      form.ListValue,
      "general_ip_address_family",
      _("Restrict to address family")
    );
    o.modalonly = true;
    o.value("", _("IPv4 and IPv6"));
    o.value("ipv4", _("IPv4 only"));
    o.value("ipv6", _("IPv6 only"));

    o = s.taboption(
      "general",
      widgets.NetworkSelect,
      "general_wan_interface",
      _("Wan Interface")
    );
    o.modalonly = true;
    o.rmempty = false;

    o = s.taboption(
      "general",
      form.Value,
      "general_interval",
      _("Keep-alive interval")
    );
    o.datatype = "uinteger";
    o.modalonly = true;
    o.rmempty = false;

    o = s.taboption(
      "general",
      form.Value,
      "general_stun_server",
      _("STUN server")
    );
    o.datatype = "host";
    o.modalonly = true;
    o.optional = false;
    o.rmempty = false;

    o = s.taboption(
      "general",
      form.Value,
      "general_http_server",
      _("HTTP server"),
      _("For TCP mode")
    );
    o.datatype = "host";
    o.modalonly = true;
    o.rmempty = false;

    o = s.taboption("general", form.Value, "general_bind_port", _("Bind port"));
    o.datatype = "port";
    o.rmempty = false;

    // **********************************************************************
    // forward
    // **********************************************************************
    o = s.taboption(
      "forward",
      form.Flag,
      "forward_enable",
      _("Enable Forward")
    );
    o.default = false;
    o.modalonly = true;
    // o.ucioption = 'forward_mode';
    // o.load = function (section_id) {
    // 	return this.super('load', section_id) ? '1' : '0';
    // };
    // o.write = function (section_id, formvalue) { };

    o = s.taboption(
      "forward",
      form.ListValue,
      "forward_mode",
      _("Forward mode")
    );
    o.default = "firewall";
    o.value("firewall", _("firewall dnat"));
    o.value("natmap", _("natmap"));
    o.value("ikuai", _("ikuai"));
    // o.depends('forward_enable', '1');

    // forward_natmap, forward_ikuai, forward_firewall
    o = s.taboption(
      "forward",
      form.Value,
      "forward_target_ip",
      _("Forward target")
    );
    o.datatype = "ip4addr";
    o.modalonly = true;
    o.depends("forward_mode", "firewall");
    o.depends("forward_mode", "natmap");
    o.depends("forward_mode", "ikuai");

    o = s.taboption(
      "forward",
      form.Value,
      "forward_target_port",
      _("Forward target port"),
      _("0 will forward to the out port get from STUN")
    );
    o.datatype = "port";
    o.modalonly = true;
    o.depends("forward_mode", "firewall");
    o.depends("forward_mode", "natmap");
    o.depends("forward_mode", "ikuai");

    // forward_firewall
    o = s.taboption(
      "forward",
      widgets.NetworkSelect,
      "forward_firewall_target_interface",
      _("Target_Interface")
    );
    o.modalonly = true;
    o.depends("forward_mode", "firewall");

    // forward_ikuai
    o = s.taboption(
      "forward",
      form.Value,
      "forward_ikuai_web_url",
      _("Ikuai Web URL"),
      _(
        "such as http://127.0.0.1:8080 or http://ikuai.lan:8080.if use host,must close Rebind protection in DHCP/DNS."
      )
    );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("forward_mode", "ikuai");

    o = s.taboption(
      "forward",
      form.Value,
      "forward_ikuai_username",
      _("Ikuai Username")
    );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("forward_mode", "ikuai");

    o = s.taboption(
      "forward",
      form.Value,
      "forward_ikuai_password",
      _("Ikuai Password")
    );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("forward_mode", "ikuai");

    o = s.taboption(
      "forward",
      form.ListValue,
      "forward_ikuai_mapping_protocol",
      _("Ikuai Mapping Protocol"),
      _("such as tcp or udp or tcp+udp")
    );
    o.modalonly = true;
    o.value("tcp+udp", _("TCP+UDP"));
    o.value("tcp", _("TCP"));
    o.value("udp", _("UDP"));
    o.depends("forward_mode", "ikuai");

    o = s.taboption(
      "forward",
      form.Value,
      "forward_ikuai_mapping_wan_interface",
      _("Ikuai Mapping Wan Interface"),
      _("such as adsl_1 or wan")
    );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("forward_mode", "ikuai");

    // forward_advanced
    o = s.taboption(
      "forward",
      form.Flag,
      "forward_advanced_enable",
      _("Advanced Settings")
    );
    o.default = false;
    o.modalonly = true;
    o.depends("forward_mode", "ikuai");

    o = s.taboption(
      "forward",
      form.Value,
      "forward_advanced_max_retries",
      _("Max Retries"),
      _("max retries,default 0 means execute only once")
    );
    o.datatype = "uinteger";
    o.default = 0;
    o.modalonly = true;
    o.depends("forward_advanced_enable", "1");

    o = s.taboption(
      "forward",
      form.Value,
      "forward_advanced_sleep_time",
      _("Retry Interval"),
      _("Retry Interval, unit is seconds, default 0 is 3 seconds")
    );
    o.datatype = "uinteger";
    o.default = 0;
    o.modalonly = true;
    o.depends("forward_advanced_enable", "1");

    // **********************************************************************
    // notify
    // **********************************************************************
    o = s.taboption("notify", form.Flag, "notify_enable", _("Enable Notify"));
    o.default = false;
    o.modalonly = true;

    o = s.taboption(
      "notify",
      form.ListValue,
      "notify_mode",
      _("Notify channel")
    );
    o.default = "telegram_bot";
    o.modalonly = true;
    o.value("telegram_bot", _("Telegram Bot"));
    o.value("pushplus", _("PushPlus"));
    o.value("serverchan", _("ServerChan"));
    o.value("gotify", _("Gotify"));

    // notify_telegram_bot
    o = s.taboption(
      "notify",
      form.Value,
      "notify_telegram_bot_chat_id",
      _("Chat ID")
    );
    o.description =
      _("Get chat_id") +
      ' <a href="https://t.me/getuserIDbot" target="_blank">' +
      _("Click here") +
      "</a>" +
      _(
        ".<br />If you want to send to a group/channel, please create a non-Chinese group/channel (for easier chatid lookup, you can rename it later).<br />Add the bot to the group, send a message, and use https://api.telegram.org/bot token /getUpdates to obtain the chatid."
      );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("notify_mode", "telegram_bot");

    o = s.taboption(
      "notify",
      form.Value,
      "notify_telegram_bot_token",
      _("Telegram Token")
    );
    o.description =
      _("Get Bot") +
      ' <a href="https://t.me/BotFather" target="_blank">' +
      _("Click here") +
      "</a>" +
      _(".<br />Send a message to the created bot to initiate a conversation.");
    o.datatype = "string";
    o.modalonly = true;
    o.depends("notify_mode", "telegram_bot");

    o = s.taboption(
      "notify",
      form.Value,
      "notify_telegram_bot_proxy",
      _("http proxy")
    );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("notify_mode", "telegram_bot");

    //notify_pushplus
    o = s.taboption(
      "notify",
      form.Value,
      "notify_pushplus_token",
      _("PushPlus Token")
    );
    o.description =
      _("Get Instructions") +
      ' <a href="http://www.pushplus.plus/" target="_blank">' +
      _("Click here") +
      "</a>";
    o.datatype = "string";
    o.modalonly = true;
    o.depends("notify_mode", "pushplus");

    // serverchan
    o = s.taboption(
      "notify",
      form.Value,
      "notify_serverchan_sendkey",
      _("ServerChan sendkey")
    );
    o.description =
      _("Get Instructions") +
      ' <a href="https://sct.ftqq.com/" target="_blank">' +
      _("Click here") +
      "</a>" +
      _(
        ".<br />Since the asynchronous push queue is used, only whether the put into the queue is successful is detected."
      );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("notify_mode", "serverchan");

    // notify_serverchan_advanced
    o = s.taboption(
      "notify",
      form.Flag,
      "notify_serverchan_advanced_enable",
      _("ServerChan Advanced Settings")
    );
    o.default = false;
    o.modalonly = true;
    o.depends("notify_mode", "serverchan");

    o = s.taboption(
      "notify",
      form.Value,
      "notify_serverchan_advanced_url",
      _("Self-built Server Url")
    );
    o.description = _(
      "such as http://127.0.0.1:8080 or http://ikuai.lan:8080 ."
    );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("notify_serverchan_advanced_enable", "1");

    // gotify
    o = s.taboption("notify", form.Value, "notify_gotify_url", _("Gotify url"));
    o.description =
      _("Get Instructions") +
      ' <a href="https://gotify.net/" target="_blank">' +
      _("Click here") +
      "</a>";
    o.datatype = "string";
    o.modalonly = true;
    o.depends("notify_mode", "gotify");

    o = s.taboption(
      "notify",
      form.Value,
      "notify_gotify_token",
      _("Gotify Token")
    );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("notify_mode", "gotify");

    o = s.taboption(
      "notify",
      form.Value,
      "notify_gotify_priority",
      _("Gotify priority")
    );
    o.datatype = "uinteger";
    o.default = 5;
    o.modalonly = true;
    o.depends("notify_mode", "gotify");

    // notify_advanced
    o = s.taboption(
      "notify",
      form.Flag,
      "notify_advanced_enable",
      _("Advanced Settings")
    );
    o.default = false;
    o.modalonly = true;
    o.depends("notify_mode", "pushplus");
    o.depends("notify_mode", "telegram_bot");
    o.depends("notify_mode", "serverchan");
    o.depends("notify_mode", "gotify");

    o = s.taboption(
      "notify",
      form.Value,
      "notify_advanced_max_retries",
      _("Max Retries"),
      _("max retries,default 0 means execute only once")
    );
    o.datatype = "uinteger";
    o.default = 0;
    o.modalonly = true;
    o.depends("notify_advanced_enable", "1");

    o = s.taboption(
      "notify",
      form.Value,
      "notify_advanced_sleep_time",
      _("Retry Interval"),
      _("Retry Interval, unit is seconds, default 0 is 3 seconds")
    );
    o.datatype = "uinteger";
    o.default = 0;
    o.modalonly = true;
    o.depends("notify_advanced_enable", "1");

    // **********************************************************************
    // link
    // **********************************************************************
    o = s.taboption("link", form.Flag, "link_enable", _("Enable link setting"));
    o.modalonly = true;
    o.default = false;

    o = s.taboption("link", form.ListValue, "link_mode", _("Service"));
    o.default = "qbittorrent";
    o.modalonly = true;
    o.value("emby", _("Emby"));
    o.value("qbittorrent", _("qBittorrent"));
    o.value("transmission", _("Transmission"));
    o.value("cloudflare_origin_rule", _("Cloudflare Origin Rule"));
    o.value("cloudflare_redirect_rule", _("Cloudflare Redirect Rule"));
    o.value("cloudflare_ddns", _("Cloudflare DDNS"));

    //
    // link_cloudflare
    o = s.taboption(
      "link",
      form.Value,
      "link_cloudflare_token",
      _("Cloudflare Token")
    );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("link_mode", "cloudflare_origin_rule");
    o.depends("link_mode", "cloudflare_redirect_rule");
    o.depends("link_mode", "cloudflare_ddns");

    o = s.taboption(
      "link",
      form.Value,
      "link_cloudflare_zone_id",
      _("Cloudflare Zone ID")
    );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("link_mode", "cloudflare_origin_rule");
    o.depends("link_mode", "cloudflare_redirect_rule");
    o.depends("link_mode", "cloudflare_ddns");

    //link_cloudflare_ddns
    o = s.taboption(
      "link",
      form.ListValue,
      "link_cloudflare_ddns_type",
      _("Cloudflare DNS Type")
    );
    o.description = _(
      "cloudflare dns type, eg: AAAA、HTTPS、SRV, default: AAAA(IP4P)."
    );
    o.modalonly = true;
    o.default = "AAAA";
    o.value("AAAA", _("AAAA (IP4P)"));
    o.value("HTTPS", _("HTTPS"));
    o.value("SRV", _("SRV"));
    o.depends("link_mode", "cloudflare_ddns");

    o = s.taboption(
      "link",
      form.Value,
      "link_cloudflare_ddns_domain",
      _("Cloudflare DDNS Domain")
    );
    o.description =
      _("cloudflare ddns domain, eg: www.example.com.") +
      _("<br />before use it, must add dns record in cloudflare DNS.");
    o.datatype = "host";
    o.modalonly = true;
    o.depends("link_mode", "cloudflare_ddns");

    // link_cloudflare_origin_rule
    o = s.taboption(
      "link",
      form.Value,
      "link_cloudflare_origin_rule_name",
      _("Origin Rule Name")
    );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("link_mode", "cloudflare_origin_rule");

    // link_cloudflare_redirect_rule
    o = s.taboption(
      "link",
      form.Value,
      "link_cloudflare_redirect_rule_name",
      _("Redirect Rule Name")
    );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("link_mode", "cloudflare_redirect_rule");
    o = s.taboption(
      "link",
      form.Value,
      "link_cloudflare_redirect_rule_target_url",
      _("Redirect Rule Target URL")
    );
    o.description =
      _(
        "can used with ddns to redirect to the specified URL, such as http://1.2.3.4:1234 or http://abc.com:1234/abc ."
      ) +
      _(
        "<br />if want to use natmap outter_port, NEW_PORT must be used instead of the port in the URL, such as http://1.2.3.4:1234/NEW_PORT/abc ."
      );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("link_mode", "cloudflare_redirect_rule");

    // link_emby
    o = s.taboption(
      "link",
      form.Value,
      "link_emby_url",
      _("EMBY URL"),
      _(
        "such as http://127.0.0.1:8080 or http://ikuai.lan:8080.if use host,must close Rebind protection in DHCP/DNS."
      )
    );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("link_mode", "emby");

    o = s.taboption("link", form.Value, "link_emby_api_key", _("API Key"));
    o.datatype = "host";
    o.modalonly = true;
    o.depends("link_mode", "emby");

    o = s.taboption(
      "link",
      form.Flag,
      "link_emby_use_https",
      _("Update HTTPS Port"),
      _("Set to False if you want to use HTTP")
    );
    o.default = false;
    o.modalonly = true;
    o.depends("link_mode", "emby");

    o = s.taboption(
      "link",
      form.Flag,
      "link_emby_update_host_with_ip",
      _("Update host with IP")
    );
    o.default = false;
    o.modalonly = true;
    o.depends("link_mode", "emby");

    // link_qbittorrent
    o = s.taboption(
      "link",
      form.Value,
      "link_qb_web_url",
      _("Web UI URL"),
      _(
        "such as http://127.0.0.1:8080 or http://ikuai.lan:8080.if use host,must close Rebind protection in DHCP/DNS."
      )
    );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("link_mode", "qbittorrent");

    o = s.taboption("link", form.Value, "link_qb_username", _("Username"));
    o.datatype = "string";
    o.modalonly = true;
    o.depends("link_mode", "qbittorrent");

    o = s.taboption("link", form.Value, "link_qb_password", _("Password"));
    o.datatype = "string";
    o.modalonly = true;
    o.depends("link_mode", "qbittorrent");

    o = s.taboption("link", form.Flag, "link_qb_allow_ipv6", _("Allow IPv6"));
    o.default = false;
    o.modalonly = true;
    o.depends("link_mode", "qbittorrent");

    o = s.taboption(
      "link",
      form.Value,
      "link_qb_ipv6_address",
      _("IPv6 Address")
    );
    o.datatype = "ip6addr";
    o.modalonly = true;
    o.depends("link_qb_allow_ipv6", "1");

    // link_transmission
    o = s.taboption(
      "link",
      form.Value,
      "link_tr_rpc_url",
      _("RPC URL"),
      _(
        "such as http://127.0.0.1:8080 or http://ikuai.lan:8080.if use host,must close Rebind protection in DHCP/DNS."
      )
    );
    o.datatype = "string";
    o.modalonly = true;
    o.depends("link_mode", "transmission");

    o = s.taboption("link", form.Value, "link_tr_username", _("Username"));
    o.datatype = "string";
    o.modalonly = true;
    o.depends("link_mode", "transmission");

    o = s.taboption("link", form.Value, "link_tr_password", _("Password"));
    o.datatype = "string";
    o.modalonly = true;
    o.depends("link_mode", "transmission");

    o = s.taboption("link", form.Flag, "link_tr_allow_ipv6", _("Allow IPv6"));
    o.modalonly = true;
    o.default = false;
    o.depends("link_mode", "transmission");

    o = s.taboption(
      "link",
      form.Value,
      "link_tr_ipv6_address",
      _("IPv6 Address")
    );
    o.datatype = "ip6addr";
    o.modalonly = true;
    o.depends("link_tr_allow_ipv6", "1");

    // link_advanced
    o = s.taboption(
      "link",
      form.Flag,
      "link_advanced_enable",
      _("Advanced Settings")
    );
    o.default = false;
    o.modalonly = true;
    // o.depends("link_mode", "transmission");
    // o.depends("link_mode", "qbittorrent");
    // o.depends("link_mode", "emby");
    // o.depends("link_mode", "cloudflare_origin_rule");
    // o.depends("link_mode", "cloudflare_redirect_rule");
    // o.depends("link_mode", "cloudflare_ddns");

    o = s.taboption(
      "link",
      form.Value,
      "link_advanced_max_retries",
      _("Max Retries"),
      _("max retries,default 0 means execute only once")
    );
    o.datatype = "uinteger";
    o.default = 0;
    o.modalonly = true;
    o.depends("link_advanced_enable", "1");

    o = s.taboption(
      "link",
      form.Value,
      "link_advanced_sleep_time",
      _("Retry Interval"),
      _("Retry Interval, unit is seconds, default 0 is 3 seconds")
    );
    o.datatype = "uinteger";
    o.default = 0;
    o.modalonly = true;
    o.depends("link_advanced_enable", "1");

    // **********************************************************************
    // Custom Settings
    // **********************************************************************
    o = s.taboption(
      "custom",
      form.Flag,
      "custom_script_enable",
      _("Enable custom script's config")
    );
    o.modalonly = true;
    o.default = false;

    o = s.taboption(
      "custom",
      form.Value,
      "custom_script_path",
      _("custom script")
    );
    o.description =
      _("custom script path,such as /etc/natmap/custom.sh .argument format:") +
      _("<br />outter_ip=$1") +
      _("<br />outter_port=$2") +
      _("<br />ip4p=$3") +
      _("<br />inner_port=$4") +
      _("<br />protocol=$5");

    // o.depends('custom_script_enable', '1');
    o.datatype = "file";
    o.modalonly = true;

    // **********************************************************************
    // status
    // **********************************************************************
    o = s.option(form.DummyValue, "_external_ip", _("External IP"));
    o.modalonly = false;
    o.textvalue = function (section_id) {
      var s = status[section_id];
      if (s) return s.ip;
    };

    o = s.option(form.DummyValue, "_external_port", _("External Port"));
    o.modalonly = false;
    o.textvalue = function (section_id) {
      var s = status[section_id];
      if (s) return s.port;
    };

    // **********************************************************************
    // natmap_enable
    // **********************************************************************
    o = s.option(form.Flag, "natmap_enable", _("enable"));
    o.editable = true;
    o.modalonly = false;

    return m.render();
  },
});
