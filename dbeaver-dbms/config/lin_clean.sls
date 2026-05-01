# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}

{#- Paths mirrored from lin_file.sls #}
{%- set skel_dbeaver_data = '/etc/skel/.local/share/DBeaverData' %}

Remove DBeaver Skeleton Configuration:
  file.absent:
    - name: {{ skel_dbeaver_data }}

Remove DBeaver Symlink from PATH:
  file.absent:
    - name: /usr/local/bin/dbeaver

Update Desktop Database after Config Removal:
  cmd.run:
    - name: update-desktop-database /usr/share/applications
    - onlyif: 'which update-desktop-database'
