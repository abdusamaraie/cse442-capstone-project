from werkzeug.wsgi import LimitedStream

class Filestream(object):

    def __init__(self, app):
        self.app = app

    def __call__(self, environ, start_response):
        stream = LimitedStream(environ['wsgi.input'], int(environ.get('CONTENT_LENGTH') or 0))
        environ['wsgi.input'] = stream
        app_iter = self.app(environ, start_response)
        try:
            stream.exhaust()
            for event in app_iter:
                yield event
        finally:
            if hasattr(app_iter, 'close'):
                app_iter.close()