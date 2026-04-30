# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}

{%- set download_uri = dbeaver_dbms.pkg.download_uri %}
{%- set staging_loc = '/tmp/dbeaver.rpm' %}

Clean-up Staged dBeaver RPM:
  file.absent:
    - name: '{{ staging_loc }}'
    - require:
      - pkg: 'Install dBeaver RPM'

Download dBeaver RPM:
  file.managed:
    - name: '{{ staging_loc }}'
    - skip_verify: True
    - source: '{{ dbeaver_dbms.pkg.download_uri }}'
    - makedirs: True

Install dBeaver RPM:
  pkg.installed:
    - name: '{{ dbeaver_dbms.pkg.name }}'
    - require:
      - file: 'Download dBeaver RPM'
    - sources:
      - {{ dbeaver_dbms.pkg.name }}: '{{ staging_loc }}'
    - skip_verify: True
