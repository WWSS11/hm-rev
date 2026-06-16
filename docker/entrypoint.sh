#!/bin/sh
set -eu

if [ "$#" -eq 0 ]; then
    set -- serve
fi

if [ "$1" = "serve" ]; then
    shift
    if [ "${HM_API_AUTO_LOGIN:-1}" = "1" ] && [ ! -f /app/cred/token.enc ]; then
        export HM_API_LOGIN_BIND_HOST="${HM_API_LOGIN_BIND_HOST:-0.0.0.0}"
        login_args="--no-browser"
        if [ -n "${HM_API_PROXY:-}" ]; then
            hm-api login --proxy "$HM_API_PROXY" $login_args
        else
            hm-api login $login_args
        fi
    fi

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
