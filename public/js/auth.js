$(window).ready(function() {
  console.log(window.location.href);
  var parts = window.location.href.split('#');
  parts.shift();
  var querystring = parts.join('#');
  var pairs = querystring.split('&');
  var query = {}
  var pairs = querystring.split('&');
  for (var idx in pairs) {
    var pair = pairs[idx];
    var parts = pair.split('=');
    var name = parts.shift();
    var value = unescape(parts.join('='));
    query[name] = value;
  }
  $.post('/key', query, function(data) {
    $('#key').val(data);
  });
});
