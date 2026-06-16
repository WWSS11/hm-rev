#!/bin/sh
set -eu

if [ "$#" -eq 0 ]; then
    set -- serve
fi

if [ "$1" = "serve" ]; then
    shift
    set -- hm-api serve \
        --host "${HM_API_HOST:-0.0.0.0}" \
        --port "${HM_API_PORT:-8000}" \
        "$@"

    if [ -n "${HM_API_PROXY:-}" ]; then
        set -- "$@" --proxy "$HM_API_PROXY"
    fi

    if [ -n "${HM_API_KEY:-}" ]; then
        set -- "$@" --key "$HM_API_KEY"
    fi

    exec "$@"
fi

if [ "$1" = "login" ] && [ -n "${HM_API_PROXY:-}" ]; then
    shift
    exec hm-api login --proxy "$HM_API_PROXY" "$@"
fi

if [ "$1" = "hm-api" ]; then
    exec "$@"
fi

exec hm-api "$@"
