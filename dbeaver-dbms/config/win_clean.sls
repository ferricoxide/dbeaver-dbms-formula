# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}
{%- set selected_edition = dbeaver_dbms.pkg.get('requested_edition', 'community') %}
{%- set appdata_root = 'C:\\Users\\Default\\AppData\\Roaming\\DBeaverData\\' ~ selected_edition %}

# Remove user-profile pre-seeds
Purge DBeaver Default Profile Content:
  file.absent:
    - name: '{{ appdata_root }}'

# Clean up the registry entries
Remove DBeaver Privacy Registry:
  reg.absent:
    - name: 'HKEY_CURRENT_USER\Software\JKISS\DBeaver'

# If you seeded local drivers, nuke that repo too
{%- set pkg = dbeaver_dbms.get('pkg') or {} %}
{%- if pkg.get('driver_repo_path') %}
Purge Local Driver Repository:
  file.absent:
    - name: '{{ pkg.driver_repo_path }}\\{{ selected_edition }}'
{%- endif %}
