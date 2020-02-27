<p><img src="https://avatars1.githubusercontent.com/u/12563465?s=200&v=4" alt="OCI logo" title="oci" align="left" height="70" /></p>
<p><img src="https://www.servethehome.com/wp-content/uploads/2017/11/Redhat-logo.jpg" alt="redhat logo" title="redhat" align="right" height="70" /></p>

Container File:vertical_traffic_light:Systemd
=========
![GitHub release (latest by date)](https://img.shields.io/github/v/release/0x0I/container-file-systemd?color=yellow)
[![Build Status](https://travis-ci.org/0x0I/container-file-systemd.svg?branch=master)](https://travis-ci.org/0x0I/container-file-systemd)
[![Docker Pulls](https://img.shields.io/docker/pulls/0labs/0x01.systemd?style=flat)](https://hub.docker.com/repository/docker/0labs/0x01.systemd)
[![License: MIT](https://img.shields.io/badge/License-MIT-blueviolet.svg)](https://opensource.org/licenses/MIT)

**Table of Contents**
  - [Supported Platforms](#supported-platforms)
  - [Requirements](#requirements)
  - [Environment Variables](#environment-variables)
      - [Install](#install)
      - [Config](#config)
  - [Dependencies](#dependencies)
  - [Example Run](#example-run)
  - [License](#license)
  - [Author Information](#author-information)

Container file that installs and configures **Systemd** [units](http://man7.org/linux/man-pages/man5/systemd.unit.5.html): system components and services managed by the Linux `systemd` system/service manager.

##### Supported Platforms:
```
* Redhat(CentOS/Fedora)
* Debian
```

Requirements
------------
Requires a *Systemd* capable container runtime (e.g. [Podman](https://podman.io/)).

Environment Variables
--------------
Variables are available and organized according to the following software & machine provisioning stages:
* _install_
* _config_

#### Install

_The following variables can be customized to control various aspects of installation of individual systemd units. It is assumed that the host has a working version of the systemd package. Available versions based on OS distribution can be found [here](http://fr2.rpmfind.net/linux/rpm2html/search.php?query=systemd&submit=Search+...&system=&arch=)_.

`$SYSTEMD_PATH:` (**default**: <string> `/etc/systemd/system`)
- load path to systemd unit configuration.

  In addition to /etc/systemd/system (*default*), unit configs and associated drop-in ".d" directory overrides for system services can be placed in `/usr/lib/systemd/system` or `/run/systemd/system` directories.

  Files in **/etc** take precedence over those in **/run** which in turn take precedence over those in **/usr/lib**. Drop-in files under any of these directories take precedence over unit files wherever located. Multiple drop-in files with different names are applied in lexicographic order, regardless of which of the directories they reside in. See table below and consult **systemd(1)** for additional details regarding path load priority.

*Load paths when running in **system mode*** (--system)

| Unit Load File Path | Description |
| --- | --- |
| /etc/systemd/system | Local configuration |
| /run/systemd/system | Runtime units |
| /usr/local/lib/systemd/system | Units installed for local system administration |
| /usr/lib/systemd/system | Units of installed packages |

*Load paths when running in **user mode*** (--user)

| Unit Load File Path | Description |
| --- | --- |
| *$XDG_CONFIG_HOME*/systemd/user or *$HOME*/.config/systemd/user | User configuration (*$XDG_CONFIG_HOME* is used if set, ~/.config otherwise) |
| /etc/systemd/user | User units created by the administrator |
| *$XDG_RUNTIME_DIR*/systemd/user | Runtime units (only used when *$XDG_RUNTIME_DIR* is set) |
| /run/systemd/user | Runtime units |
| *$dir*/systemd/user for each *$dir* in *$XDG_DATA_DIRS* | Additional locations for installed user units, one for each entry in *$XDG_DATA_DIRS* |
| /usr/local/lib/systemd/user | User units installed for local system administration |
| /usr/lib/systemd/user | User units installed by the distribution package manager |

#### Example

 ```bash
 SYSTEMD_NAME=apache
 SYSTEMD_PATH=/run/systemd/system
 
 SERVICE_ExecStart=/usr/sbin/httpd
 SERVICE_ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
 
 INSTALL_WantedBy=multi-user.target
```

`$SYSTEMD_TYPE` (**default**: `service`)
- type of systemd unit to configure. There are currently 11 different unit types, ranging from daemons and the processes they consist of to path modification triggers. Consult [systemd(1)](http://man7.org/linux/man-pages/man1/systemd.1.html) for the full list of available units.

#### Example

 ```bash
 SYSTEMD_NAME=apache
 SYSTEMD_TYPE=socket
 
 SOCKET_ListenStream=0.0.0.0:8080
 SOCKET_Accept=yes
 
 INSTALL_WantedBy=sockets.target
```

#### Config

Configuration of a `systemd` unit is declared in an [ini-style](https://en.wikipedia.org/wiki/INI_file) config file. A `systemd` unit *INI* config is composed of sections: 2 common amongst all unit types (`Unit` and `Install`) and 1 specific to each unit type. These unit configurations can be expressed within the role's `unit_config` hash variable as lists of dicts containing key-value pairs representing the name, type, load path of the unit and a combination of the aforemented section definitions.

Each configuration section definition provides a dict containing a set of key-value pairs for corresponding section options (e.g. the `ExecStart` specification for a system or web service `[Service]` section or the `ListenStream` option for a web `[Socket]` section).

`{UNIT, <unit-type e.g. SERVICE, SOCKET, DEVICE>, INSTALL}_<config-key>=<config-value>` (**default**: undefined)
- section definitions for a unit configuration

Any configuration setting/value key-pair supported by the corresponding *Systemd* unit type specification should be expressible within each `envvar` and properly rendered within the associated *INI* config.

_The following provides an overview and example configuration of each unit type for reference_.

**[[Service](http://man7.org/linux/man-pages/man5/systemd.service.5.html)]**

Manages daemons and the processes they consist of.

#### Example

```bash
   SYSTEMD_NAME=example
   # SYSTEMD_PATH=/etc/systemd/system
   # SYSTEMD_TYPE=service
   
   UNIT_Description=Sleepy service
   SERVICE_ExecStart=/usr/bin/sleep infinity
   INSTALL_WantedBy=multi-user.target
 ```
 
**[[Socket](http://man7.org/linux/man-pages/man5/systemd.socket.5.html)]**

Encapsulates local IPC or network sockets in the system.

#### Example

```bash
  SYSTEMD_NAME=docker
  SYSTEM_TYPE=socket
  
  UNIT_Description=Listens/accepts connection requests at /var/run/docker/sock (implicitly *Requires=* associated docker.service)
  SOCKET_ListenStream=/var/run/docker.sock
  SOCKET_SocketMode=0660
  SOCKET_SocketUser=root
  SOCKET_SocketGroup=root
  
  INSTALL_WantedBy=sockets.target
 ```

**[[Mount](http://man7.org/linux/man-pages/man5/systemd.mount.5.html)]**

Controls mount points in the sytem.

#### Example

```bash
  SYSTEMD_NAME=tmp_new
  SYSTEM_TYPE=mount
  
  UNIT_Description=New Temporary Directory (/tmp_new)
  UNIT_Conflicts=umount.target
  UNIT_Before=local-fs.target umount.target
  UNIT_After=swap.target
  
  MOUNT_What=tmpfs
  MOUNT_Where=/tmp_new
  MOUNT_Type=tmpfs
  MOUNT_Options=mode=1777,strictatime,nosuid,nodev
 ```

**[[Automount](http://man7.org/linux/man-pages/man5/systemd.automount.5.html)]**

Provides automount capabilities for on-demand mounting of file systems as well as parallelized boot-up.

#### Example

```bash
  SYSTEMD_NAME=proc-sys-fs-binfmt_misc
  SYSTEMD_TYPE=automount
  
  UNIT_Description=Arbitrary Executable File Formats File System Automount Point
  UNIT_Documentation=https://www.kernel.org/doc/html/latest/admin-guide/binfmt-misc.html
  UNIT_ConditionPathExists=/proc/sys/fs/binfmt_misc/
  UNIT_ConditionPathIsReadWrite=/proc/sys/
  
  AUTOMOUNT_Where=/proc/sys/fs/binfmt_misc
 ```

**[[Device](http://man7.org/linux/man-pages/man5/systemd.device.5.html)]**

Exposes kernel devices and implements device-based activation.

This unit type has no specific options and as such a separate `[Device]` section does not exist. The common configuration items are configured in the generic `[Unit]` and `[Install]` sections. `systemd` will dynamically create device units for all kernel devices that are marked with the "systemd" udev tag (by default all block and network devices, and a few others). To tag a udev device, use **TAG+="systemd** in the udev rules file. Also note that device units are named after the */sys* and */dev* paths they control.

#### Example

 ```yaml
# /usr/lib/udev/rules.d/10-nvidia.rules

SUBSYSTEM=="pci", ATTRS{vendor}=="0x12d2", ATTRS{class}=="0x030000", TAG+="systemd", ENV{SYSTEMD_WANTS}="nvidia-fallback.service"

# Will result in the automatic generation of a nvidia-fallback.device file with appropriate [Unit] and [Install] sections set
```

**[[Target](http://man7.org/linux/man-pages/man5/systemd.target.5.html)]**

Provides unit organization capabilities and setting of well-known synchronization points during boot-up.

This unit type has no specific options and as such a separate `[Target]` section does not exist. The common configuration items are configured in the generic `[Unit]` and `[Install]` sections.

#### Example

```bash
  SYSTEMD_NAME=graphical
  SYSTEMD_PATH=/usr/lib/systemd/system/graphical.target
  SYSTEMD_TYPE=target
  
  UNIT_Description=Graphical Interface
  UNIT_Documentation=man:systemd.special(7)
  UNIT_Requires=multi-user.target
  UNIT_Wants=display-manager.service
  UNIT_Conflicts=rescue.service rescue.target
  UNIT_After=multi-user.target rescue.service rescue.target display-manager.service
  UNIT_AllowIsolate-yes
```

**[[Timer](http://man7.org/linux/man-pages/man5/systemd.timer.5.html)]**

Triggers activation of other units based on timers.

#### Example

```bash
  SYSTEMD_NAME=dnf-makecache
  SYSTEMD_TYPE=timer
  
  TIMER_OnBootSec=10min
  TIMER_OnUnitInactiveSec=1h
  TIMER_Unit=dnf-makecache.service
  
  INSTALL_WantedBy=multi-user.target
 ```

**[[Swap](http://man7.org/linux/man-pages/man5/systemd.swap.5.html)]**

Encapsulates memory swap partitions or files of the operating system.

#### Example

 ```yaml
  # Ensure existence of swap file
  mkdir -p /var/vm
  fallocate -l 1024m /var/vm/swapfile
  chmod 600 /var/vm/swapfile
  mkswap /var/vm/swapfile

------------------------------------

  SYSTEMD_NAME=var-vm-swap
  SYSTEM_TYPE=swap
  
  UNIT_Description=Turn on swap for /var/vm/swapfile
  SWAP_What=/var/vm/swapfile
  INSTALL_WantedBy=multi-user.target
```

**[[Path](http://man7.org/linux/man-pages/man5/systemd.path.5.html)]**

Activates other services when file system objects change or are modified.

#### Example

```bash
  SYSTEMD_NAME=Repository Code Coverage Analysis trigger
  SYSTEMD_TYPE=path
  
  UNIT_Description=Activate code coverage analysis on modified git repositories
  
  PATH_PathChanged=/path/to/git/repo
  PATH_UNIT=code-coverage-analysis
 ```

**[[Scope](http://man7.org/linux/man-pages/man5/systemd.scope.5.html)]**

Manages a set of system or foreign/remote processes.

**Scope units are not configured via unit configuration files, but are only created programmatically using the bus interfaces of systemd.** Unlike service units, scope units manage externally created processes and do not fork off processes on their own. The main purpose of scope units is grouping worker processes of a system service for organization and for managing resources.

#### Example

```bash
  SYSTEMD_NAME=user-session
  SYSTEMD_TYPE=scope
  
  UNIT_Description=Session of user
  UNIT_Wants=user-runtime-dir@1000.service user@1000.service
  UNIT_After=systemd-logind.service systemd-user-sessions.service user-runtime-dir@1000.service user@1000.service
  UNIT_RequiresMountsFor=/home/user
  
  SCOPE_SendSIGHUP=yes
  SCOPE_TasksMax=infinity
 ```

**[[Slice](http://man7.org/linux/man-pages/man5/systemd.slice.5.html)]**

Group and manage system processes in a hierarchical tree for resource management purposes.

The name of the slice encodes the location in the tree. The name consists of a dash-separated series of names, which describes the path to the slice from the root slice. By default, service and scope units are placed in system.slice, virtual machines and containers registered with systemd-machined(1) are found in machine.slice and user sessions handled by systemd-logind(1) in user.slice.

See [systemd.slice(5)](http://man7.org/linux/man-pages/man5/systemd.slice.5.html) for more details.

Dependencies
------------

None

Example Run
----------------
run a microservice:
```
podman run \
  --env SYSTEMD_NAME=example-microservice \
  --env UNIT_Description=This is an example of a microservice provisioned within a container, managed by Systemd \
  --env SERVICE_ExecStart=/app/bin/service --config /path/to/config \
  --env SERVICE_Restart=on-failure \
  --env INSTALL_WantedBy=multi-user.target \
  --volume /path/to/app/repo:/app
  0labs.0x01.systemd:centos-7 \
  systemctl start example-microservice
```

License
-------

MIT

Author Information
------------------

This Containerfile was created in 2020 by O1.IO.
