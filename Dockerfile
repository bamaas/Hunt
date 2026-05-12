FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV SHELL=/usr/bin/zsh
ENV MISE_IGNORED_CONFIG_PATHS=/workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
    zsh git curl ca-certificates tree \
    && rm -rf /var/lib/apt/lists/*

COPY . /root/.hunt
RUN SHELL=/usr/bin/zsh bash /root/.hunt/install.sh --yes

WORKDIR /workspace
ENTRYPOINT ["/usr/bin/zsh", "-ic", "hunt"]
