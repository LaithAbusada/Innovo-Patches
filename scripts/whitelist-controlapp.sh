#!/system/bin/sh
# Whitelist the Innovo Control App for deviceidle / Doze, and force its
# standby bucket to ACTIVE.
#
# Why: Android 13 filters BOOT_COMPLETED broadcasts for apps not in the
# deviceidle whitelist when they have UPDATED_SYSTEM_APP flag (which any
# self-updated priv-app has). Whitelisting fixes the boot receiver from
# silently being dropped.
#
# Idempotent: safe to run multiple times.

PKG="com.innovo.controlapp"

echo "Adding $PKG to deviceidle whitelist..."
cmd deviceidle whitelist "+$PKG"

echo "Setting $PKG to ACTIVE standby bucket..."
am set-standby-bucket "$PKG" active

echo "Verifying..."
dumpsys deviceidle whitelist | grep "$PKG" && echo "OK: in whitelist"
echo "Standby bucket: $(am get-standby-bucket "$PKG")"