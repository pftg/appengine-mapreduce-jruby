var stxt = '';
function makeWnd(wname,w,h,strong) {
if(strong==''||strong==null||typeof(strong)=='undefined') {
	strong = false;
}
posStr='';
sw=screen.width;
sh=screen.height;
ww=sw-220;
//wh=sh-Math.round(sh/100*25);
wh=sh-175;

if(w>0) ww = w;
if(h>0) wh = h;

posx=(sw-ww)-15;
posy=0;
if(document.all) posStr=',left='+posx+',top='+posy;
else if(document.layers) posStr=',screenX='+posx+',screenY='+posy;

var parm = strong ? 'directories=0,location=0,menubar=0,toolbar=0,titlebar=0,status=0,scrollbars=0,resizable=0' : 'location=0,menubar=1,toolbar=1,status=1,scrollbars=1,resizable=1'

w = open("",wname,parm+",height="+wh+",width="+ww+posStr,true);
w.focus();
return (w);
}

function gomenu(https,url)
{
	if(https) {
		document.location = 'https://'+document.location.host.toString()+'/'+url;
	} else {
		document.location = 'http://'+document.location.host.toString()+'/'+url;
	}
	return false;
}
function logoff()
{
	if(confirm("Завершить сеанс?")) {
		document.location='https://www.marathonbet.com/bin/logout.mpl';
	}
}
function statusTxt(txt) {
	if(txt == '') {
		stxt = '';
	} else {
		stxt = txt+" - Букмекерская контора 'Марафон'";
	}
	window.status=stxt;
	setTimeout('statusTxt2(stxt);',10);
	return true;
}; 
function statusTxt2(txt) {
	status=txt;
	stxt = txt;
	return true;
}
function sdef() {
	stxt = '';
	statusTxt(stxt);
	return true;
}

sdef();
