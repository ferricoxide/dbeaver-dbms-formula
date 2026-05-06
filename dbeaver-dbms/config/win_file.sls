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
{%- set appdata_root = 'C:\\Users\\Default\\AppData\\Roaming\\DBeaverData\\' %}
{%- set dbeaver_core_prefs = '\\General\\.plugins\\org.eclipse.core.runtime\\.settings\\org.jkiss.dbeaver.core.prefs' %}
{%- set dbeaver_roam_ui_prefs = '\\General\\.plugins\\org.eclipse.core.runtime\\.settings\\org.jkiss.dbeaver.ui.prefs' %}
{%- set eclipse_ui_prefs = '\\General\\.metadata\\.plugins\\org.eclipse.core.runtime\\.settings\\org.eclipse.ui.prefs' %}
{%- set eclipse_ui_prefs_path = appdata_root ~ selected_edition ~ eclipse_ui_prefs %}
{%- set oomph_recorder_prefs = '\\General\\.plugins\\org.eclipse.oomph.setup\\setup.recorder.prefs' %}
{%- set prefs_path = appdata_root ~ selected_edition ~ dbeaver_core_prefs %}
{%- set recorder_prefs_path = appdata_root ~ selected_edition ~ oomph_recorder_prefs %}
{%- set roam_ui_prefs_path = appdata_root ~ selected_edition ~ dbeaver_roam_ui_prefs %}
{%- set workbench_xml = '\\General\\.metadata\\.plugins\\org.eclipse.ui.workbench\\workbench.xml' %}
{%- set workbench_xml_path = appdata_root ~ selected_edition ~ workbench_xml %}
{%- set dbeaver_configs = {
    'dbeaver.statistics.receive.notified': 'true',
    'dbeaver.statistics.receive.skip': 'true',
    'eclipse.pluginCustomization': 'configuration/plugin_customization.ini',
    'osgi.instance.area.default': '@user.home/AppData/Roaming/DBeaverData/' ~ selected_edition,
    'ovirt.disableTelemetry': 'true',
    'search.eclipse.telemetry.enabled': 'false'
  }
%}
{%- set shortcut_targets = {
    'Desktop': 'C:\\Users\\Public\\Desktop',
    'Start Menu': 'C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs'
  }
%}
{%- set pkg = dbeaver_dbms.get('pkg') or {} %}
{%- set base_driver_path = pkg.get('driver_repo_path', '') %}
{%- set final_driver_path = base_driver_path ~ '\\' ~ selected_edition if base_driver_path else '' %}


include:
  - {{ sls_package_install }}

Configure DBeaver Privacy Registry:
  reg.present:
    - name: 'HKEY_CURRENT_USER\Software\JKISS\DBeaver'
    - vname: 'PrivacyAccepted'
    - vdata: 1
    - vtype: REG_DWORD
    - require:
      - cmd: 'Install dBeaver EXE'

{%- if final_driver_path %}
Configure Local Driver Repository:
  file.append:
    - name: '{{ prefs_path }}'
    - require:
      - file: 'Suppress DBeaver Telemetry Popup'
      - file: 'Ensure Local Driver Directory Exists'
    - text:
      - 'drivers.repo.external={{ final_driver_path | replace("\\", "\\\\") }}'
      - 'drivers.remote.download.enabled=false'

Ensure Local Driver Directory Exists:
  file.directory:
    - makedirs: True
    - name: '{{ final_driver_path }}'
    - require:
      - cmd: 'Install dBeaver EXE'
{%- endif %}

{%- for location, path in shortcut_targets.items() %}
Create DBeaver {{ location }} Shortcut:
  shortcut.present:
    - force: True
    - icon_index: 0
    - icon_location: '{{ install_dir }}\\dbeaver.exe'
    - name: '{{ path }}\\DBeaver {{ selected_edition|capitalize }}.lnk'
    - require:
      - cmd: 'Install dBeaver EXE'
    - target: '{{ install_dir }}\\dbeaver.exe'
    - working_dir: '{{ install_dir }}'
{%- endfor %}

Disable Eclipse Oomph Setup:
  file.managed:
    - contents: |
        eclipse.preferences.version=1
        enabled=false
    - encoding: ascii
    - makedirs: True
    - name: '{{ recorder_prefs_path }}'
    - require:
      - file: 'Suppress DBeaver Telemetry Popup'
      - file: 'Suppress DBeaver UI Consent'
    - win_line_endings: True

Force Workbench Initialized:
  file.managed:
    - name: 'C:\\Users\\Default\\AppData\\Roaming\\DBeaverData\\{{ selected_edition }}\\General\\.metadata\\.plugins\\org.eclipse.ui.workbench\\workbench.xml'
    - makedirs: True
    - contents: |
        <?xml version="1.0" encoding="UTF-8"?>
        <workbench version="2.0">
          <activePerspectiveId value="org.jkiss.dbeaver.core.perspective"/>
        </workbench>
    - require:
      - file: 'Set Metadata Version Marker'
      - file: 'Set Workspace Version Marker'
    - win_line_endings: True

Global DBeaver Preference Override:
  file.managed:
    - contents: |
        org.jkiss.dbeaver.core/statistics.receive.send=false
        org.jkiss.dbeaver.core/statistics.receive.skip=true
        org.jkiss.dbeaver.ui/ui.statistics.keepUpdated=false
        org.jkiss.dbeaver.ui/ui.statistics.notified=true
    - makedirs: True
    - name: '{{ install_dir }}\\configuration\\plugin_customization.ini'
    - require:
      - cmd: 'Install dBeaver EXE'

{%- for key, value in dbeaver_configs.items() %}
Manage DBeaver Setting {{ key }}:
  file.keyvalue:
    - name: '{{ ini_file }}'
    - key: '-D{{ key }}'
    - value: '{{ value }}'
    - separator: '='
    - append_if_not_found: True
    - require:
      - cmd: 'Install dBeaver EXE'
{%- endfor %}

Modify DBeaver Memory Limit:
  file.replace:
    - append_if_not_found: False
    - name: '{{ ini_file }}'
    - pattern: '^-Xmx.*'
    - repl: '-Xmx2048m'
    - require:
      - cmd: 'Install dBeaver EXE'

Pre-initialize DBeaver Workspace:
  file.managed:
    - contents: |
        eclipse.preferences.version=1
        SHOW_TEXT_ON_PERSPECTIVE_BAR=false
        newWorkbench=false
        ui.statistics.notified=true
    - encoding: ascii
    - makedirs: True
    - name: '{{ eclipse_ui_prefs_path }}'
    - require:
      - file: 'Force Workbench Initialized'
    - win_line_endings: True

Set Metadata Version Marker:
  file.managed:
    - name: '{{ appdata_root }}{{ selected_edition }}\\General\\.metadata\\.version'
    - makedirs: True
    - contents: '2'
    - require:
      - cmd: 'Install dBeaver EXE'

Set Workspace Version Marker:
  file.managed:
    - contents: |
        org.eclipse.core.runtime=1
    - makedirs: True
    - name: '{{ appdata_root }}{{ selected_edition }}\\General\\.metadata\\version.ini'
    - require:
      - file: 'Global DBeaver Preference Override'
      - file: 'Set Metadata Version Marker'
    - win_line_endings: True

Suppress DBeaver Telemetry Popup:
  file.managed:
    - contents: |
        eclipse.preferences.version=1
        org.jkiss.dbeaver.core/privacy.policy.accepted=true
        org.jkiss.dbeaver.core/privacy.view.count=1
        org.jkiss.dbeaver.ui/ui.privacy.accepted=true
        statistics.receive.send=false
        statistics.receive.skip=true
    - encoding: ascii
    - makedirs: True
    - name: '{{ prefs_path }}'
    - require:
      - file: 'Set Workspace Version Marker'
      - file: 'Force Workbench Initialized'
    - win_line_endings: True

Suppress DBeaver UI Consent:
  file.managed:
    - contents: |
        eclipse.preferences.version=1
        ui.statistics.keepUpdated=false
        # This is often the specific flag the UI checks to see if it should nag
        ui.statistics.notified=true
    - encoding: ascii
    - makedirs: True
    - name: '{{ roam_ui_prefs_path }}'
    - require:
      - file: 'Set Workspace Version Marker'
      - file: 'Force Workbench Initialized'
    - win_line_endings: True
