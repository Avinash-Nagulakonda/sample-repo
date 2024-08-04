var http = require('http');

http.createServer(function (req, res) {
  res.write('** Hey my app was deployed :) **'); 
  res.end(); 
}).listen(3000);
