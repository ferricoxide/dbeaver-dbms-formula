# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}
{%- if grains.kernel == "Linux" %}
  - dbeaver-dbms.config.lin_file
{%- elif grains.kernel == "Windows" %}
  - dbeaver-dbms.config.win_file
  - dbeaver-dbms.config.win_driver_seeds
{%- endif %}
