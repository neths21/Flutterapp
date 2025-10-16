FROM ubuntu:22.04

# Install dependencies (with OpenJDK 17)
RUN apt-get update && apt-get install -y \
    git curl unzip xz-utils zip libglu1-mesa openjdk-17-jdk wget

# Create non-root user
RUN useradd -ms /bin/bash flutteruser
USER flutteruser
WORKDIR /home/flutteruser

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable flutter
ENV PATH="/home/flutteruser/flutter/bin:/home/flutteruser/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Disable Flutter analytics
RUN flutter config --no-analytics

# Install Android SDK command-line tools
RUN mkdir -p /home/flutteruser/Android/cmdline-tools
WORKDIR /home/flutteruser/Android
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O commandlinetools.zip && \
    unzip commandlinetools.zip -d cmdline-tools && \
    rm commandlinetools.zip && \
    mv cmdline-tools/cmdline-tools cmdline-tools/latest

# Set Android environment variables
ENV ANDROID_HOME=/home/flutteruser/Android
ENV PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install required SDK packages
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME \
    "platform-tools" "platforms;android-33" "build-tools;33.0.2"

# Switch back to app folder
WORKDIR /home/flutteruser/app

# Switch to root temporarily for copying files
USER root
COPY . .
RUN chown -R flutteruser:flutteruser /home/flutteruser

# Switch back to flutteruser
USER flutteruser

# Get dependencies
RUN flutter pub get

# Build APK
RUN flutter build apk --release
