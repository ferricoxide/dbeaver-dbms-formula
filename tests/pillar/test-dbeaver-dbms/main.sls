dbeaver-dbms:
  lookup:
    {%- if grains.os_family == "RedHat" %}      # Configure for ELx Linux distros
    pkg:
      name: 'dbeaver-le'
      download_uri: 'https://dbeaver.com/files/dbeaver-le-latest-linux-x86_64.rpm'
    java_version: '17'
    {%- elif grains.os_family == "Windows" %}   # Configure for Windows-based hosts
    {%- endif %}
