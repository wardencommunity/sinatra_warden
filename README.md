# Sinatra::Warden

A [Sinatra](http://github.com/sinatra/sinatra) module that provides authentication for your Sinatra application through [Warden](http://github.com/wardencommunity/warden).

## Usage

```ruby
  require 'sinatra'
  require 'sinatra_warden'

  class Application < Sinatra::Base
    register Sinatra::Warden

    get '/admin' do
      authorize!('/login') # require session, redirect to '/login' instead of work
      haml :admin
    end

    get '/dashboard' do
      authorize! # require a session for this action
      haml :dashboard
    end
  end
```

## More Information

Please read the [wiki](http://wiki.github.com/wardencommunity/sinatra_warden) for more information on more advanced configurations.

## Note on Patches/Pull Requests

```
  $ git clone git://github.com/wardencommunity/sinatra_warden.git
  $ cd sinatra_warden
  $ bundle install
  $ bundle exec rake
```

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
* Send me a pull request. Bonus points for topic branches.

## Contributors

* Justin Smestad (http://github.com/jsmestad)
* Daniel Neighman (http://github.com/hassox)
* Shane Hanna (http://github.com/shanna)
* Alex - crhym3 (http://github.com/crhym3)

## Copyright

Copyright (c) 2009-2017 Justin Smestad. See LICENSE for details.
