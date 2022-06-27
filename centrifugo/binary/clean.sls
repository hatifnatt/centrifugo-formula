{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import centrifugo as c %}
{#- Find all centrifugo binaries with version i.e. /usr/local/bin/centrifugo-1.11.2 etc. #}
{%- set centrifugo_versions = salt['file.find'](c.bin ~ '-*', type='fl') %}

include:
  - {{ tplroot }}.service.clean

{#- Remove symlink into system bin dir #}
centrifugo_binary_clean_bin_symlink:
  file.absent:
    - name: {{ c.bin }}

{%- for binary in centrifugo_versions %}
  {%- set version = binary.split('-')[-1] %}
centrifugo_binary_clean_bin_v{{ version }}:
  file.absent:
    - name: {{ binary }}
    - require:
      - file: centrifugo_binary_clean_bin_symlink

{%- endfor %}

{#- Remove user and group #}
centrifugo_binary_clean_user:
  user.absent:
    - name: {{ c.user }}

centrifugo_binary_clean_group:
  group.absent:
    - name: {{ c.group }}
