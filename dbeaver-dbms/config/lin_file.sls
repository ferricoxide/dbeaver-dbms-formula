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
{#- Define the driver path within the skeleton directory #}
{%- set skel_dbeaver_data = '/etc/skel/.local/share/DBeaverData' %}
{%- set skel_dbeaver_drivers = skel_dbeaver_data ~ '/drivers' %}
{%- set skel_settings_dir = skel_dbeaver_data ~ '/workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings' %}
{%- set pref_file = skel_settings_dir ~ '/org.jkiss.dbeaver.core.prefs' %}

include:
  - {{ sls_package_install }}

Disable DBeaver Update Checks:
  file.managed:
    - contents: |
        ui.check.update=false
    - group: root
    - mode: 0644
    - name: '{{ pref_file }}'
    - require:
      - file: Ensure DBeaver Settings Directory in Skel
    - user: root

Enable Java Execmem for dBeaver:
  selinux.boolean:
    - name: allow_execmem
    - value: True
    - persist: True

Ensure DBeaver Driver Path in Skel:
  file.directory:
    - group: root
    - makedirs: True
    - mode: 0755
    - name: '{{ skel_dbeaver_data }}'
    - user: root

Ensure DBeaver Settings Directory in Skel:
  file.directory:
    - group: root
    - makedirs: True
    - mode: 0755
    - name: '{{ skel_settings_dir }}'
    - user: root

Fix the dbeaver.ini file:
  file.replace:
    - backup: False
    - flags: [
        'MULTILINE'
      ]
    - name: '{{ ini_file_path }}'
    - pattern: '(?<!/bin/java\n)^-vmargs'
    - repl: |
        -vm
        /usr/lib/jvm/java-{{ installed_jdk_ver }}-openjdk/bin/java
        -vmargs

Link Global Drivers to Skel:
  file.symlink:
    - force: True
    - name: '{{ skel_dbeaver_drivers }}'
    - require:
      - file: Ensure DBeaver Driver Path in Skel
      - pkg: Install dBeaver RPM
    - target: '/usr/share/{{ dbeaver_dbms.pkg.name }}/drivers'

Restore SELinux Context on DBeaver Drivers:
  module.run:
    - name: file.restorecon
    - path: /usr/share/{{ dbeaver_dbms.pkg.name }}/drivers
    - recursive: True
    - require:
      - pkg: Install dBeaver RPM
