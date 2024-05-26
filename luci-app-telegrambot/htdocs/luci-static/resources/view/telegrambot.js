'use strict';
'require form';
'require fs';
'require view';
'require uci';
'require ui';
'require tools.widgets as widgets'


return view.extend({
	render: function(data) {
		var m, s, o

		m = new form.Map('telegrambot', _('TelegramBot'), _('Telegram bot for router with firmware Lede/Openwrt.'));
		s = m.section(form.TypedSection, 'telegram_bot', null);
		s.anonymous = true;

		o = s.option(form.Flag, 'enabled', _('Enable'), _('Enable Bot'));
		o.rmempty = true;

		o = s.option(form.Value, 'bot_token', _('Bot Token'), _('Token ID your Telegram Bot'));
		o.password = true;

		o = s.option(form.Value, 'chat_id', _('Chat ID'), _('Chat ID your Telegram'));

		o = s.option(form.Value, 'timeout', _('Delay'), _('Time Out respone Bot in sec.'));

		o = s.option(form.Value, 'polling_time', _('Polling Time'), _('Polling Time in sec.'));

		o = s.option(form.Value, 'plugins', _('Plugins'), _('Path to plugins directory.'));
		o.default = ('/usr/lib/telegrambot/plugins');

		o = s.option(form.Value, 'log_file', _('Log File'), _('Log File'));
		o.default = ('/tmp/telegrambot.log');

		return m.render();
	}
});
