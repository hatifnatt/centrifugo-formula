{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import centrifugo as c %}
{%- from tplroot ~ '/macros.jinja' import format_kwargs %}

{%- if c.install %}
  {#- If centrifugo:use_upstream is 'repo' or 'package' official repo will be configured #}
  {%- if c.use_upstream in ('repo', 'package') %}

    {#- Install required packages if defined #}
    {%- if c.repo.prerequisites %}
centrifugo_repo_install_prerequisites:
  pkg.installed:
    - pkgs: {{ c.repo.prerequisites|tojson }}
    {%- endif %}

    {#- Install keyring if provided, for Debian based systems only #}
    {%- if 'keyring' in c.repo and c.repo.keyring %}
centrifugo_repo_install_keyring:
  file.managed:
    - name: /usr/share/keyrings/centrifugo-archive-keyring.gpg
    - source: {{ c.repo.keyring }}
    {%- endif %}

    {#- If only one repo configuration is present - convert it to list #}
    {%- if c.repo.config is mapping %}
      {%- set configs = [c.repo.config] %}
    {%- else %}
      {%- set configs = c.repo.config %}
    {%- endif %}
    {%- for config in configs %}
centrifugo_repo_install_{{ loop.index0 }}:
  pkgrepo.managed:
    {{- format_kwargs(config) }}
      {%- if 'keyring' in c.repo and c.repo.keyring %}
    - require:
      - file: centrifugo_repo_install_keyring
      {%- endif %}
    {%- endfor %}

  {#- Another installation method is selected #}
  {%- else %}
centrifugo_repo_install_method:
  test.show_notification:
    - name: centrifugo_repo_install_method
    - text: |
        Another installation method is selected. Repo configuration is not required.
        If you want to configure repository set 'centrifugo:use_upstream' to 'repo' or 'package'.
        Current value of centrifugo:use_upstream: '{{ c.use_upstream }}'
  {%- endif %}

{#- Centrifugo is not selected for installation #}
{%- else %}
centrifugo_repo_install_notice:
  test.show_notification:
    - name: centrifugo_repo_install
    - text: |
        Centrifugo is not selected for installation, current value
        for 'centrifugo:install': {{ c.install|string|lower }}, if you want to install Centrifugo
        you need to set it to 'true'.

{%- endif %}
