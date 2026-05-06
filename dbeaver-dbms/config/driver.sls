# -*- coding: utf-8 -*-
# vim: ft=sls

{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}
{%- set pkg = dbeaver_dbms.get('pkg', {}) %}
{%- set driver_path = [
    pkg.get('driver_repo_path',
    'C:\ProgramData\DBeaver\Drivers'),
    dbeaver_dbms.get('requested_edition', 'community')
  ] | join('\\')
%}

include:
  - .win_file

{%- for driver in pkg.get('driver_seeds', []) %}
Seed DBeaver Driver - {{ driver.name }}:
  file.managed:
    - name: {{ driver_path }}\{{ driver.name }}
    - source: {{ driver.source }}
    - skip_verify: True
    - makedirs: True
    - require:
      - file: Ensure Local Driver Directory Exists
{%- endfor %}
