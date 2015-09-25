function misskey_open_share_window(url) {
	window.open(url, "Misskey", "width=600,height=400,scrollbars=yes");
}

window.onload = function() {
	document.getElementsByClassName('misskey-share')[0].innerHTML = "\
		<style>\
			.misskey-share {\
				margin: 2px;\
			}\
			.misskey-share .b {\
				display: inline-block;\
				position: relative;\
				box-sizing: border-box;\
				overflow: hidden;\
				/*min-height: 20px;*/\
				/*height: 20px;*/\
				min-height: 22px;\
				max-height: 22px;\
				margin: 0;\
				padding: 2px 6px 2px 3px;\
				cursor: pointer;\
				color: #000;\
				text-decoration: none;\
				border: solid 1px #CCC;\
				outline: none;\
				background: #fefcea;\
				background: -moz-linear-gradient(top,#fff 0%,#f2f2f2 100%);\
				background: -webkit-gradient(linear,left top,left bottom,color-stop(0%,#fff),color-stop(100%,#f2f2f2));\
				background: -webkit-linear-gradient(top,#fff 0%,#f2f2f2 100%);\
				background: -o-linear-gradient(top,#fff 0%,#f2f2f2 100%);\
				background: -ms-linear-gradient(top,#fff 0%,#f2f2f2 100%);\
				background: linear-gradient(to bottom,#fff 0%,#f2f2f2 100%);\
				transition: all 0.2s linear;\
			}\
			.misskey-share .b:hover {\
				color: #000;\
				background-color: #F2F2F2;\
				border: solid 1px #1bb3b3;\
				transition: all 0s linear;\
			}\
			.misskey-share .b:active {\
				background-color: #EBEBEB;\
				box-shadow: 0 1px 0 0 rgba(0,0,0,0.1) inset;\
				border: solid 1px #1bb3b3;\
				transition: all 0s linear;\
			}\
			.misskey-share .b:focus {\
				border: solid 1px #1bb3b3;\
			}\
			.misskey-share .b img {\
				display: inline-block;\
				position: absolute;\
				top: 2px;\
				left: 2px;\
				margin: 0;\
				min-width: 16px;\
				min-height: 16px;\
			}\
			.misskey-share .b span {\
				display: inline-block;\
				margin: 0 0 0 16px;\
				line-height: 16px;\
				vertical-align: top;\
				font-size: 0.8em;\
			}\
			.misskey-share .b:active img {\
				margin-top: 1px;\
			}\
			.misskey-share .b:active span {\
				margin-top: 1px;\
			}\
			.misskey-share .count {\
				display: inline-block;\
				position: relative;\
				box-sizing: border-box;\
				vertical-align: top;\
				min-height: 22px;\
				max-height: 22px;\
				margin: 0 2px;\
				padding: 0 4px;\
				font-size: 1em;\
				background: #fff;\
				border: #ccc solid 1px;\
				border-radius: 3px;\
			}\
			.misskey-share .count:before {\
				border: solid transparent;\
				content: '';\
				height: 0;\
				right: 100%;\
				position: absolute;\
				width: 0;\
				border-width: 5px;\
				border-right-color: #ccc;\
				top: 5px;\
			}\
			.misskey-share .count:after {\
				border: solid transparent;\
				content: '';\
				height: 0;\
				right: 100%;\
				position: absolute;\
				width: 0;\
				border-width: 3px;\
				border-right-color: #fff;\
				top: 7px;\
			}\
			.misskey-share .count span {\
				display: inline;\
				margin: 0;\
				vertical-align: top;\
				line-height: 21px;\
				font-size: 0.8em;\
				color: #000;\
			}\
		</style>\
		<a href=\"http://api.misskey.xyz/share?title="+document.title+"&url="+location.href+"\" target='misskey' title=\"Misskeyでみんなと共有\" onclick=\"misskey_open_share_window('https://api.misskey.xyz/share?title="+document.title+"&url="+location.href+"'); return false;\" class=\"b\">\
			<img src=\"http://misskey.xyz/resources/common/images/sharebutton-icon.png\" alt=\"\">\
			<span>Share!</span>\
		</a>\
		<div class=\"count\">\
			<span class=\"misskey-share-count\">-</span>\
		</div>";
	var ajax=null;
	if(XMLHttpRequest){
		ajax=new XMLHttpRequest();
	}else{
		ajax= new ActiveXObject('MSXML2.XMLHTTP.6.0');
		if(!ajax){
			ajax = ActiveXObject('MSXML2.XMLHTTP.3.0');
			if(!ajax){
				ajax = ActiveXObject('MSXML2.XMLHTTP');
				if(!ajax){
					return;
				}
			}
		}
	}
	ajax.open('GET','https://api.misskey.xyz/share/count?text='+location.href,true);
	ajax.onreadystatechange = function Receive(){
		if(ajax.readyState==4 && ajax.status==200){
			document.getElementsByClassName('misskey-share-count')[0].innerHTML = ajax.responseText;
			return;
		}else if(ajax.status!=200){
			return;
		}
	}
	ajax.send(null);
}
