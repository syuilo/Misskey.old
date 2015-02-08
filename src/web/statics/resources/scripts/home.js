$(function() {
	socket = io.connect("https://api.misskey.xyz:1207/streaming/home", { port: 1207 });

	socket.on("connected", function() {
		console.log('Connected');
	});

	socket.on("disconnect", function(client) {
	});

	socket.on("post", function(content) {
		console.log(content);
	});
});