# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}

{%- set download_uri = dbeaver_dbms.pkg.download_uri %}
{%- set sig_uri = dbeaver_dbms.pkg.get('download_sig', None) %}
{%- set staging_loc = '/tmp/dbeaver.rpm' %}

Clean-up Staged dBeaver RPM:
  file.absent:
    - name: '{{ staging_loc }}'
    - require:
      - pkg: 'Install dBeaver RPM'

Download dBeaver RPM:
  file.managed:
    - makedirs: True
    - name: '{{ staging_loc }}'
    - source: '{{ dbeaver_dbms.pkg.download_uri }}'
    {%- if sig_uri %}
    - skip_verify: False
    - source_hash: {{ sig_uri }}
    {%- else %}
    - skip_verify: True
    {%- endif %}

Install dBeaver RPM:
  pkg.installed:
    - name: '{{ dbeaver_dbms.pkg.name }}'
    - require:
      - file: 'Download dBeaver RPM'
    - sources:
      - {{ dbeaver_dbms.pkg.name }}: '{{ staging_loc }}'
    - skip_verify: True
