$(window).ready(function() {
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
  pairs = [];
  for (var name in query) {
    pairs.push(name + '=' + escape(value));
  }
  var url = 'http://localhost:' + query.state + '?' + pairs.join('&');
  $.get(url, function(data) {
    // redirect to localhost
  });
});
