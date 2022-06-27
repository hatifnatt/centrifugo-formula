{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import centrifugo as c %}

{#- Remove any configured repo form the system #}
{#- If only one repo configuration is present - convert it to list #}
{%- if c.repo.config is mapping %}
  {%- set configs = [c.repo.config] %}
{%- else %}
  {%- set configs = c.repo.config %}
{%- endif %}
{%- for config in configs %}
centrifugo_repo_clean_{{ loop.index0 }}:
  {%- if grains.os_family != 'Debian' %}
  pkgrepo.absent:
    - name: {{ config.name | yaml_dquote }}
  {%- else %}
  {#- Due bug in pkgrepo.absent we need to manually remove repositry '.list' files
      See https://github.com/saltstack/salt/issues/61602 #}
  file.absent:
    - name: {{ config.file }}
  {%- endif %}

{%- endfor %}

{#- Remove keyring #}
centrifugo_repo_clean_keyring:
  file.absent:
    - name: /usr/share/keyrings/centrifugo-archive-keyring.gpg
