'use strict';
'require form';
'require poll';
'require rpc';
'require uci';
'require view';

var callServiceList = rpc.declare({
	object: 'service',
	method: 'list',
	params: ['name'],
	expect: { '': {} }
});

function getServiceStatus() {
	return L.resolveDefault(callServiceList('spotifyd'), {}).then(function (res) {
		var isRunning = false;
		try {
			isRunning = res['spotifyd']['instances']['spotifyd']['running'];
		} catch (e) { }
		return isRunning;
	});
}

function renderStatus(isRunning) {
	var spanTemp = '<em><span style="color:%s"><strong>%s %s</strong></span></em>';
	var renderHTML;
	if (isRunning) {
		renderHTML = spanTemp.format('green', _('Spotifyd'), _('RUNNING'));
	} else {
		renderHTML = spanTemp.format('red', _('Spotifyd'), _('NOT RUNNING'));
	}

	return renderHTML;
}

return view.extend({
	render: function() {
		var m, s, o;

		m = new form.Map('spotifyd', _('Spotifyd'),
			_('An open source Spotify client running as a UNIX daemon.'));

		s = m.section(form.TypedSection);
		s.anonymous = true;
		s.render = function () {
			poll.add(function () {
				return L.resolveDefault(getServiceStatus()).then(function (res) {
					var view = document.getElementById('service_status');
					view.innerHTML = renderStatus(res);
				});
			});

			return E('div', { class: 'cbi-section', id: 'status_bar' }, [
					E('p', { id: 'service_status' }, _('Collecting data…'))
			]);
		}

		s = m.section(form.NamedSection, 'config', 'spotifyd');

		o = s.option(form.Flag, 'enabled', _('Enable'));
		o.rmempty = false;

		o = s.option(form.Value, 'username', _('Username'));

		o = s.option(form.Value, 'password', _('Password'));
		o.password = true;

		o = s.option(form.Value, 'device_name', _('Device name'));

		o = s.option(form.ListValue, 'device_type', _('Device type'));
		o.value('audiodongle');
		o.value('avr');
		o.value('computer');
		o.value('smartphone');
		o.value('speaker');
		o.value('stb');
		o.value('tablet');
		o.value('tv');

		o = s.option(form.ListValue, 'backend', _('Backend'));
		o.value('alsa');
		o.default = 'alsa';
		o.rmempty = false;

		o = s.option(form.Value, 'control', _('Control device'));

		o = s.option(form.Value, 'device', _('Audio device'));

		o = s.option(form.Value, 'mixer', _('Mixer device'));

		o = s.option(form.Flag, 'autoplay', _('Autoplay similar music'),
			_('Start playing similar songs after your music has ended.'));

		o = s.option(form.ListValue, 'audio_format', _('Audio format'),
			_('The audio format of the streamed audio data.'));
		o.value('S16');
		o.value('S24');
		o.value('S24_3');
		o.value('S32');
		o.value('F32');
		o.default = 'S32';
		o.rmempty = false;

		o = s.option(form.ListValue, 'bitrate', _('Audio bitrate'),
			_('The bitrate of the streamed audio data.'));
		o.value('96');
		o.value('160');
		o.value('320');
		o.default = '320';
		o.rmempty = false;

		o = s.option(form.Value, 'initial_volume', _('Initial volume'));
		o.value('0');
		o.value('25');
		o.value('50');
		o.value('75');
		o.value('100');
		o.datatype = 'uinteger';

		o = s.option(form.Flag, 'volume_normalisation', _('Volume normalisation'),
			_('Enable to normalize the volume during playback.'));

		o = s.option(form.Value, 'normalisation_pregain', _('Normalisation pregain'),
			_('A custom pregain applied before sending the audio to the output device.'));

		o = s.option(form.ListValue, 'volume_controller', _('Volume controller'));
		o.value('none');
		o.value('alsa');
		o.value('alsa_linear');
		o.value('softvol');
		o.default = 'alsa';
		o.rmempty = false;

		o = s.option(form.Flag, 'no_audio_cache', _('Enable cache'));
		o.enabled = '0';
		o.disabled = '1';
		o.default = '1';

		o = s.option(form.Value, 'cache_path', _('Cache path'));
		o.depends('no_audio_cache', '0');

		o = s.option(form.Value, 'max_cache_size', _('Max cache size'),
			_('The maximal cache size in bytes.'));
		o.datatype = 'uinteger';
		o.depends('no_audio_cache', '0');

		o = s.option(form.Value, 'on_song_change_hook', _('Song change hook'),
			_('A script that gets evaluated in the user\'s shell when the song changes.'));

		o = s.option(form.Value, 'proxy', _('Proxy server'),
			_('The proxy used to connect to Spotify\'s servers.'));

		o = s.option(form.Value, 'zeroconf_port', _('Zeroconf port'),
			_('The port used for the Spotify Connect discovery.'));
		o.datatype = 'port';

		return m.render();
	}
});
