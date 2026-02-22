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

# 从编译阶段复制二进制文件并改名为 xupnpd-bin
COPY --from=builder /src/src/xupnpd-x86 /app/xupnpd-bin

# 复制所有脚本和资源到 /app/ 目录
COPY --from=builder /src/src/*.lua /app/
COPY --from=builder /src/src/profiles /app/profiles
COPY --from=builder /src/src/plugins /app/plugins
COPY --from=builder /src/src/ui /app/ui
COPY --from=builder /src/src/www /app/www
COPY --from=builder /src/src/playlists /app/playlists

# 默认端口
EXPOSE 4044

# 核心修正：由于 xupnpd.lua 已经由用户在宿主机通过 volume 挂载到 /app/xupnpd.lua，
# 而 xupnpd 程序启动时需要指定配置文件。
# 我们直接运行程序并指向挂载的配置文件。
# 注意：程序搜索脚本的路径是基于执行时的当前目录。
CMD ["./xupnpd-bin", "xupnpd"]
