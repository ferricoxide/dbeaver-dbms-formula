# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}

include:
{%- if grains.kernel == "Linux" %}
  - dbeaver-dbms.package.lin_install
{%- elif grains.kernel == "Windows" %}
  - dbeaver-dbms.package.win_install
{%- endif %}

