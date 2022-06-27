{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import centrifugo as c %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}
{%- set conf_dir = salt['file.dirname'](c.config.file) -%}

  {#- Remove config file #}
centrifugo_config_clean_file:
  file.absent:
    - name: {{ c.config.file }}
    - require_in:
        - file: centrifugo_config_clean_directory

  {#- Remove parameters / environment file #}
centrifugo_config_clean_env_file:
  file.absent:
    - name: {{ c.env.file }}

  {#- Remove config dir #}
centrifugo_config_clean_directory:
  file.absent:
    - name: {{ conf_dir }}
