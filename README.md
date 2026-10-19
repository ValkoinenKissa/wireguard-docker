# wireguard-docker

Dockerized WireGuard VPN server based on the `linuxserver/wireguard` image.
Intended for remote access to an internal LAN (e.g. home network) over UDP,
as a lower-latency alternative to slow VPN protocols over TCP.

## Requirements

- Linux host with Docker and Docker Compose
- A UDP port (default `51820`) open on the firewall/router and forwarded to the host

## Quick start

1. Copy the environment template and fill it in:
```bash
   cp .env.example .env
```
2. Start the container:
```bash
   docker compose up -d
```
3. Collect the generated client configs from `./config/peer*/`.
4. Deliver each `.conf` to its user through a secure channel (never through this repo).
5. On the client, import the `.conf` into the WireGuard app and activate the tunnel.
6. Test with `ping` to a host on the LAN.

## Configuration

| Variable | Description |
|---|---|
| `TZ` | Time zone (e.g. `Europe/Madrid`) |
| `SERVERURL` | Public IP or DNS name of the server |
| `SERVERPORT` | Public UDP port |
| `PEERS` | Number of client configs to generate |
| `INTERNAL_SUBNET` | Tunnel subnet (e.g. `10.13.13.0`) |
| `ALLOWEDIPS` | Networks routed through the tunnel (tunnel subnet + LAN to reach) |

Using only the tunnel subnet and the target LAN in `ALLOWEDIPS` gives a split
tunnel: only that traffic goes through the VPN, not all the client's traffic.

## Managing peers

- Add peers: increase `PEERS` in `.env`, then run
  `docker compose up -d --force-recreate`.
- Revoke a peer: remove it from `PEERS`/config and recreate the container,
  or regenerate the configuration.

## Troubleshooting

```bash
docker logs wireguard
docker exec wireguard wg show
```

- No handshake: check the UDP port forwarding and that `SERVERURL` is reachable.
- Handshake OK but no traffic to the LAN: the destination hosts must be able to
  reply to the tunnel subnet (NAT/masquerade on the VPN host, or a static route
  on the router).
- Slow or odd behavior: check the MTU (try lowering it in the client config).
- Do not connect another VPN to the same subnet at the same time; routes will clash.

## Security

- `config/` and `.env` contain private keys and network details. Both are in `.gitignore`.
- Never commit `.conf` files or QR codes.
- If a key is committed by mistake, regenerate all keys and rewrite the Git history;
  deleting it in a later commit is not enough.
- Keep the repository private if it contains details of an internal network.

## Repository structure

```
.
├── docker-compose.yml
├── .env.example
├── .gitignore
└── README.md
```