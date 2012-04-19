## What is this?

Jacha is a xmpp4r based bot. Currently, it only handles XMPP connection pool and checks whether given JID is online.
Also, it can be started as a dedicated service.

## Installation

    gem 'jacha'

## Configuration

Put somewhere in your initializers the following code:

```ruby
Jacha.configure do |config|
  config.jid = 'jid@example.com'
  config.password = 'password'
  config.size = 3
  # uncomment to apply charset related xmpp4r monkeypatch
  # config.fix_charset!
end

if some_environment_specific_condition
  Jacha::ConnectionPool.spawn
end
```

Then you anytime can get a random connection from the pool and perform some actions.

```ruby
jacha_connection = Jacha::ConnectionPool.get_connection
jacha_connection.jabber  # here is wrapped Jabber::Client from xmpp4r
jacha_connection.online? 'someone@example.com'
jacha_connection.online? 'another@example.com', optional_timeout_in_seconds
```

Credits
-------

<img src="http://roundlake.ru/assets/logo.png" align="right" />

* Alexander Pavlenko ([@alerticus](http://twitter.com/#!/alerticus))

<br/>

LICENSE
-------

It is free software, and may be redistributed under the terms of MIT license.
