FROM jdxcode/mise:2026.5
WORKDIR /src
USER root
RUN apt update && apt upgrade -y
RUN apt install zsh -y && chsh -s /usr/bin/zsh
RUN apt install tree
COPY .mise/config.toml .mise/
RUN mise trust && mise install
RUN apt install vim tree -y
ENTRYPOINT [ "" ]