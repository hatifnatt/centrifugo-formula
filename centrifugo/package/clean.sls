{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import centrifugo as c %}

include:
  - {{ tplroot }}.service.clean
  - {{ tplroot }}.repo.clean

centrifugo_package_clean:
  pkg.removed:
    - pkgs:
    {%- for pkg in c.package.pkgs %}
      - {{ pkg }}
    {%- endfor %}
    - require_in:
      - sls: {{ tplroot }}.repo.clean

{#- Remove user and group #}
centrifugo_package_clean_user:
  user.absent:
    - name: {{ c.user }}
    - require_in:
      - sls: {{ tplroot }}.repo.clean

centrifugo_package_clean_group:
  group.absent:
    - name: {{ c.group }}
    - require_in:
      - sls: {{ tplroot }}.repo.clean
