{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import centrifugo as c %}

{%- if c.install %}
  {#- Install systemd service file #}
  {%- if grains.init == 'systemd' %}
include:
  - {{ tplroot }}.service

centrifugo_service_install_systemd_unit:
  file.managed:
    - name: {{ salt['file.join'](c.service.systemd.unit_dir,c.service.name ~ '.service') }}
    - source: salt://{{ tplroot }}/files/centrifugo.service.jinja
    - user: {{ c.root_user }}
    - group: {{ c.root_group }}
    - mode: 644
    - template: jinja
    - context:
        tplroot: {{ tplroot }}
    - require_in:
      - sls: {{ tplroot }}.service
    - watch_in:
      - module: centrifugo_service_install_reload_systemd

    {#- Reload systemd after new unit file added, like `systemctl daemon-reload` #}
centrifugo_service_install_reload_systemd:
  module.wait:
    {#- Workaround for deprecated `module.run` syntax, subject to change in Salt 3005 #}
    {%- if 'module.run' in salt['config.get']('use_superseded', [])
    or grains['saltversioninfo'] >= [3005] %}
    - service.systemctl_reload: {}
    {%- else %}
    - name: service.systemctl_reload
    {%- endif %}
    - require_in:
      - sls: {{ tplroot }}.service

  {%- else %}
centrifugo_service_install_warning:
  test.configurable_test_state:
    - name: centrifugo_service_install
    - changes: false
    - result: false
    - comment: |
        Your OS init system is {{ grains.init }}, currently only systemd init system is supported.
        Service for Centrifugo is not installed.

  {%- endif %}

{#- Centrifugo is not selected for installation #}
{%- else %}
centrifugo_service_install_notice:
  test.show_notification:
    - name: centrifugo_service_install
    - text: |
        Centrifugo is not selected for installation, current value
        for 'centrifugo:install': {{ c.install|string|lower }}, if you want to install Centrifugo
        you need to set it to 'true'.

{%- endif %}
