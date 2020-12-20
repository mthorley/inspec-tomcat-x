# Tomcat9 InSpec Profile

Inspec profile to support verification of key security controls for Tomcat9.

To test

> inspec exec . --input webxml_path="./test/web.xml"

> inspec exec . --input webxml_path="./test/web-fail.xml"

> inspec exec . --input webxml_path="./test/web-empty.xml"

