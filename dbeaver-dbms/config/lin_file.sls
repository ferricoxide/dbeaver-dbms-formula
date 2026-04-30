# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set min_supported = 21 %}
{%- set latest_available = 25 %}
{%- set requested_ver = dbeaver_dbms.pkg.get('java_version', latest_available) | int %}
{%- if requested_ver < min_supported %}
    {%- set installed_jdk_ver = latest_available %}
{%- else %}
    {%- set installed_jdk_ver = requested_ver %}
{%- endif %}
{%- set ini_path_prefix = "/usr/share" %}
{%- set ini_path_end = "/dbeaver.ini" %}
{%- set ini_file_path = ini_path_prefix ~ "/" ~ dbeaver_dbms.pkg.name ~ ini_path_end %}

include:
  - {{ sls_package_install }}

Fix the dbeaver.ini file:
  file.replace:
    - name: '{{ ini_file_path }}'
    - pattern: '(?<!/bin/java\n)^-vmargs'
    - repl: |
        -vm
        /usr/lib/jvm/java-{{ installed_jdk_ver }}-openjdk/bin/java
        -vmargs
    - flags: [
        'MULTILINE'
      ]
    - backup: False
