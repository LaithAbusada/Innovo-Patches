#!/system/bin/sh
#
# fix-timezone.sh
# Single-shot timezone auto-detection fix for InnovoP4 panels.
# Self-contained — DEX helper is embedded as base64.
#
# What this does:
#   1. Extracts a small DEX helper that queries IP geolocation APIs
#   2. Detects the panel's timezone from its public IP address
#   3. Applies workarounds for outdated tzdata (2022a)
#   4. Sets the timezone and broadcasts the change to all apps
#
# Usage (on-device):
#   sh /data/local/tmp/fix-timezone.sh
#
# Usage (from host via ADB):
#   adb push fix-timezone.sh /data/local/tmp/
#   adb shell sh /data/local/tmp/fix-timezone.sh
#
# Idempotent — safe to run multiple times or at every boot.
#

# ── Embedded DEX (tz-lookup.dex, base64-encoded, ~2.3KB) ────────────────────
TZ_DEX_B64="ZGV4CjAzNQBIjwvkXCm288Z4x+dXPjFkKo0qOPPZ+PYECQAAcAAAAHhWNBIAAAAAAAAAAEwIAAA0AAAAcAAAABIAAABAAQAADAAAAIgBAAAEAAAAGAIAABQAAAA4AgAAAQAAANgCAAAMBgAA+AIAAJoEAACdBAAAoAQAAKoEAACyBAAA5AQAAOcEAAD+BAAAAQUAAA0FAAAnBQAAPgUAAFsFAAByBQAAhAUAAJ4FAAC1BQAAyQUAAN0FAADxBQAADwYAAB8GAAA5BgAARQYAAE4GAABdBgAAaQYAAGwGAABwBgAAdAYAAHkGAAB8BgAAgAYAAJUGAACcBgAApgYAALIGAAC3BgAAvQYAAM0GAADeBgAABwcAACMHAAApBwAAOQcAAD4HAABHBwAAUQcAAGQHAAB0BwAAiAcAAI4HAAAFAAAACAAAAAkAAAAKAAAACwAAAAwAAAANAAAADgAAAA8AAAAQAAAAEQAAABIAAAATAAAAFAAAABUAAAAaAAAAHgAAACAAAAAFAAAAAAAAAAAAAAAHAAAAAwAAAAAAAAAHAAAACgAAAAAAAAAHAAAADgAAAAAAAAAaAAAADwAAAAAAAAAbAAAADwAAAGQEAAAcAAAADwAAAGwEAAAcAAAADwAAAHQEAAAcAAAADwAAAHwEAAAdAAAADwAAAIQEAAAcAAAADwAAAIwEAAAfAAAAEAAAAJQEAAABAAAAFgAAAAEAEQAXAAAACwAFACQAAAALAAUALAAAAAEABAACAAAAAQAEAAMAAAABAAoAKgAAAAIABwADAAAAAgAEACEAAAACAAIALgAAAAQABgADAAAABQAIAC0AAAAJAAQAAwAAAAoACwAiAAAACgACADIAAAALAAUAJQAAAAwABAAjAAAADAABACYAAAAMAAAAJwAAAAwABQAvAAAADAAFADAAAAAMAAkAMQAAAA0ACAADAAAADQADACsAAAABAAAAAQAAAAkAAAAAAAAAGAAAAAAAAAAsCAAARAgAAAMAAAAAAAAAPAQAABAAAAASICMAEQASARoCKABNAgABEhEaAikATQIAAWkAAQAOAAEAAQABAAAAQAQAAAQAAABwEAgAAAAOAAcAAQADAAEARAQAAG8AAABiBgEAIWASATUBXwBGAgYBIgMNAHAgEgAjAG4QEwADAAwCHwIMABMDECduIA8AMgBuIBAAMgAaAxkAGgQGAG4wEQAyBG4QDgACAAoDEwTIADNDMwAiAwIAIgQEAG4QDQACAAwFcCAGAFQAcCADAEMAbhAFAAMADARuEAQAAwA4BBwAGgMAAG4gCQA0AAoDOAMUABoDAQBuIAkANAAKAzkDDABiAgMAbhAKAAQADANuIAcAMgAOAG4QDAACACgCDQLYAQEBKKJiBgIAGgAEAG4gBwAGABIWcRALAAYADgAAAAgAAABWAAEAAQEIXwwADgALAA4AEwEADoi0Wjx4h0ulSzwBEg+WID4bAm8dAhU7eEsAAAABAAAAAAAAAAEAAAADAAAAAQAAAAYAAAABAAAACgAAAAIAAAAKAAoAAQAAABEAAAABAAAABwABLwABPAAIPGNsaW5pdD4ABjxpbml0PgAwRVJST1I6IENvdWxkIG5vdCBkZXRlcm1pbmUgdGltZXpvbmUgZnJvbSBhbnkgQVBJAAFJABVJbm5vdm9QNC1Uekxvb2t1cC8xLjAAAUwACkxUekxvb2t1cDsAGExqYXZhL2lvL0J1ZmZlcmVkUmVhZGVyOwAVTGphdmEvaW8vSW5wdXRTdHJlYW07ABtMamF2YS9pby9JbnB1dFN0cmVhbVJlYWRlcjsAFUxqYXZhL2lvL1ByaW50U3RyZWFtOwAQTGphdmEvaW8vUmVhZGVyOwAYTGphdmEvbGFuZy9DaGFyU2VxdWVuY2U7ABVMamF2YS9sYW5nL0V4Y2VwdGlvbjsAEkxqYXZhL2xhbmcvT2JqZWN0OwASTGphdmEvbGFuZy9TdHJpbmc7ABJMamF2YS9sYW5nL1N5c3RlbTsAHExqYXZhL25ldC9IdHRwVVJMQ29ubmVjdGlvbjsADkxqYXZhL25ldC9VUkw7ABhMamF2YS9uZXQvVVJMQ29ubmVjdGlvbjsAClRJTUVPVVRfTVMAB1RaX0FQSVMADVR6TG9va3VwLmphdmEAClVzZXItQWdlbnQAAVYAAlZJAAJWTAADVkxMAAFaAAJaTAATW0xqYXZhL2xhbmcvU3RyaW5nOwAFY2xvc2UACGNvbnRhaW5zAApkaXNjb25uZWN0AANlcnIABGV4aXQADmdldElucHV0U3RyZWFtAA9nZXRSZXNwb25zZUNvZGUAJ2h0dHA6Ly9pcC1hcGkuY29tL2xpbmUvP2ZpZWxkcz10aW1lem9uZQAaaHR0cHM6Ly9pcGluZm8uaW8vdGltZXpvbmUABG1haW4ADm9wZW5Db25uZWN0aW9uAANvdXQAB3ByaW50bG4ACHJlYWRMaW5lABFzZXRDb25uZWN0VGltZW91dAAOc2V0UmVhZFRpbWVvdXQAEnNldFJlcXVlc3RQcm9wZXJ0eQAEdHJpbQCbAX5+RDh7ImJhY2tlbmQiOiJkZXgiLCJjb21waWxhdGlvbi1tb2RlIjoiZGVidWciLCJoYXMtY2hlY2tzdW1zIjpmYWxzZSwibWluLWFwaSI6MSwic2hhLTEiOiJhYmFhYjQ2OWI1ZWJkNGRkMmJiOTFiYTBlZDZmNDUyNzdmYWFlNGNhIiwidmVyc2lvbiI6IjguNi4yLWRldiJ9AAIAAwAAGgEaAIiABPgFAYGABKgGAQnABgEkECcAAAAADwAAAAAAAAABAAAAAAAAAAEAAAA0AAAAcAAAAAIAAAASAAAAQAEAAAMAAAAMAAAAiAEAAAQAAAAEAAAAGAIAAAUAAAAUAAAAOAIAAAYAAAABAAAA2AIAAAEgAAADAAAA+AIAAAMgAAADAAAAPAQAAAEQAAAHAAAAZAQAAAIgAAA0AAAAmgQAAAAgAAABAAAALAgAAAUgAAABAAAARAgAAAMQAAABAAAASAgAAAAQAAABAAAATAgAAA=="

# ── Configuration ────────────────────────────────────────────────────────────
DEX_PATH="/data/local/tmp/_tz_lookup.dex"
LOG_TAG="TzAutoSet"
MAX_RETRIES=3
RETRY_DELAY=10

# Workaround for outdated tzdata (2022a) on InnovoP4 panels.
# Jordan moved to permanent UTC+3 in late 2022, but tzdata 2022a
# still treats Asia/Amman as UTC+2 with DST. Map to equivalent
# timezones that are always UTC+3 on this old tzdata.
TZDATA_FIXUPS="Asia/Amman=Asia/Baghdad"

# ── Helpers ──────────────────────────────────────────────────────────────────
logmsg() { /system/bin/log -t "$LOG_TAG" -p i "$*" 2>/dev/null; echo "[TZ] $*"; }
errmsg() { /system/bin/log -t "$LOG_TAG" -p e "$*" 2>/dev/null; echo "[TZ] ERROR: $*" >&2; }

# Wait for network connectivity (at boot, network may not be up yet)
wait_for_network() {
    local attempts=0
    while [ $attempts -lt 30 ]; do
        if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
            return 0
        fi
        attempts=$((attempts + 1))
        sleep 2
    done
    return 1
}

# Look up timezone from IP using the embedded DEX helper
lookup_timezone() {
    if [ ! -f "$DEX_PATH" ]; then
        errmsg "DEX file not found at $DEX_PATH"
        return 1
    fi

    local tz
    tz=$(CLASSPATH="$DEX_PATH" app_process /system/bin TzLookup 2>/dev/null)

    if [ -z "$tz" ]; then
        return 1
    fi

    # Validate: must contain a slash (IANA format like Region/City)
    case "$tz" in
        */*)  echo "$tz"; return 0 ;;
        *)    errmsg "Invalid timezone format: $tz"; return 1 ;;
    esac
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
    logmsg "Starting timezone auto-detection..."

    # Extract embedded DEX
    echo "$TZ_DEX_B64" | base64 -d > "$DEX_PATH" 2>/dev/null
    if [ ! -f "$DEX_PATH" ]; then
        errmsg "Failed to extract DEX helper"
        exit 1
    fi

    # Check current timezone
    current_tz=$(getprop persist.sys.timezone)
    logmsg "Current timezone: $current_tz"

    # Wait for network
    if ! wait_for_network; then
        errmsg "No network connectivity after 60s. Keeping timezone: $current_tz"
        rm -f "$DEX_PATH"
        exit 1
    fi
    logmsg "Network is up."

    # Try to detect timezone with retries
    local attempt=0
    local detected_tz=""
    while [ $attempt -lt $MAX_RETRIES ]; do
        attempt=$((attempt + 1))
        detected_tz=$(lookup_timezone)
        if [ -n "$detected_tz" ]; then
            break
        fi
        logmsg "Attempt $attempt/$MAX_RETRIES failed, retrying in ${RETRY_DELAY}s..."
        sleep "$RETRY_DELAY"
    done

    # Clean up extracted DEX
    rm -f "$DEX_PATH"

    if [ -z "$detected_tz" ]; then
        errmsg "Could not detect timezone after $MAX_RETRIES attempts. Keeping: $current_tz"
        exit 1
    fi

    logmsg "Detected timezone: $detected_tz"

    # Apply tzdata fixups for outdated timezone databases
    local final_tz="$detected_tz"
    for fixup in $TZDATA_FIXUPS; do
        local from="${fixup%%=*}"
        local to="${fixup##*=}"
        if [ "$detected_tz" = "$from" ]; then
            logmsg "Applying tzdata fixup: $from -> $to (outdated tzdata workaround)"
            final_tz="$to"
            break
        fi
    done

    # Set timezone if different
    if [ "$current_tz" = "$final_tz" ]; then
        logmsg "Timezone already correct: $final_tz"
        exit 0
    fi

    logmsg "Changing timezone: $current_tz -> $final_tz"
    setprop persist.sys.timezone "$final_tz"

    # Broadcast timezone change to notify all apps (screensaver, clocks, etc.)
    am broadcast -a android.intent.action.TIMEZONE_CHANGED \
        --es time-zone "$final_tz" >/dev/null 2>&1

    # Also notify the system via the time_zone_detector
    cmd time_zone_detector suggest_manual_time_zone \
        --zone_id "$final_tz" \
        --quality single \
        --elapsed_realtime "$(date +%s)000" >/dev/null 2>&1

    # Verify
    new_tz=$(getprop persist.sys.timezone)
    if [ "$new_tz" = "$final_tz" ]; then
        logmsg "Timezone set successfully: $final_tz (detected: $detected_tz)"
    else
        errmsg "Failed to verify timezone change (expected $final_tz, got $new_tz)"
        exit 1
    fi
}

main
