{% from "jenkins/map.jinja" import master with context %}

{{ master.home }}/updates:
  file.directory:
  - user: jenkins
  - group: jenkins

setup_jenkins_cli:
  cmd.run:
  - runas: jenkins
  - names:
    - wget http://localhost:{{ master.http.port }}/jnlpJars/jenkins-cli.jar
  - unless: "[ -f {{ master.home }}/jenkins-cli.jar ]"
  - cwd: {{ master.home }}
  - require:
    - cmd: jenkins_service_running
    
restart_jenkins:
  cmd.run:
    - name: service jenkins restart && sleep 120

{%- for plugin in master.plugins %}

install_jenkins_plugin_{{ plugin.name }}:
  cmd.run:
  - runas: jenkins
  - name: >
      java -jar jenkins-cli.jar -s http://localhost:{{ master.http.port }} install-plugin {{ plugin.name }} ||
      java -jar jenkins-cli.jar -s http://localhost:{{ master.http.port }} install-plugin --username admin --password {{ master.user.admin.password }} {{ plugin.name }}
  - unless: "[ -d {{ master.home }}/plugins/{{ plugin.name }} ]"
  - cwd: {{ master.home }}
  - require:
    - cmd: setup_jenkins_cli
    - cmd: jenkins_service_running

{%- endfor %}
