#!/usr/bin/env bash
# Prism Launcher is shipped as a portable tarball extracted to
# /opt/prismlauncher, with a symlink to /usr/local/bin. The symlink is what
# startup.sh calls -- verify both.

source /smoke-common/lib.sh

assert_has prismlauncher

assert_path /opt/prismlauncher \
            /opt/prismlauncher/PrismLauncher \
            /opt/prismlauncher/bin/prismlauncher

if [[ -L /usr/local/bin/prismlauncher ]]; then
  ok "/usr/local/bin/prismlauncher is a symlink"
else
  bad "/usr/local/bin/prismlauncher is a symlink"
fi

assert_shared_ok /opt/prismlauncher/bin/prismlauncher
assert_version prismlauncher --version

# Minecraft skips any resource pack whose file name has a non-ASCII byte
# unless the JVM maps paths as UTF-8, which it derives from LANG at startup.
jnu_encoding=$(java -XshowSettings:properties -version 2>&1 | awk '/sun.jnu.encoding/ {print $3}')
if [[ "$jnu_encoding" == "UTF-8" ]]; then
  ok "JVM path encoding is UTF-8 (sun.jnu.encoding=$jnu_encoding)"
else
  bad "JVM path encoding is UTF-8 (sun.jnu.encoding=${jnu_encoding:-unset})"
fi

smoke_report
