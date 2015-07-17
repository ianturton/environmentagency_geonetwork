var modalDialog = (function() {
	var overlay = null,
		checkbox = null,
		checkboxLabel = null,
		button = null,
		link = null,
		iframe = null,
		overlayStyling = '',
		checkboxStyling = '',
		buttonStyling = '',
		linkStyling = '',
		iFrameStyling = '',
		cookieName = 'modaldialog';
		
	function showOverlay() {
		if (overlay !== null)
			return;
			
		overlay = document.createElement('div');
		overlay.setAttribute('id','modal-dialog-overlay');
		overlay.setAttribute('style', 'position:absolute;top:0;left:0;width:100%;height:100%;z-index:99999;overflow:hidden;text-align:center;background-color:#000;background-color:rgba(0,0,0,0.75);' + overlayStyling);
		checkbox = document.createElement('input');
		checkbox.setAttribute('type', 'checkbox');
		checkbox.setAttribute('id', 'modal-dialog-checkbox');
		checkbox.setAttribute('name', 'modal-dialog-checkbox');
		checkbox.setAttribute('checked', '');
		checkboxLabel = document.createElement('label');
		checkboxLabel.setAttribute('for', 'modal-dialog-checkbox');
		checkboxLabel.setAttribute('style', 'color:#fff;');
		checkboxLabel.appendChild(document.createTextNode('Show this next time'))
		button = document.createElement('div');
		button.setAttribute('id', 'modal-dialog-button');
		button.setAttribute('style', 'background-color:#fff;margin-top:8px;padding:8px 0;width:100px;margin:8px auto;position:relative;border-radius:8px;' + buttonStyling)
		link = document.createElement('a');
		link.setAttribute('href', 'javascript:void(0);');
		link.setAttribute('style', 'width:100px;display:inline-block;height:20px;' + linkStyling)
		link.appendChild(document.createTextNode('OK'));
		bind(link, 'click', close);
		button.appendChild(link);
		overlay.appendChild(button);
		overlay.appendChild(checkbox);
		overlay.appendChild(checkboxLabel);
	}
	
	function showIFrame(url) {
		if (!url) 
			url = 'about:blank';
		
		if (typeof(overlay) !== undefined && overlay !== null) {
			close();
		}
		
		if (typeof(overlay) === 'undefined' || overlay === null)
			showOverlay();
			
		iframe = document.createElement('iframe');
		iframe.setAttribute('id', 'modal-dialog-iframe');
		iframe.setAttribute('src', url);
		iframe.setAttribute('style', 'width:500px;height:500px;margin-top:50px;' + iFrameStyling)
		overlay.insertBefore(iframe, button);
		
		document.body.appendChild(overlay);
	}
	
	function showDialog(id, frequency, url) {
		cookieName = 'modaldialog::' + id;
		
		if (cookieExists())
			return; // cookie exists, don't show it
		
		if (document.getElementById(id) !== null) {
			showIFrame(url);
			return;
		}
		
		window.setTimeout(function() {
			showDialog(id, frequency, url);
		}, frequency);
	}
	
	function close() {
		if (checkbox.checked) {
			deleteCookie();
		} else {
			createCookie();
		}
		unbind(link, 'click', close);
		document.body.removeChild(overlay);
		iframe = null;
		link = null;
		button = null;
		overlay = null;
	}
	
	function bind(el, evt, func) {
	    if (el.addEventListener){
	        el.addEventListener(evt, func, false);
	    } else if (el.attachEvent) {
	        el.attachEvent('on' + evt, func);
	    }
	}
	
	function unbind(el, evt, func) {
		if (el.removeEventListener) {
			el.removeEventListener(evt, func, false);
		} else if (el.detachEvent) {
			el.detachEvent('on' + evt, func);
		}
	}
	
	function setCookie(cname, cvalue, exdays) {
	    var d = new Date();
	    d.setTime(d.getTime() + (exdays*24*60*60*1000));
	    var expires = "expires="+d.toUTCString();
	    document.cookie = cname + "=" + cvalue + "; " + expires;
	}	
	
	function getCookie(cname) {
	    var name = cname + "=";
	    var ca = document.cookie.split(';');
	    for(var i=0; i<ca.length; i++) {
	        var c = ca[i];
	        while (c.charAt(0)==' ') c = c.substring(1);
	        if (c.indexOf(name) != -1) return c.substring(name.length,c.length);
	    }
	    return "";
	}
	
	function deleteCookie() {
		document.cookie = cookieName + '=;expires=Thu, 01 Jan 1970 00:00:00 UTC';
	}
	
	function createCookie() {
		setCookie(cookieName, 'true', 100);
	}
	
	function cookieExists() {
		var cookie = getCookie(cookieName);
		return '' !== cookie;
	}

	return {
		showDialog: function(id, frequency, url) {
			showDialog(id, frequency, url);
		},
		
		setOverlayStyling: function(style) {
			overlayStyling = style;
		},
		
		setButtonStyling: function(style) {
			buttonStyling = style;
		},
		
		setLinkStyling: function(style) {
			linkStyling = style;
		},
		
		setiFrameStyling: function(style) {
			iFrameStyling = style;
		}
	};
})();

/*
 *
 * The Modal Dialog allows us to easily add a pop-up dialog box to a page which the user has 
 * to accept before they can use the page. 
 *
 * Instructions
 *   Include the script into the source page, then use the following syntax to create a dialog:
 *     modalDialog.showDialog('idOfElement', 500, 'urlofdialog.htm');
 * 
 * Parameters:
 *   idOfElement: The id of the element to wait for before we show the dialog
 *   500: The number of milliseconds to wait between checking for the element
 *   'urlofdialog.htm': The url of the page that will be loaded into the iFrame
 * 
 * You can also add additional styling to each of the elements to customise the page by using
 * these functions
 *   modalDialog.setOverlayStyling(style);
 *   modalDialog.setButtonStyling(style);
 *   modalDialog.setLinkStyling(style);
 *   modalDialog.setiFrameStyling(style);
 * 
 * Each of these functions accepts CSS styling as a parameter ('width:500px;height:400px;color:#f00') 
 * and adds it to the styling of the relevant element.
 *  
 */
