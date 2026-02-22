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

# 安装运行依赖 (xupnpd 主要是静态链接 Lua，但可能需要基础库)
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 从编译阶段复制二进制文件和必要的脚本
COPY --from=builder /src/src/xupnpd-x86 /app/xupnpd
COPY --from=builder /src/xupnpd.lua /app/
COPY --from=builder /src/profiles /app/profiles
COPY --from=builder /src/plugins /app/plugins
COPY --from=builder /src/ui /app/ui
COPY --from=builder /src/www /app/www
COPY --from=builder /src/playlists /app/playlists
COPY --from=builder /src/config /app/config

# 默认端口
EXPOSE 4044

# 启动脚本：xupnpd 默认以守护进程运行，Docker 需要在前台运行
# 使用 -v 级别提高日志输出，或者修改 lua 配置
CMD ["./xupnpd"]
