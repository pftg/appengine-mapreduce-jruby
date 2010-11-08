function goTo(where) {
        document.location.replace(where);
        return false;
}
function OpenMatchStat(sss) {
        window.open('http://results.marathonbet.com/sportstatbeto.php?event='+sss, 's', 'scrollbars=1,resizable=1,width=800,height=600')
}
function LinkOn(text, e) {
  if (document.body.clientHeight<event.clientY+50){;
   YY=event.clientY+document.body.scrollTop-40;
  } else {
   YY=event.clientY+document.body.scrollTop+15;
  }
  document.all["ieview"].innerHTML='<nobr><font size="-1">&nbsp;'+text + '&nbsp;</font></nobr>';
  document.all["ieview"].style.posHeight=10;
  document.all["ieview"].style.posWidth=10;
  document.all["ieview"].style.posTop=YY;
  document.all["ieview"].style.posLeft=event.clientX;
  document.all["ieview"].style.visibility='visible';
}
function LinkOff() {
  document.all["ieview"].style.visibility='hidden';
}
function logoff() {
        if(confirm("Завершить сеанс?")) {
                document.location='https://www.marathonbet.com/bin/logout.mpl';
        }
}
function rf(i) {
  i.c = i.checked
}
function rc(i) {
  if(i.c) i.c = i.checked = false
  else i.c = true
}

