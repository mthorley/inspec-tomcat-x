# Tomcat9 InSpec Profile

Inspec profile to support verification of key security controls for Tomcat9.
This is supplementary to the CIS benchmark for Tomcat9 as HTTP header controls are not currently defined.
Based on https://tomcat.apache.org/tomcat-9.0-doc/security-howto.html#web.xml

Profile expects the following inputs:
- catalina_home which specifies the tomcat installation root for 
	- conf/
		- web.xml

To install:

> gem install inspec
> gem install inspec-bin 

To test:

> inspec exec . --input catalina_home="./test/pass"

> inspec exec . --input catalina_home="./test/fail"

> inspec exec . --input catalina_home="./test/empty"

