#!/usr/bin/env sh

[ -f "${SUB_STORE_DATA_BASE_PATH}/root.json" ] || echo "{}" > "${SUB_STORE_DATA_BASE_PATH}/root.json"
[ -f "${SUB_STORE_DATA_BASE_PATH}/sub-store.json" ] || echo "{}" > "${SUB_STORE_DATA_BASE_PATH}/sub-store.json"

exec node /app/sub-store.bundle.js