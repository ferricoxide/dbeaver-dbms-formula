# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}
{%- set pkg = dbeaver_dbms.get('pkg', {}) %}
{%- set selected_edition = pkg.get(
    'requested_edition',
    dbeaver_dbms.get(
      'requested_edition',
      'community'
    )
  )
%}
{%- set driver_path = [
    pkg.get('driver_repo_path', 'C:\ProgramData\DBeaver\Drivers'),
    selected_edition
  ] | join('\\')
%}

include:
  - .win_file

{%- for driver in pkg.get('driver_seeds', []) %}
Seed DBeaver Driver - {{ driver.name }}:
  file.managed:
    - makedirs: True
    - name: {{ driver_path }}\{{ driver.name.replace('.jar', '') }}\{{ driver.name }}
    - require:
      - file: Ensure Local Driver Directory Exists
    - skip_verify: True
    - source: {{ driver.source }}
{%- endfor %}
