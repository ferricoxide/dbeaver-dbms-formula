# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set selected_edition = dbeaver_dbms.pkg.get('requested_edition', 'community') %}
{%- set install_dir = 'C:\\Program Files\\DBeaver\\' ~ selected_edition %}
{%- set ini_file = install_dir ~ '\\dbeaver.ini' %}
{%- set appdata_root = 'C:\\Users\\Default\\AppData\\Roaming\\DBeaverData\\' %}
{%- set appdata_suffix = '\\General\\.plugins\\org.eclipse.core.runtime\\.settings\\org.jkiss.dbeaver.core.prefs' %}
{%- set prefs_path = appdata_root ~ selected_edition ~ appdata_suffix %}
{%- set dbeaver_configs = {
    'ovirt.disableTelemetry': 'true',
    'osgi.instance.area.default': '@user.home/AppData/Roaming/DBeaverData/' ~ selected_edition,
    'search.eclipse.telemetry.enabled': 'false'
  }
%}
{%- set shortcut_targets = {
    'Desktop': 'C:\\Users\\Public\\Desktop',
    'Start Menu': 'C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs'
  }
%}


include:
  - {{ sls_package_install }}

{%- for location, path in shortcut_targets.items() %}
Create DBeaver {{ location }} Shortcut:
  shortcut.present:
    - force: True
    - icon_index: 0
    - icon_location: '{{ install_dir }}\\dbeaver.exe'
    - name: '{{ path }}\\DBeaver {{ selected_edition|capitalize }}.lnk'
    - require:
      - cmd: 'Install dBeaver EXE'
    - target: '{{ install_dir }}\\dbeaver.exe'
    - working_dir: '{{ install_dir }}'
{%- endfor %}

{%- for key, value in dbeaver_configs.items() %}
Manage DBeaver Setting {{ key }}:
  file.keyvalue:
    - name: '{{ ini_file }}'
    - key: '-D{{ key }}'
    - value: '{{ value }}'
    - separator: '='
    - append_if_not_found: True
    - require:
      - cmd: 'Install dBeaver EXE'
{%- endfor %}

Modify DBeaver Memory Limit:
  file.replace:
    - append_if_not_found: False
    - name: '{{ ini_file }}'
    - pattern: '^-Xmx.*'
    - repl: '-Xmx2048m'
    - require:
      - cmd: 'Install dBeaver EXE'

Suppress DBeaver Telemetry Popup:
  file.managed:
    - contents: |
        statistics.receive.send=false
        statistics.receive.skip=true
    - makedirs: True
    - name: '{{ prefs_path }}'
    - require:
      - cmd: 'Install dBeaver EXE'
