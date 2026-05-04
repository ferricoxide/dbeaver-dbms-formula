# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}

dbeaver-dbms-service-clean-service-dead:
  service.dead:
    - name: {{ dbeaver_dbms.service.name }}
    - enable: False
