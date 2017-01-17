iOS 10: URLSessionConfiguration.background does not persist cookies
===================================================================

When an URLSession is configured using URLSessionConfiguration.background,
the session does not persist cookies between the requests.

This example does two network calls using:

    session?.dataTask(with: req)

The first call request a cookie and the second call verifies, that the
cookie has been sent with the request.

Using an iOS 9 Simulator, the view controller confirms, that the requested
cookie was submitted to the server when doing the second request.

With an iOS 10 Simulator (and real device), the example behaves different.
The requested cookie, neither session or a cookie with a lifetime, is
not persisted and using for subsequent requests to the same domain.

This bug was filed as rdar://30049163 on 16 Jan 2017.
