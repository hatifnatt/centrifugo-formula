{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import centrifugo as c %}

{%- if c.install %}
  {#- Manage on boot service state in dedicated state to ensure watch trigger properly in service.running state #}
centrifugo_service_{{ c.service.on_boot_state }}:
  service.{{ c.service.on_boot_state }}:
    - name: {{ c.service.name }}

centrifugo_service_{{ c.service.status }}:
  service:
    - name: {{ c.service.name }}
    - {{ c.service.status }}
  {%- if c.service.status == 'running' %}
    - reload: {{ c.service.reload }}
  {%- endif %}
    - require:
        - service: centrifugo_service_{{ c.service.on_boot_state }}
    - order: last

{#- Centrifugo is not selected for installation #}
{%- else %}
centrifugo_service_notice:
  test.show_notification:
    - name: centrifugo_service_notice
    - text: |
        Centrifugo is not selected for installation, current value
        for 'centrifugo:install': {{ c.install|string|lower }}, if you want to install Centrifugo
        you need to set it to 'true'.

{%- endif %}
