 # ruby:3.4.9-slim-trixie
FROM ruby@sha256:a842f35cdf2fe24a7523182127c3ce6a4848e77fb50b3a57ec09faa59c96491e

RUN useradd --create-home --shell /bin/bash appuser

COPY lib /action/lib

USER appuser

CMD ["ruby", "/action/lib/main.rb"]
