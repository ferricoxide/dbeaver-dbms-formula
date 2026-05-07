dbeaver-dbms:
  lookup:
    {%- if grains.os_family == "RedHat" %}      # Configure for ELx Linux distros
    pkg:
      name: 'dbeaver-le'
      download_uri: 'https://dbeaver.com/files/dbeaver-le-latest-linux-x86_64.rpm'
    java_version: '17'
    {%- elif grains.os_family == "Windows" %}   # Configure for Windows-based hosts
    pkg:
      requested_edition: 'lite'
      driver_seeds:
        - name: mysql-connector-j-9.7.0.jar
          source: 'https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/9.7.0/mysql-connector-j-9.7.0.jar'
        - name: mysql-connector-j-8.0.33.jar
          source: 'https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar'
        - name: postgresql-42.7.11.jar
          source: 'https://jdbc.postgresql.org/download/postgresql-42.7.11.jar'
    {%- endif %}
