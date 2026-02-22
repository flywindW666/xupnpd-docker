# xupnpd Docker

eXtensible UPnP agent (xupnpd) Dockerized.

## Quick Start

1. Clone this repo.
2. Run `docker-compose up -d`.
3. Access web UI at `http://your-ip:4044`.

## Note

This container uses `network_mode: host` to support UPnP/DLNA discovery and multicast traffic.

Modify `xupnpd.lua` (via volume mapping) to set your correct `cfg.ssdp_interface`.
