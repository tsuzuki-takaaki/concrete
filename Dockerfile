FROM ruby:3.2-bookworm

# This packages is not needed, just for searching in the container
RUN apt update -y && apt install -y \
    vim \
    netcat-openbsd \
    default-mysql-client

WORKDIR /app
COPY /Gemfile ./Gemfile
RUN bundle install

COPY /app.rb ./app.rb

CMD ["ruby", "app.rb"]
