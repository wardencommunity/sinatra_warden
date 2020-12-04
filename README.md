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

## Options

`Sinatra::Warden` lets you override options to customize functionality. You can place them anywhere after executing `register Sinatra::Warden` in your application.

Configurations are set using the set action: `set :setting_name, value`

### Configuration Settings

| Setting Name | Type | Description |
| ---          | ---  | ---         |
| `:auth_success_path` | String/Proc | The path you want to redirect to on authentication success. Defaults to `"/"`. |
| `:auth_failure_path` | String/Proc | The path you want to redirect to on authentication failure. (e.g. `"/error"`) Defaults to `lambda { back }`. |
| `:auth_success_message` | String | The `flash[:success]` message to display (requires Rack::Flash). Defaults to `"You have logged in successfully."` |
| `:auth_error_message` | String | The `flash[:error]` message to display (requires Rack::Flash). Defaults to `"Could not log you in."` |
| `:auth_template_renderer` | String | Template renderer to use. Defaults to `haml`, can also use `erb` |
| `:auth_login_template` | Symbol | The path to the login form you want to use with Sinatra::Warden. Defaults to `:login`. |

### OAuth Configuration Settings

_Available since sinatra_warden >= 1.6.x_

| Setting Name | Type | Description |
| ---          | ---  | --- |
| `:auth_use_oauth` | Boolean | Use OAuth authorization for the `"/login"` route. Defaults to `false`. |
| `:auth_oauth_authorization_url` | Proc/String | The path you want to redirect to for OAuth authorization (e.g. `lambda { consumer.get_request_token.authorize_url }`. |


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
