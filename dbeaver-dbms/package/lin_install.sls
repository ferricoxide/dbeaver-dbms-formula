# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}

dbeaver-dbms-package-install-pkg-installed:
  pkg.installed:
    - name: {{ dbeaver_dbms.pkg.name }}
