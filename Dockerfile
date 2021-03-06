FROM circleci/node:8.9.2-browsers

USER root

###
# Java install
# See https://github.com/docker-library/openjdk/blob/415b0cc42d91ef5d70597d8a24d942967728242b/8-jdk/Dockerfile
# see https://bugs.debian.org/775775
# and https://github.com/docker-library/java/issues/19#issuecomment-70546872
RUN JAVA_DEBIAN_VERSION="8u131-b11-1~bpo8+1" \
 && CA_CERTIFICATES_JAVA_VERSION="20161107~bpo8+1" \
 && echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list \
 && apt-get update \
 && apt-get install -y \
    openjdk-8-jre-headless="$JAVA_DEBIAN_VERSION" \
    ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
 && rm -rf /var/lib/apt/lists/*

###
# Bazel install
# See https://bazel.build/versions/master/docs/install-ubuntu.html#using-bazel-custom-apt-repository-recommended
RUN BAZEL_VERSION="0.8.1" \
 && wget -q -O - https://bazel.build/bazel-release.pub.gpg | apt-key add - \
 && echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" > /etc/apt/sources.list.d/bazel.list \
 && apt-get update \
 && apt-get install -y bazel=$BAZEL_VERSION \
 && rm -rf /var/lib/apt/lists/*

###
# Brotli compression
# Not available on backports so we have to pull from Debian 9
# See https://packages.debian.org/search?keywords=brotli
RUN echo "deb http://deb.debian.org/debian stretch main contrib" > /etc/apt/sources.list.d/stretch.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends brotli/stretch

###
# Buildifier
# BUILD file formatter
# 'bazel clean --expunge' conserves size of the image
RUN git clone https://github.com/bazelbuild/buildtools.git \
 && (cd buildtools \
  && bazel build //buildifier \
  && cp bazel-bin/buildifier/buildifier /usr/local/bin/ \
  && bazel clean --expunge \
  )

USER circleci

ENTRYPOINT ["/bin/bash"]
