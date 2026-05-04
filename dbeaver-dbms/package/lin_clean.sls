# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}

# Only remove packages that are highly likely to be "leaf" nodes added
# specifically for this GUI. Core libs, like libsecret and libXtst, that
# may have been added via this project's "install" contents are omitted to
# prevent breaking other system tools.
Cleanup DBeaver Specific Dependencies:
  pkg.removed:
    - pkgs:
      - liberation-mono-fonts
      - webkit2gtk3

Uninstall dBeaver RPM:
  pkg.removed:
    - name: {{ dbeaver_dbms.pkg.name }}
