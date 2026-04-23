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

smoke_report
