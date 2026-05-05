# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set selected_edition = dbeaver_dbms.pkg.get('requested_edition', 'community') %}
{%- set install_dir = 'C:\\Program Files\\DBeaver\\' ~ selected_edition %}
{%- set ini_file = install_dir ~ '\\dbeaver.ini' %}

include:
  - {{ sls_package_install }}

Disable DBeaver Telemetry:
  cmd.run:
    - name: |
        $path = "{{ install_dir }}\dbeaver.ini"
        $content = Get-Content $path
        $flag = "-Dovirt.disableTelemetry=true"
        if ($content -match "-Dovirt.disableTelemetry=") {
          $content -replace "-Dovirt.disableTelemetry=.*", $flag `
          | Set-Content $path
        } else {
          Add-Content $path "`n$flag"
        }
    - require:
      - cmd: 'Install dBeaver EXE'
    - shell: powershell
    - unless: |
        $path = "{{ install_dir }}\dbeaver.ini"
        $pattern = "^-Dovirt.disableTelemetry=true$"
        if ( !( Select-String -Quiet -Pattern $pattern -Path $path ) ) {
          exit 1
        }

Modify DBeaver Memory Limit:
  file.replace:
    - name: '{{ ini_file }}'
    - pattern: '^-Xmx.*'
    - repl: '-Xmx2048m'
    - append_if_not_found: True
    - require:
      - cmd: 'Install dBeaver EXE'

Set Custom Workspace Area:
  file.replace:
    - name: '{{ install_dir }}\\dbeaver.ini'
    - pattern: '^-Dosgi.instance.area.default=.*'
    - repl: '-Dosgi.instance.area.default=@user.home/AppData/Roaming/DBeaverData/{{ selected_edition }}'
    - append_if_not_found: True
    - require:
      - cmd: 'Install dBeaver EXE'
