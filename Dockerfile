# 第一阶段：编译
FROM ubuntu:22.04 AS builder

# 安装编译依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# 克隆源码
WORKDIR /src
RUN git clone https://github.com/clark15b/xupnpd.git .

# 编译 (src 目录下有源码和 Makefile)
WORKDIR /src/src
RUN make

# 第二阶段：运行
FROM ubuntu:22.04

# 安装运行依赖
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 从编译阶段复制二进制文件
COPY --from=builder /src/src/xupnpd-x86 /app/xupnpd

# 复制脚本和插件 (这些在根目录和 src 目录都有，根据 master 分支结构)
# 根据源码结构，主要的 lua 脚本和目录在 src 目录下
COPY --from=builder /src/src/xupnpd.lua /app/
COPY --from=builder /src/src/profiles /app/profiles
COPY --from=builder /src/src/plugins /app/plugins
COPY --from=builder /src/src/ui /app/ui
COPY --from=builder /src/src/www /app/www
COPY --from=builder /src/src/playlists /app/playlists

# 默认端口
EXPOSE 4044

# 启动
CMD ["./xupnpd"]
