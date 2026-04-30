dbeaver-dbms-formula
==================

A SaltStack formula designed to install and configure the [dBeaver](https://dbeaver.io/) DBMS utility on installation-targets.

It is primarily expected that this formula will be run via [P3](https://www.plus3it.com/)'s "[watchmaker](https://watchmaker.readthedocs.io/en/stable/)" framework.

This formula is able to install the dBeaver DBMS on both Linux[^1] and Windows Server[^2] operating environments:

* On Linux hosts, it will install using the distro's native package-manager[^1]
* On Windows hosts, it will install using the installer-EXE[^3]

## Available states

- [dbeaver-dbms](#dbeaver-dbms)
- [dbeaver-dbms.clean](#dbeaver-dbms.clean)
- [dbeaver-dbms.package](#dbeaver-dbms.package)
- [dbeaver-dbms.package.clean](#dbeaver-dbms.package.clean)
- [dbeaver-dbms.config](#dbeaver-dbms.config)
- [dbeaver-dbms.config.clean](#dbeaver-dbms.config.clean)

### dbeaver-dbms

Executes the `package` and `config` states to install and configure the dBeaver DBMS

### dbeaver-dbms.clean

Executes the `package` and `config` states' `clean` actions to fully uninstall the dBeaver DBMS and remove previously-installed browser policy-configs (and, on Windows, associated registry entries)

### dbeaver-dbms.package

Executes _just_ the `package` state to install the dBeaver DBMS package.

### dbeaver-dbms.package.clean

Executes _just_ the `package.clean` state to uninstall the dBeaver DBMS package.

### dbeaver-dbms.config

Executes _just_ the `config` state to install/configure the dBeaver DBMS client-configuration (etc.) files

### dbeaver-dbms.config.clean

Executes _just_ the `config` state to uninstall the dBeaver DBMS client-configuration (etc.) files and, on Windows, remove any registry-keys set by prior install-runs of the formula.



[^1]: As of this README's writing, only Enterprise Linux and related distros (Red Hat and Oracle Enterprise, CentOS Stream, Rocky and Alma Linux). It has only been specifically tested with EL **_9_** variants.
[^2]: As of this README's writing, this functionality has only been tested on Windows Server 2022
[^3]: Future iterations _may_ allow the use of MSI-based installers.
