package image

// AppDef describes a well-known application image in terms of its base
// distro image, the packages to install, and optional post-install commands.
type AppDef struct {
	// Base is the distro image:tag to clone from, e.g. "debian:bookworm".
	Base string
	// Packages is the list of packages to install via the distro's package
	// manager after the base container is created.
	Packages []string
	// PostInstall is an optional shell snippet run inside the container after
	// packages are installed (cleanup, config, etc.).
	PostInstall string
	// DefaultCmd is the command set as lxc.init.cmd when no Cmd is specified.
	DefaultCmd string
}

// knownApps maps Docker Hub image names to their AppDef. Only the image name
// (without tag) is used as the key; tag differences within the same app are
// not tracked at this layer.
var knownApps = map[string]AppDef{
	"nginx": {
		Base:        "debian:bookworm",
		Packages:    []string{"nginx"},
		PostInstall: "rm -rf /var/lib/apt/lists/*",
		DefaultCmd:  "nginx -g 'daemon off;'",
	},
	"redis": {
		Base:        "debian:bookworm",
		Packages:    []string{"redis-server"},
		PostInstall: "rm -rf /var/lib/apt/lists/*",
		DefaultCmd:  "redis-server",
	},
	"postgres": {
		Base:     "debian:bookworm",
		Packages: []string{"postgresql"},
		PostInstall: `rm -rf /var/lib/apt/lists/* && ` +
			`mkdir -p /var/run/postgresql && ` +
			`chown postgres:postgres /var/run/postgresql`,
		DefaultCmd: "postgres",
	},
	"mysql": {
		Base:        "debian:bookworm",
		Packages:    []string{"default-mysql-server"},
		PostInstall: "rm -rf /var/lib/apt/lists/*",
		DefaultCmd:  "mysqld",
	},
	"mariadb": {
		Base:        "debian:bookworm",
		Packages:    []string{"mariadb-server"},
		PostInstall: "rm -rf /var/lib/apt/lists/*",
		DefaultCmd:  "mariadbd",
	},
	"node": {
		Base:        "debian:bookworm",
		Packages:    []string{"nodejs", "npm"},
		PostInstall: "rm -rf /var/lib/apt/lists/*",
		DefaultCmd:  "node",
	},
	"python": {
		Base:        "debian:bookworm",
		Packages:    []string{"python3", "python3-pip"},
		PostInstall: "rm -rf /var/lib/apt/lists/*",
		DefaultCmd:  "python3",
	},
	"php": {
		Base:        "debian:bookworm",
		Packages:    []string{"php-cli", "php-fpm"},
		PostInstall: "rm -rf /var/lib/apt/lists/*",
		DefaultCmd:  "php-fpm8.2 -F",
	},
	"memcached": {
		Base:        "debian:bookworm",
		Packages:    []string{"memcached"},
		PostInstall: "rm -rf /var/lib/apt/lists/*",
		DefaultCmd:  "memcached",
	},
	"rabbitmq": {
		Base:        "debian:bookworm",
		Packages:    []string{"rabbitmq-server"},
		PostInstall: "rm -rf /var/lib/apt/lists/*",
		DefaultCmd:  "rabbitmq-server",
	},
	"haproxy": {
		Base:        "debian:bookworm",
		Packages:    []string{"haproxy"},
		PostInstall: "rm -rf /var/lib/apt/lists/*",
		DefaultCmd:  "haproxy -f /etc/haproxy/haproxy.cfg",
	},
	"caddy": {
		Base:     "debian:bookworm",
		Packages: []string{"debian-keyring", "debian-archive-keyring", "apt-transport-https", "curl"},
		PostInstall: `curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | ` +
			`gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg && ` +
			`curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | ` +
			`tee /etc/apt/sources.list.d/caddy-stable.list && ` +
			`apt-get update && apt-get install -y caddy && ` +
			`rm -rf /var/lib/apt/lists/*`,
		DefaultCmd: "caddy run --config /etc/caddy/Caddyfile",
	},
	// Games-on-Whales specific
	"sunshine": {
		Base:     "ubuntu:22.04",
		Packages: []string{},
		PostInstall: `apt-get update && ` +
			`apt-get install -y curl && ` +
			`rm -rf /var/lib/apt/lists/*`,
		DefaultCmd: "sunshine",
	},
}

// lookupApp returns the AppDef for a given image name, and whether it was found.
func lookupApp(name string) (AppDef, bool) {
	def, ok := knownApps[name]
	return def, ok
}
