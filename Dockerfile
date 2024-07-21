FROM ruby:3.2-bookworm

# This packages is not needed, just for searching in the container
RUN apt update -y && apt install -y \
    vim \
    netcat-openbsd \
    default-mysql-client

WORKDIR /app
COPY /Gemfile /app/Gemfile
RUN bundle install

COPY /src /app/src

CMD ["ruby", "/app/src/app.rb"]
