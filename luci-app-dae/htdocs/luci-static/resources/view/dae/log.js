// SPDX-License-Identifier: Apache-2.0

'use strict';
'require dom';
'require fs';
'require poll';
'require view';

return view.extend({
	render: function() {
		/* Thanks to luci-app-aria2 */
		var css = '					\
			#log_textarea {				\
				text-align: left;		\
			}					\
			#log_textarea pre {			\
				padding: .5rem;			\
				word-break: break-all;		\
				margin: 0;			\
			}					\
			.description {				\
				background-color: #33ccff;	\
			}';

		var log_textarea = E('div', { 'id': 'log_textarea' },
			E('img', {
				'src': L.resource(['icons/loading.gif']),
				'alt': _('Loading...'),
				'style': 'vertical-align:middle'
			}, _('Collecting data…'))
		);

		poll.add(L.bind(function() {
			return fs.read_direct('/var/log/dae/dae.log', 'text')
			.then(function(content) {
				var log = E('pre', { 'wrap': 'pre' }, [
					content.trim() || _('Log is empty.')
				]);

				dom.content(log_textarea, log);
			}).catch(function(e) {
				var log;

				if (e.toString().includes('NotFoundError'))
					log = E('pre', { 'wrap': 'pre' }, [
						_('Log file does not exist.')
					]);
				else
					log = E('pre', { 'wrap': 'pre' }, [
						_('Unknown error: %s').format(e)
					]);

				dom.content(log_textarea, log);
			});
		}));

		var scrollDownButton = E('button', { 
				'id': 'scrollDownButton',
				'class': 'cbi-button cbi-button-neutral',
			}, _('Scroll to tail', 'scroll to bottom (the tail) of the log file')
		);
		scrollDownButton.addEventListener('click', function() {
			window.scrollTo(0, document.body.scrollHeight);
		});

		var scrollUpButton = E('button', { 
				'id' : 'scrollUpButton',
				'class': 'cbi-button cbi-button-neutral',
			}, _('Scroll to head', 'scroll to top (the head) of the log file')
		);
		scrollUpButton.addEventListener('click', function() {
			window.scrollTo(0, 0);
		});

		return E([
			E('style', [ css ]),
			E('h2', {}, [ _('Log') ]),
			E('div', {'class': 'cbi-map'}, [
				E('div', {'style': 'padding-bottom: 20px'}, [scrollDownButton]),
				E('div', {'class': 'cbi-section'}, [
					log_textarea,
					E('div', {'style': 'text-align:right'},
						E('small', {}, _('Refresh every %s seconds.').format(L.env.pollinterval))
					)
				]),
				E('div', {'style': 'padding-bottom: 20px'}, [scrollUpButton])
			])
		]);
	},

	handleSaveApply: null,
	handleSave: null,
	handleReset: null
});
