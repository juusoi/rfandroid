FROM node:lts-buster
WORKDIR /robot

RUN npm i -g npm
RUN npm i -g appium --unsafe-perm=true --allow-root

RUN apt-get update -qqy && \
    apt-get install -qqy --no-install-recommends \
    apt-utils \
    python3-pip \
    default-jdk

RUN python3 -m pip install --upgrade pip

COPY . .
RUN python3 -m pip install setuptools
RUN python3 -m pip install -r requirements.txt

ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
ENV PATH=$PATH:$JAVA_HOME/bin

ARG SDK_VERSION=commandlinetools-linux-6514223_latest
ARG ANDROID_BUILD_TOOLS_VERSION=30.0.0
ARG ANDROID_PLATFORM_VERSION="android-30"

ENV SDK_VERSION=$SDK_VERSION \
    ANDROID_BUILD_TOOLS_VERSION=$ANDROID_BUILD_TOOLS_VERSION \
    ANDROID_HOME=/robot/android

RUN wget -O tools.zip https://dl.google.com/android/repository/${SDK_VERSION}.zip && \
    unzip -d $ANDROID_HOME tools.zip && rm tools.zip && \
    chmod a+x -R $ANDROID_HOME && \
    chown -R root:root $ANDROID_HOME

ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin

RUN yes | $ANDROID_HOME/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses
RUN $ANDROID_HOME/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools" "platforms;$ANDROID_PLATFORM_VERSION" "emulator"

ENV PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools

COPY entrypoint.sh /usr/local/bin/
RUN chmod ugo+x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]