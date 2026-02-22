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

# 编译
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

# 核心修正：xupnpd 默认在当前目录寻找脚本，我们必须把 src 目录下的所有 lua 脚本复制到 /app/
# 根据 github 源码结构，xupnpd_main.lua 等脚本就在 src 目录下
COPY --from=builder /src/src/*.lua /app/
COPY --from=builder /src/src/profiles /app/profiles
COPY --from=builder /src/src/plugins /app/plugins
COPY --from=builder /src/src/ui /app/ui
COPY --from=builder /src/src/www /app/www
COPY --from=builder /src/src/playlists /app/playlists

# 默认端口
EXPOSE 4044

# 启动
CMD ["./xupnpd"]
