# HackSoc Calendar API
## Deployment

For host 0.0.0.0, port 9000, production mode, in a terminal:

```
gem install bundler
bundle install
bundle exec main.rb -p 9000 -e production
```

Swapping `production` for `development` will enable stack traces and host on `localhost` instead of `0.0.0.0`.