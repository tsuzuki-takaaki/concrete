FROM ruby:3.2-bookworm

RUN apt update -y && apt install -y \
		vim \
		netcat-openbsd

WORKDIR /app
COPY /Gemfile ./Gemfile
COPY /app.rb ./app.rb

RUN bundle install

CMD ["bash"]
