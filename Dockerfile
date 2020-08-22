FROM ruby:2.6.3
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y yarn nodejs postgresql-client
RUN gem install bundler:2.0.2
RUN mkdir -p /misete/accounts
WORKDIR /misete/accounts
COPY Gemfile /misete/accounts/Gemfile
COPY Gemfile.lock /misete/accounts/Gemfile.lock
COPY package.json /misete/accounts/package.json
RUN bundle install --jobs 4 --retry 5
RUN yarn install --check-files
COPY . /misete/accounts

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]