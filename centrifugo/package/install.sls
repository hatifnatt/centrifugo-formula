{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import centrifugo as c %}
{%- set conf_dir = salt['file.dirname'](c.config.file) -%}

{%- if c.install %}
  {#- Install Centrifugo from packages #}
  {%- if c.use_upstream in ('repo', 'package') %}
include:
  - {{ tplroot }}.repo.install
  - {{ tplroot }}.service.install

    {#- Install packages required for further execution of 'package' installation method #}
    {%- if 'prereq_pkgs' in c.package and c.package.prereq_pkgs %}
centrifugo_package_install_prerequisites:
  pkg.installed:
    - pkgs: {{ c.package.prereq_pkgs|tojson }}
    - require:
      - sls: {{ tplroot }}.repo.install
    - require_in:
      - pkg: centrifugo_package_install
    {%- endif %}

    {%- if 'pkgs_extra' in c.package and c.package.pkgs_extra %}
centrifugo_package_install_extra:
  pkg.installed:
    - pkgs: {{ c.package.pkgs_extra|tojson }}
    - require:
      - sls: {{ tplroot }}.repo.install
    - require_in:
      - pkg: centrifugo_package_install
    {%- endif %}

centrifugo_package_install:
  pkg.installed:
    - pkgs:
    {%- for pkg in c.package.pkgs %}
      - {{ pkg }}{% if c.version is defined and 'centrifugo' in pkg %}: '{{ c.version }}*'{% endif %}
    {%- endfor %}
    - hold: {{ c.package.hold }}
    - update_holds: {{ c.package.update_holds }}
    {%- if salt['grains.get']('os_family') == 'Debian' %}
    - install_recommends: {{ c.package.install_recommends }}
    {%- endif %}
    - watch_in:
      - service: centrifugo_service_{{ c.service.status }}
    - require:
      - sls: {{ tplroot }}.repo.install
    - require_in:
      - sls: {{ tplroot }}.service.install

    {#- Create group and user #}
centrifugo_package_install_group:
  group.present:
    - name: {{ c.group }}
    - system: true
    - require:
      - pkg: centrifugo_package_install

centrifugo_package_install_user:
  user.present:
    - name: {{ c.user }}
    - gid: {{ c.group }}
    - system: true
    - password: '!'
    - home: {{ c.home }}
    - createhome: false
    - shell: /usr/sbin/nologin
    - fullname: Centrifugo daemon
    - require:
      - group: centrifugo_package_install_group
    - require_in:
      - sls: {{ tplroot }}.backup_helper.install
      - sls: {{ slsdotpath }}.service.install

  {#- Another installation method is selected #}
  {%- else %}
centrifugo_package_install_method:
  test.show_notification:
    - name: centrifugo_package_install_method
    - text: |
        Another installation method is selected. If you want to use package
        installation method set 'centrifugo:use_upstream' to 'package' or 'repo'.
        Current value of centrifugo:use_upstream: '{{ c.use_upstream }}'
  {%- endif %}

{#- Centrifugo is not selected for installation #}
{%- else %}
centrifugo_package_install_notice:
  test.show_notification:
    - name: centrifugo_package_install
    - text: |
        Centrifugo is not selected for installation, current value
        for 'centrifugo:install': {{ c.install|string|lower }}, if you want to install Centrifugo
        you need to set it to 'true'.

{%- endif %}
