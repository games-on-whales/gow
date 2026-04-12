package lxc

import (
	"golang.org/x/sys/unix"
)

type syscallStat struct {
	major int64
	minor int64
}

func syscallStatDevice(path string, out *syscallStat) error {
	var st unix.Stat_t
	if err := unix.Stat(path, &st); err != nil {
		return err
	}
	out.major = int64(unix.Major(st.Rdev))
	out.minor = int64(unix.Minor(st.Rdev))
	return nil
}
