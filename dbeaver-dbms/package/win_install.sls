# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}

{#- Windows specific paths #}
{%- set temp_dir = salt['environ.get']('TEMP', 'C:\\temp') %}
{%- set staging_loc = temp_dir ~ '\\dbeaver-setup.exe' %}
{%- set editions = dbeaver_dbms.pkg.get('editions', {}) %}
{%- set selected_edition = dbeaver_dbms.pkg.get('requested_edition', 'community') %}
{%- set download_uri = editions.get(
    selected_edition, editions.get(
      'community',
      'https://dbeaver.io/files/dbeaver-ce-latest-x86_64-setup.exe'
    )
  )
%}
{%- set install_dir = 'C:\\Program Files\\DBeaver\\' ~ selected_edition %}

Clean-up Staged dBeaver EXE:
  file.absent:
    - onchanges:
      - cmd: 'Install dBeaver EXE'
    - name: '{{ staging_loc }}'

Download dBeaver EXE:
  file.managed:
    - name: '{{ staging_loc }}'
    - makedirs: True
    - skip_verify: True
    - source: '{{ download_uri }}'

Install dBeaver EXE:
  cmd.run:
    - name: '{{ staging_loc }} /S /allusers /D={{ install_dir }}'
    - require:
      - file: 'Download dBeaver EXE'
    - shell: powershell
    - unless: 'exit !( Test-Path "{{ install_dir }}\\dbeaver.exe" )'

Update System Path for DBeaver:
  win_path.exists:
    - name: '{{ install_dir }}'
    - require:
      - cmd: 'Install dBeaver EXE'
