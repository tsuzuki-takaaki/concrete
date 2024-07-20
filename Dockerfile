FROM ruby:3.2-bookworm

WORKDIR /app
COPY /Gemfile ./Gemfile
COPY /app.rb ./app.rb

RUN bundle install

CMD ["bash"]
