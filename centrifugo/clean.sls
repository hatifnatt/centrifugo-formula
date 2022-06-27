{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ '/map.jinja' import centrifugo as c %}
include:
{%- if c.use_upstream in ('binary', 'archive') %}
  - .binary.clean
{%- elif c.use_upstream in ('repo', 'package') %}
  - .package.clean
{%- endif %}
