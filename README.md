# Obat
Battery notifications daemon like [bato](https://github.com/doums/bato) written in Ocaml for tiling window managers with more configuration options like upper thresholds.

<!-- TODO: Insert screenshot of notification here -->


### Features

Configuration in TOML.

Notification events:
- level full
- level sufficient
- level low
- level critical
- charging
- discharging

### Prerequisites

- a notification server, like [Dunst](https://dunst-project.org/), [mako](https://github.com/emersion/mako) etc.
- libnotify

### Setup and Usage

Clone this repo, cd into it. The binary can be executed using:
```bash
chmod +x ./_build/default/bin/main.exe
./_build/default/bin/main.exe
```

You'll need dune (Ocaml's build system) to build the project from source. cd into the repo and:
```bash
dune build --release
```

### Configuration

The binary looks for the config file `config.toml` located in `$HOME/.config/obat`, without which it will exit after throwing an exception.
<!-- TODO: Give all the options available in a blob: config.toml -->

Example configuration:
```toml
# $HOME/.config/obat/config.toml
low_threshold = 25
critical_threshold = 20
high_threshold = 85
polling_interval = 20.0
enable_hibernation = false
```
<!-- TODO: maybe create a script like the one below for usage -->
<!-- ```-->
<!-- #!/usr/bin/bash-->
<!-- -->
<!-- mapfile -t pids <<< "$(pgrep -x obat)"-->
<!-- if [ "${#pids[@]}" -gt 0 ]; then-->
<!--   for pid in "${pids[@]}"; do-->
<!--     if [ -n "$pid" ]; then-->
<!--       kill "$pid"-->
<!--     fi-->
<!--   done-->
<!-- fi-->
<!-- bato &-->
<!-- ```-->

<!-- Call this script from your window manager, _autostart_ programs.-->
