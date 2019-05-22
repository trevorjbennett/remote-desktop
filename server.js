    let http = require('http');

    let fs = require('fs');

    var url  = require('url'); 

    const { exec } = require('child_process');

    let handleRequest = (request, response) => {

	var url_parts = url.parse(request.url, true);

	var query = url_parts.query;

	var s = JSON.stringify(query);

	var file = './index.html';

	var contenttype = "'Content-Type': 'text/plain'";

if (s.indexOf("scp")>0) {

	exec('event.exe ' + s);

}

if (s.indexOf("lu")>0) {

	exec('event.exe /lu');

}

if (s.indexOf("ld")>0) {

	exec('event.exe /ld');

}

if (s.indexOf("ru")>0) {

	exec('event.exe /ru');

}

if (s.indexOf("rd")>0) {

	exec('event.exe /rd');
	

}

if (s.indexOf("ku")>0) {

	exec('event.exe /ku '+s);

}

if (s.indexOf("kd")>0) {

	exec('event.exe /kd '+s);
	

}

if (s.indexOf("img")>0) {

	file = './screen.jpg';
    
	contenttype = "'Content-Type': 'image/jpeg'";

}

if (s.indexOf("jquery")>0) {

	file = './jquery-3.4.1.min.js';
    
	contenttype = "'Content-Type': 'application/javascript'";

}

    response.writeHead(200, {
        contenttype 
    });

    fs.readFile(file, null, function (error, data) {

if (error) {

		response.writeHead(404);
		response.write('file not found');

} else {

		response.write(data);

	}
        response.end();
    });
};
 
    http.createServer(handleRequest).listen(8000);