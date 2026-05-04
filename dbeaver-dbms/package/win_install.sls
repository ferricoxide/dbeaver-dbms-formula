# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}

{#- Windows specific paths #}
{%- set temp_dir = salt['environ.get']('TEMP', 'C:\\temp') %}
{%- set staging_loc = temp_dir ~ '\\k9s_windows_amd64.zip' %}
{%- set editions = dbeaver_dbms.pkg.get('editions', {}) %}
{%- set selected_edition = dbeaver_dbms.pkg.get('requested_edition', 'community') %}
{%- set download_uri = editions.get(selected_edition, editions.community) %}
{%- set install_dir = 'C:\\Program Files\\DBeaver\\' ~ selected_edition %}

Clean-up Staged dBeaver EXE:
  file.absent:
    - name: '{{ staging_loc }}'
    - onchanges:
      - cmd: 'Install dBeaver EXE'

Download dBeaver EXE:
  file.managed:
    - name: '{{ staging_loc }}'
    - source: '{{ download_uri }}'
    - makedirs: True
    - skip_verify: True

Install dBeaver EXE:
  cmd.run:
    - name: '{{ staging_loc }} /S /allusers /D={{ install_dir }}'
    - shell: powershell
    - unless: 'Test-Path "{{ install_dir }}\\dbeaver.exe"'
    - require:
      - file: 'Download dBeaver EXE'

Update System Path for DBeaver:
  win_path.exists:
    - name: '{{ install_dir }}'
    - require:
      - cmd: 'Install dBeaver EXE'
