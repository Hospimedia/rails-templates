FROM ruby:3.1.2-bullseye

ARG USER_ID
ARG GROUP_ID
ARG USER
ARG HOME

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y locales aspell-fr libidn11-dev libaspell-dev \
    g++ build-essential && \
    echo 'en_US.UTF-8 UTF-8' >/etc/locale.gen && \
    echo 'fr_FR.UTF-8 UTF-8'>>/etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn

RUN curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install -y nodejs

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    groupadd -g ${GROUP_ID} ${USER} &&\
    useradd -l -u ${USER_ID} -g ${USER} ${USER} &&\
    install -d -m 0755 -o ${USER} -g ${USER} ${HOME}; fi

USER ${USER}

RUN mkdir -p ${HOME}/app
WORKDIR ${HOME}/app

RUN mkdir ${HOME}/.ssh/ && \
    ssh-keyscan github.com >> ${HOME}/.ssh/known_hosts && \
    echo 'gem: --no-rdoc --no-ri' >> ~/.gemrc && \
    gem install bundler

COPY /start-app.sh /start-app.sh

EXPOSE 3000

ENTRYPOINT ["/start-app.sh"]
