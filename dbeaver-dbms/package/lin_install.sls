# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}

{%- set download_uri = dbeaver_dbms.pkg.download_uri %}
{%- set sig_uri = dbeaver_dbms.pkg.get('download_sig', None) %}
{%- set staging_loc = '/tmp/dbeaver.rpm' %}
{%- set java_pkg_prefix = "java-" %}
{%- set java_pkg_suffix = "-openjdk" %}
{%- set min_supported = 21 %}
{%- set latest_available = 25 %}
{#- Determine requested version from Pillar, defaulting to latest #}
{%- set requested_ver = dbeaver_dbms.get('java_version', latest_available) | int %}
{%- set install_ver = requested_ver %}
{%- set ignore_reason = "" %}

{#- Enforcement Logic #}
{%- if requested_ver < min_supported %}
    {%- set install_ver = latest_available %}
    {%- set ignore_reason = "Pillar requested Java " ~ requested_ver ~ ", but dBeaver requires >= " ~ min_supported ~ ". Installing Java " ~ latest_available ~ " instead." %}
{%- endif %}

Clean-up Staged dBeaver RPM:
  file.absent:
    - name: '{{ staging_loc }}'
    - require:
      - pkg: 'Install dBeaver RPM'

Download dBeaver RPM:
  file.managed:
    - makedirs: True
    - name: '{{ staging_loc }}'
    - require:
      - pkg: 'Install OpenJDK for dBeaver'
    {%- if sig_uri %}
    - skip_verify: False
    - source_hash: {{ sig_uri }}
    {%- else %}
    - skip_verify: True
    {%- endif %}
    - source: '{{ dbeaver_dbms.pkg.download_uri }}'

Install OpenJDK for dBeaver:
  pkg.installed:
    - name: {{ java_pkg_prefix ~ install_ver ~ java_pkg_suffix }}
    - require:
      - pkg: 'Install non-enumerated DBeaver GUI Dependencies'

Install dBeaver RPM:
  pkg.installed:
    - name: '{{ dbeaver_dbms.pkg.name }}'
    - require:
      - file: 'Download dBeaver RPM'
    - skip_verify: True
    - sources:
      - {{ dbeaver_dbms.pkg.name }}: '{{ staging_loc }}'

Install non-enumerated DBeaver GUI Dependencies:
  pkg.installed:
    - pkgs:
      - webkit2gtk3
      - libsecret
      - libXtst
    - require_in:
      - pkg: 'Install dBeaver RPM'

{%- if ignore_reason %}
Notify Java Version Override:
  test.show_notification:
    - require_in:
      - pkg: Install OpenJDK for dBeaver
    - text: |
        {{ ignore_reason }}
{%- endif %}
