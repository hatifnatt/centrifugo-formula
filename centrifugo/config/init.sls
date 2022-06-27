{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import centrifugo as c %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}
{%- set conf_dir = salt['file.dirname'](c.config.file) -%}

{%- if c.install %}
  {#- Manage Centrifugo configuration #}
include:
  - {{ tplroot }}.install
  - {{ tplroot }}.service

  {#- Create parameters / environment file #}
centrifugo_config_env_file:
  file.managed:
    - name: {{ c.env.file }}
    - source: salt://{{ tplroot }}/files/env_file.jinja
    - template: jinja
    - context:
        tplroot: {{ tplroot }}
        options: {{ c.env.options|tojson }}
    - watch_in:
      - service: centrifugo_service_{{ c.service.status }}

  {#- Create data dir #}
centrifugo_config_directory:
  file.directory:
    - name: {{ conf_dir }}
    - user: {{ c.user }}
    - group: {{ c.group }}
    - dir_mode: 755

  {#- Put config file in place #}
centrifugo_config_file:
  file.serialize:
    - name: {{ c.config.file }}
    - dataset: {{ c.config.data|tojson }}
    - serializer: {{ c.config.serializer }}
    - user: {{ c.user }}
    - group: {{ c.group }}
    - mode: 640
    {#- By default don't show changes to don't reveal secrets. #}
    - show_changes: {{ c.config.show_changes }}
    - require:
        - file: centrifugo_config_directory
    - watch_in:
      - service: centrifugo_service_{{ c.service.status }}

  {#- Create data dir #}
{# centrifugo_config_data_directory:
  file.directory:
    - name: {{ c.config.data.data_dir }}
    - user: {{ c.user }}
    - group: {{ c.group }}
    - dir_mode: 750
    - makedirs: True
    - require_in:
      - service: centrifugo_service_{{ c.service.status }} #}

{#- Centrifugo is not selected for installation #}
{%- else %}
centrifugo_config_install_notice:
  test.show_notification:
    - name: centrifugo_config_install_notice
    - text: |
        Centrifugo is not selected for installation, current value
        for 'centrifugo:install': {{ c.install|string|lower }}, if you want to install Centrifugo
        you need to set it to 'true'.

{%- endif %}
