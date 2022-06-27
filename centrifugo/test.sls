{% set tplroot = tpldir.split('/')[0] -%}
{% from tplroot ~ '/map.jinja' import centrifugo -%}

centrifugo_test_print_data:
  test.configurable_test_state:
    - name: Print some dict
    - result: True
    - changes: False
    - comment: |
        {{ centrifugo|yaml(False)|indent(width=8) }}
