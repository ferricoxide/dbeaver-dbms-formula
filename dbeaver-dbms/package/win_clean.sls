# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}
{%- set selected_edition = dbeaver_dbms.pkg.get('requested_edition', 'community') %}
{%- set install_dir = 'C:\\Program Files\\DBeaver\\' ~ selected_edition %}
{%- set uninstaller = install_dir ~ '\\uninstall.exe' %}

Remove DBeaver Binary Directory:
  file.absent:
    - name: '{{ install_dir }}'
    - require:
      - cmd: 'Uninstall dBeaver EXE'

Remove DBeaver from System Path:
  win_path.absent:
    - name: '{{ install_dir }}'

Uninstall dBeaver EXE:
  cmd.run:
    - name: 'start /wait "" "{{ uninstaller }}" /S'
    - shell: cmd
    - onlyif: 'if not exist "{{ uninstaller }}" exit 1'
