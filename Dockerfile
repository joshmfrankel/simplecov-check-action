FROM ruby:3.4.2-slim

COPY lib /action/lib

CMD ["ruby", "/action/lib/main.rb"]
