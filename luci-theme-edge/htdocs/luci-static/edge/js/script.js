/**
 *  Edge is a clean HTML5 theme for LuCI. It is based on luci-theme-Argon
 *
 *  luci-theme-edge
 *      Copyright 2020 Kiddin'
 *
 *  Have a bug? Please create an issue here on GitHub!
 *      https://github.com/kiddin9/luci-theme-edge/issues
 *
 *  luci-theme-material: 
 *      Copyright 2015 Lutty Yang <lutty@wcan.in>
 *		https://github.com/LuttyYang/luci-theme-material/
 *
 *  Agron Theme
 *	    https://demos.creative-tim.com/argon-dashboard/index.html
 *
 *  Login background
 *      https://unsplash.com/
 *  Font generate by Icomoon<icomoon.io>
 *
 *  Licensed to the public under the Apache License 2.0
 */

document.addEventListener('luci-loaded', function(ev) {
(function ($) {
	$(".main > .loading").fadeOut();

	/**
	 * trim text, Remove spaces, wrap
	 * @param text
	 * @returns {string}
	 */
	function trimText(text) {
		return text.replace(/[ \t\n\r]+/g, " ");
	}

	var lastNode = undefined;
	var mainNodeName = undefined;

	var nodeUrl = "";
	(function(node){
		var luciLocation;
		if (node[0] == "admin"){
			luciLocation = [node[1], node[2]];
		}else{
			luciLocation = node;
		}

		for(var i in luciLocation){
			nodeUrl += luciLocation[i];
			if (i != luciLocation.length - 1){
				nodeUrl += "/";
			}
		}
	})(luciLocation);

	/**
	 * get the current node by Burl (primary)
	 * @returns {boolean} success?
	 */
	function getCurrentNodeByUrl() {
		var ret = false;
		if (!$('body').hasClass('logged-in')) {
			luciLocation = ["Main", "Login"];
			return true;
		}

		return ret;
	}

	/**
	 * get current node and open it
	 */
	if (getCurrentNodeByUrl()) {
		mainNodeName = "node-" + luciLocation[0] + "-" + luciLocation[1];
		mainNodeName = mainNodeName.replace(/[ \t\n\r\/]+/g, "_").toLowerCase();
		$("body").addClass(mainNodeName);
	}

	/**
	 * Sidebar expand
	 */
	var showSide = false;
	$(".showSide").click(function () {
		if (showSide) {
			$(".darkMask").stop(true).fadeOut("fast");
			$(".main-left").stop(true).animate({
				width: "0"
			}, "200");
			$(".main-right").css("overflow-y", "visible");
			showSide = false;
		} else {
			$(".darkMask").stop(true).fadeIn("fast");
			$(".main-left").stop(true).animate({
				width: "13rem"
			}, "200");
			$(".main-right").css("overflow-y", "hidden");
			showSide = true;
		}
	});

	$(".darkMask").click(function () {
		if (showSide) {
			showSide = false;
			$(".darkMask").stop(true).fadeOut("fast");
			$(".main-left").stop(true).animate({
				width: "0"
			}, "fast");
			$(".main-right").css("overflow-y", "visible");
		}
	});

	$(window).resize(function () {
		if ($(window).width() > 921) {
			$(".main-left").css("width", "");
			$(".darkMask").stop(true);
			$(".darkMask").css("display", "none");
			showSide = false;
		}
	});

	/**
	 * fix legend position
	 */
	$("legend").each(function () {
		var that = $(this);
		that.after("<span class='panel-title'>" + that.text() + "</span>");
	});

	$(".cbi-section-table-titles, .cbi-section-table-descr, .cbi-section-descr").each(function () {
		var that = $(this);
		if (that.text().trim() == ""){
			that.css("display", "none");
		}
	});

	$(".main-right").focus();
	$(".main-right").blur();
	$("input").attr("size", "0");
	$(".cbi-button-up").val("__");
	$(".cbi-button-down").val("__");
	$(".slide > a").removeAttr("href");

	if (mainNodeName != undefined) {
		console.log(mainNodeName);
		switch (mainNodeName) {
			case "node-status-system_log":
			case "node-status-kernel_log":
				$("#syslog").focus(function () {
					$("#syslog").blur();
					$(".main-right").focus();
					$(".main-right").blur();
				});
				break;
			case "node-status-firewall":
				var button = $(".node-status-firewall > .main fieldset li > a");
				button.addClass("cbi-button cbi-button-reset a-to-btn");
				break;
			case "node-system-reboot":
				var button = $(".node-system-reboot > .main > .main-right p > a");
				button.addClass("cbi-button cbi-input-reset a-to-btn");
				break;
		}
	}
	
   var getaudio = $('#player')[0];
   /* Get the audio from the player (using the player's ID), the [0] is necessary */
   var audiostatus = 'off';
   /* Global variable for the audio's status (off or on). It's a bit crude but it works for determining the status. */


   $(document).on('click touchend', '.speaker', function() {
     /* Touchend is necessary for mobile devices, click alone won't work */
     if (!$('.speaker').hasClass("speakerplay")) {
       if (audiostatus == 'off') {
         $('.speaker').addClass('speakerplay');
         getaudio.load();
         getaudio.play();
         audiostatus = 'on';
         return false;
       } else if (audiostatus == 'on') {
         $('.speaker').addClass('speakerplay');
         getaudio.play()
       }
     } else if ($('.speaker').hasClass("speakerplay")) {
       getaudio.pause();
       $('.speaker').removeClass('speakerplay');
       audiostatus = 'on';
     }
   });

   $('#player').on('ended', function() {
     $('.speaker').removeClass('speakerplay');
     /*When the audio has finished playing, remove the class speakerplay*/
     audiostatus = 'off';
     /*Set the status back to off*/
   });
	setTimeout(function(){
$("input[type='checkbox']").filter(function () {
  return (!$(this).next("label").length)
}).show();
	}, 0);

var options = { attributes: true};
function callback() {
$("input[type='checkbox']").filter(function () {
  return (!$(this).next("label").length)
}).show();
}
var mutationObserver = new MutationObserver(callback);
 mutationObserver.observe($("body")[0], options);
 $(".cbi-value").has("textarea").css("background","none");
if(document.body.scrollHeight > window.innerHeight){
	$(".cbi-page-actions.control-group").addClass("fixed")
}
})(jQuery);
});