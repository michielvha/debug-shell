#!/usr/bin/env bash
set -euo pipefail

image="${1:?Usage: bash tests/image-smoke.sh IMAGE}"

docker run --rm --network none --read-only --tmpfs /tmp \
    --cap-drop ALL --security-opt no-new-privileges "$image" \
    /bin/bash -euo pipefail -c '
        test "$EUID" -eq 1000
        for tool in dig nslookup drill ping curl wget nc tcpdump nmap netstat ip ss strace; do
            command -v "$tool"
        done
        test -z "$(getcap /bin/busybox)"
        id
        uname -s
        sleep 0
        dig -v
        drill -v
        curl --version
        (
            for request in 1 2; do
                printf "HTTP/1.1 200 OK\r\nContent-Length: 23\r\nConnection: close\r\n\r\ndebug-shell smoke test\n" |
                    nc -N -l 127.0.0.1 18080 > /dev/null
            done
        ) &
        server_pid=$!
        trap '\''if kill -0 "$server_pid" 2>/dev/null; then kill "$server_pid"; fi'\'' EXIT
        response="$(curl -fsS --max-time 5 --retry 5 --retry-connrefused --retry-delay 1 --retry-max-time 15 http://127.0.0.1:18080/)"
        test "$response" = "debug-shell smoke test"
        test "$(wget --timeout=5 --retry-connrefused --waitretry=1 --tries=5 -qO- http://127.0.0.1:18080/)" = "$response"
        wait "$server_pid"
        trap - EXIT
    '

docker run --rm --network none --read-only --tmpfs /tmp \
    --cap-drop ALL --cap-add NET_RAW "$image" \
    /bin/bash -euo pipefail -c '
        test "$EUID" -eq 1000
        test ! -u /bin/ping
        for binary in /bin/ping /usr/bin/tcpdump /usr/bin/nmap; do
            test "$(getcap "$binary")" = "$binary cap_net_raw=ep"
        done
        timeout 10 tcpdump -p -n -i lo -c 1 icmp > /tmp/packets.log 2>&1 &
        capture_pid=$!
        ping -c 3 -W 2 127.0.0.1
        if ! wait "$capture_pid"; then
            cat /tmp/packets.log >&2
            exit 1
        fi
        grep -q "1 packet captured" /tmp/packets.log
        nmap --privileged -sS -Pn -p 9 127.0.0.1
    '

printf 'Image smoke tests passed: %s\n' "$image"
