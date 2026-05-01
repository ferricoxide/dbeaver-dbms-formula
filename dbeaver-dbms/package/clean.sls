# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}

include:
  - {{ sls_config_clean }}
{%- if grains.kernel == "Linux" %}
  - .lin_clean
{%- elif grains.kernel == "Windows" %}
  - .win_clean
{%- endif %}
