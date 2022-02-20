FROM ruby:3.1.0-alpine

COPY lib /action/lib

CMD ["ruby", "/action/lib/main.rb"]
