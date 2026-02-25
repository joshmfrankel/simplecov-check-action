FROM ruby:3.1.0-slim

COPY lib /action/lib

CMD ["ruby", "/action/lib/main.rb"]
