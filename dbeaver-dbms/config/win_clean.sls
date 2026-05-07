# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}
{%- set selected_edition = dbeaver_dbms.pkg.get('requested_edition', 'community') %}
{%- set install_dir = 'C:\\Program Files\\DBeaver\\' ~ selected_edition %}
{%- set appdata_root = 'C:\\Users\\Default\\AppData\\Roaming\\DBeaverData\\' ~ selected_edition %}
{%- set shortcut_targets = {
    'Desktop': 'C:\\Users\\Public\\Desktop',
    'Start Menu': 'C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs'
  }
%}

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
    - name: '{{ [pkg.driver_repo_path, selected_edition] | join("\\") | replace("\\\\", "\\") }}'
{%- endif %}

{%- for location, path in shortcut_targets.items() %}
Remove DBeaver {{ location }} Shortcut:
  file.absent:
    - name: '{{ path }}\\DBeaver {{ selected_edition|capitalize }}.lnk'
{%- endfor %}

Remove DBeaver Global Overrides:
  file.absent:
    - name: '{{ install_dir }}\\configuration\\plugin_customization.ini'
