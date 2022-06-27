{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import centrifugo as c %}
{%- set conf_dir = salt['file.dirname'](c.config.file) -%}

{%- if c.install %}
  {#- Install Centrifugo from precompiled binary #}
  {%- if c.use_upstream in ('binary', 'archive') %}

    {#- Path prefix for local (salt fileserver) files #}
    {%- set local_path = salt['file.join'](c.binary.download_local, 'v' ~ c.version) %}
    {#- Path prefix for remote (upstream) files #}
    {%- set remote_path = salt['file.join'](c.binary.download_remote, 'v' ~ c.version) %}
    {#- Path prefix for remote (upstream) sha256sum file #}
    {%- set source_hash_remote_path = salt['file.join'](c.binary.source_hash_remote, 'v' ~ c.version) %}

include:
  - {{ tplroot }}.service.install

    {#- Install prerequisies #}
centrifugo_binary_install_prerequisites:
  pkg.installed:
    - pkgs: {{ c.binary.prereq_pkgs|tojson }}
    - require_in:
      - file: centrifugo_binary_install_download_archive

    {#- Create group and user #}
centrifugo_binary_install_group:
  group.present:
    - name: {{ c.group }}
    - system: true

centrifugo_binary_install_user:
  user.present:
    - name: {{ c.user }}
    - gid: {{ c.group }}
    - system: true
    - password: '!'
    - home: {{ c.home }}
    - createhome: false
    - shell: /bin/false
    - fullname: Centrifugo daemon
    - require:
      - group: centrifugo_binary_install_group
    - require_in:
      - sls: {{ tplroot }}.service.install

    {#- Create directories #}
centrifugo_binary_install_bin_dir:
  file.directory:
    - name: {{ salt['file.dirname'](c.bin) }}
    - makedirs: true

    {#- Download archive, extract archive install binary to it's place #}
    {#- TODO: Download and validate SHA file with gpg? https://www.hashicorp.com/security.html #}
centrifugo_binary_install_download_archive:
  file.managed:
    - name: {{ c.binary.temp_dir }}/{{ c.version }}/centrifugo_{{ c.version }}_linux_amd64.tar.gz
    - source:
      - {{ local_path }}/centrifugo_{{ c.version }}_linux_amd64.tar.gz
      - {{ remote_path }}/centrifugo_{{ c.version }}_linux_amd64.tar.gz
    {%- if c.binary.skip_verify %}
    - skip_verify: true
    {%- else %}
    {#- source_hash only applicable when downloading via HTTP[S],
        it's not used when downloading from salt fileserver (salt://) #}
    - source_hash: {{ source_hash_remote_path }}/centrifugo_{{ c.version }}_checksums.txt
    {%- endif %}
    - makedirs: true
    - unless: test -f {{ c.bin }}-{{ c.version }}

centrifugo_binary_install_extract_bin:
  archive.extracted:
    - name: {{ c.binary.temp_dir }}/{{ c.version }}
    - source: {{ c.binary.temp_dir }}/{{ c.version }}/centrifugo_{{ c.version }}_linux_amd64.tar.gz
    - skip_verify: true
    - enforce_toplevel: false
    - require:
      - file: centrifugo_binary_install_download_archive
    - unless: test -f {{ c.bin }}-{{ c.version }}

centrifugo_binary_install_install_bin:
  file.rename:
    - name: {{ c.bin }}-{{ c.version }}
    - source: {{ c.binary.temp_dir }}/{{ c.version }}/{{ salt['file.basename'](c.bin) }}
    - require:
      - file: centrifugo_binary_install_bin_dir
    - watch:
      - archive: centrifugo_binary_install_extract_bin

    {#- Create symlink into system bin dir #}
centrifugo_binary_install_bin_symlink:
  file.symlink:
    - name: {{ c.bin }}
    - target: {{ c.bin }}-{{ c.version }}
    - force: true
    - require:
      - archive: centrifugo_binary_install_extract_bin
      - file: centrifugo_binary_install_install_bin
    - require_in:
      - sls: {{ tplroot }}.service.install

    {#- Fix problem with service startup due SELinux restrictions on RedHat falmily OS-es
        thx. https://github.com/saltstack-formulas/centrifugo-formula/issues/49 for idea #}
    {%- if grains['os_family'] == 'RedHat' %}
centrifugo_binary_install_bin_restorecon:
  module.run:
      {#- Workaround for deprecated `module.run` syntax, subject to change in Salt 3005 #}
      {%- if 'module.run' in salt['config.get']('use_superseded', [])
              or grains['saltversioninfo'] >= [3005] %}
    - file.restorecon:
        - {{ c.bin }}-{{ c.version }}
      {%- else %}
    - name: file.restorecon
    - path: {{ c.bin }}-{{ c.version }}
      {%- endif %}
    - require:
      - file: centrifugo_binary_install_install_bin
    - onlyif: "LC_ALL=C restorecon -vn {{ c.bin }}-{{ c.version }} | grep -q 'Would relabel'"
    {% endif -%}

    {#- Remove temporary files #}
centrifugo_binary_install_cleanup:
  file.absent:
    - name: {{ c.binary.temp_dir }}
    - require_in:
      - sls: {{ tplroot }}.service.install

  {#- Another installation method is selected #}
  {%- else %}
centrifugo_binary_install_method:
  test.show_notification:
    - name: centrifugo_binary_install_method
    - text: |
        Another installation method is selected. If you want to use binary
        installation method set 'centrifugo:use_upstream' to 'binary' or 'archive'.
        Current value of centrifugo:use_upstream: '{{ c.use_upstream }}'
  {%- endif %}

{#- Centrifugo is not selected for installation #}
{%- else %}
centrifugo_binary_install_notice:
  test.show_notification:
    - name: centrifugo_binary_install
    - text: |
        Centrifugo is not selected for installation, current value
        for 'centrifugo:install': {{ c.install|string|lower }}, if you want to install Centrifugo
        you need to set it to 'true'.

{%- endif %}
