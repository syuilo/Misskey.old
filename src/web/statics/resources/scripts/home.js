$(function() {
	socket = io.connect("https://api.misskey.xyz/streaming/home", { port: 443 });

	socket.on("connected", function() {
		console.log('Connected');
	});

	socket.on("disconnect", function(client) {
	});

	socket.on("post", function(content) {
		console.log(content);
	});
});