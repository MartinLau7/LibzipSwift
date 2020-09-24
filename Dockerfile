# DockerFile 当前仅配置了依赖配置，尚未完成编译

FROM harbor.tutuapp.net/baseimages/swift

WORKDIR /tutucodesign

# 安装 Swift 相关依赖
RUN apt update \
    && apt install -qq libbz2-1.0 libbz2-dev libbz2-ocaml libbz2-ocaml-dev openssl libssl-dev libsqlite3-dev libncurses5-dev
    && RUN apt-get clean

WORKDIR /.build

# 编译
# swift build -c release;
# 拷贝编译完成的二进制
# mv .build/x86_64-unknown-linux-gnu/release/<projectName> /tutucodesign/<projectName>
# 执行二进制 非必要
# ./<projectName>
