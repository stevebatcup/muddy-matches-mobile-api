FROM ruby:2.7.1

RUN apt-get update -yqq \
  && apt-get install -yqq --no-install-recommends \
  default-mysql-client default-libmysqlclient-dev vim nodejs \
  && rm -rf /var/lib/apt/lists

ENV RAILS_ENV development
ENV APP_PATH /usr/src/app
ENV PATH $APP_PATH/bin:$PATH
ENV BUNDLE_PATH /usr/src/gems

RUN groupadd appuser
RUN useradd -m -r -u 1000 -g appuser appuser

RUN mkdir -p $BUNDLE_PATH
RUN chown appuser:appuser $BUNDLE_PATH

USER appuser

WORKDIR $APP_PATH

ADD . $APP_PATH

EXPOSE 4050
CMD ./lib/start-rails.sh