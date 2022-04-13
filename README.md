<div align='center'>

# dotm - Personal Dotfile Manager Utility

A comprehensive utility for managing dotfiles, using a pakcage manager like
interface.

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/LuxAter/dotm/CI?label=Tests&style=flat-square)
![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/LuxAter/dotm?label=Version&style=flat-square)
![GitHub file size in bytes](https://img.shields.io/github/size/LuxAter/dotm/dotm?label=Size&style=flat-square)

---

</div>

Dotm is a command line application that help in managing personal dotfiles
across multiple systems.

## Getting Started

### Installing

#### Automated Method (recommended)

dotm comes with a bootstraping command, that handles most of the setup for you,
so all that needs to be done is to run the command:

```shell
$ curl "https://raw.githubusercontent.com/LuxAter/dotm/main/setup" | bash
```

This command will download dotm and run it in a bootstraping mode. This will
prompt the user during the process to pick where to install the package, and
where to create the local dotfiles directory.

#### Manual

dotm consists of a single bash script so manual installation is quite simple.
Just download the `dotm` file and set it as an executable.

```shell
$ curl "https://raw.githubusercontent.com/LuxAter/dotm/main/dotm" -o dotm
$ chmod +x dotm
```

If you also want to enable completions, install the bash completions as well.
These should be installed into `$XDG_DATA_HOME/bash-completions/completions`, or
`~/.local/share/bash-completions/completions` if `$XDG_DATA_HOME` is not set.

```shell
$ curl "https://raw.githubusercontent.com/LuxAter/dotm/main/completions.bash" -o
"${XDG_DATA_HOME:-$HOME/.local/share}/bash-completions/completions/dotm.bash"
```

### Updating

#### Automated Method (recommended)

dotm provides a utility function for managing the self updating, so all that
needs to happen is to run the command:

```shell
$ dotm update
```

This will check this github repository for a newer version, and download and
replace the current version with the newer version. It also manages updating the
bash completion script if that has been installed.

#### Manual

To update manually simply follow the steps for installing, and just replace the
existing files with the new ones.
