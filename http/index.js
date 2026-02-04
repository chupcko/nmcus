var sel='';
window.onload = function() {
  document.getElementById('scanBtn').onclick=scan;
  document.getElementById('connBtn').onclick=connect;
};

function status(t) {
  document.getElementById('status').textContent=t
}

function scan() {
  status('Scanning...');
  fetch('/api/scan_ap').then(
    function(r) {
      return r.json();
    }
  ).then(
    function(d) {
      var h='';
      for(var b in d) {
        h += '<label><input type="radio" name="ap" value="'+d[b]+'" onchange="sel=this.value">'+d[b]+'</label>';
      }
      document.getElementById('list').innerHTML=h||'No networks found';
      status('Scan done');
    }
  );
}

function connect() {
  if(!sel) {
    status('Select network');
    return;
  }
  var p=document.getElementById('pwd').value;
  status('Connecting...');
  fetch(
    '/api/set_sta',
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body : JSON.stringify({ ssid: sel, pwd: p })
    }
  ).then(
    function() {
      var n = 0;
      iv =setInterval(
        function() {
          fetch('/api/get_sta_state').then(
            function(r) {
              return r.json();
            }
          ).then(
            function(d) {
              if(d.connected) {
                clearInterval(iv);
                status('Connected!');
              } else if(++n>=10) {
                clearInterval(iv);
                status('Connection failed');
              }
            }
          );
        },
        1000
      );
    }
  )
}
