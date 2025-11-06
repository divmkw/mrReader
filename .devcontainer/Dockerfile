# Base: Ubuntu with build essentials
FROM ubuntu:22.04

# Prevent prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install essentials
RUN apt-get update && apt-get install -y \
    curl unzip git wget xz-utils zip libglu1-mesa openjdk-17-jdk-headless \
    ca-certificates gnupg lsb-release sudo apt-transport-https \
    fonts-droid-fallback fonts-noto-color-emoji \
    chromium-browser \
    && rm -rf /var/lib/apt/lists/*

# Set environment paths
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV PATH=${PATH}:/opt/flutter/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
RUN flutter config --no-analytics

# Install Android SDK commandline tools
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && cd ${ANDROID_HOME}/cmdline-tools \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip \
    && unzip cmdline-tools.zip -d latest \
    && rm cmdline-tools.zip

# Install SDK components (platforms, build-tools, NDK)
RUN yes | sdkmanager --licenses
RUN sdkmanager --sdk_root=${ANDROID_HOME} \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0" \
    "cmdline-tools;latest" \
    "ndk;27.0.12077973"

# Enable Flutter web support + Chrome
RUN flutter config --enable-web
RUN flutter precache --web

# Clean up
RUN flutter doctor -v

WORKDIR /workspaces
