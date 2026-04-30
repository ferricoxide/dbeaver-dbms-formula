# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as dbeaver_dbms with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

dbeaver-dbms-config-file-file-managed:
  file.managed:
    - name: {{ dbeaver_dbms.config }}
    - source: {{ files_switch(['example.tmpl'],
                              lookup='dbeaver-dbms-config-file-file-managed'
                 )
              }}
    - mode: 644
    - user: root
    - group: {{ dbeaver_dbms.rootgroup }}
    - makedirs: True
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        dbeaver_dbms: {{ dbeaver_dbms | json }}
