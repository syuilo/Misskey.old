$(function()
{
    socket = io.connect('https://api.misskey.xyz:1207/streaming/home', { port: 1207 });

    socket.on('connected', function()
    {
        console.log('Connected');
    });

    socket.on('disconnect', function(client)
    {
    });

    socket.on('post', function(content)
    {
        console.log(content);
        var $post = TIMELINE.generatePostElement(content, conf).hide()
        TIMELINE.setEventPost($post);
        $post.prependTo($('#timeline > .timeline > .posts')).show(200);
    });

    $('#postForm').submit(function(event)
    {
        event.preventDefault();
        var $form = $(this);
        var $submitButton = $form.find('[type=submit]');

        $submitButton.attr('disabled', true);
        $submitButton.text('Updating...');

        $.ajax($form.attr('action'), {
            type: $form.attr('method'),
            processData: false,
            contentType: false,
            data: new FormData($form[0]),
            dataType: 'json',
            xhrFields: {
                withCredentials: true
            }
        }).done(function(data)
        {
            $form[0].reset();
            $submitButton.attr('disabled', false);
            $submitButton.text('Update');
        }).fail(function(data)
        {
            $form[0].reset();
            /*alert('error');*/
            $submitButton.attr('disabled', false);
            $submitButton.text('Update');
        });
    });
});

