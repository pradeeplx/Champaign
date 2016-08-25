FROM ruby:2.3.1-alpine

# Dependencies
#   build-base        contains tools required to build native gem extensions
#
#   git               Needed by bundler
#
#   nodejs            Provides `node` and `npm`
#
#   tzdata            Installs the `/usr/share/zoneinfo/` data files (needed by rails / TZInfo)
#                     https://github.com/tzinfo/tzinfo/wiki/Resolving-TZInfo::DataSourceNotFound-Errors 
#                     
#   imagemagick       Provides `identify` and `convert` utilities (rmagick)
#   imagemagick-dev   Needed to build RMagick's native gem extensions 
#
#   postgresql-dev    Needed to build native extensions for the `pg` gem


# By default the alpine image doesn't have a local cache of all available packages
# so we need to fetch one
RUN apk update

RUN apk add build-base
RUN apk add git
RUN apk add tzdata
RUN apk add nodejs
RUN apk add imagemagick
RUN apk add imagemagick-dev
RUN apk add postgresql-dev

#### NOTE: at this point, it'd be better to commit these changes and create our own image


RUN mkdir /myapp
WORKDIR /myapp

# In testing, we'll probably want phantomjs
# RUN npm install -g phantomjs-prebuilt

# This rarely changes so we should have it before bundle install in order to take
# advantage of caching
ADD package.json /myapp/
RUN npm install

# Bundler
# =======
#
# In development, we'd want to do this:
# ADD Gemfile* /myapp/
# RUN bundle install --jobs 4
#
# In testing, we'd want to do this:
# ADD Gemfile* /myapp/
# RUN bundle install --jobs 4 --without development
#
# In production, we'd want to do this:
ADD Gemfile* /myapp/
RUN bundle install --jobs 4 --deployment --without development test

# We can now uninstall the `builddeps` packages (optional)
RUN apk del build-base

EXPOSE 3000
ADD . /myapp

# In production we'd precompile assets and run the server in production mode.
RUN RAILS_ENV=production bundle exec rake assets:precompile
CMD bundle exec puma -b tcp://0.0.0.0 -p 3000 -t 5:16 -e production

# In development, we don't need to precompile assets and we'd run the
# server in development mode
# CMD bundle exec puma -b tcp://0.0.0.0 -p 3000 -t 5:16

