# Tomcat9 InSpec Profile

Inspec profile to support verification of key security controls for Tomcat9.
This is supplementary to the CIS benchmark for Tomcat9 as HTTP header controls are not currently defined.
Based on https://tomcat.apache.org/tomcat-9.0-doc/security-howto.html#web.xml

Profile expects the following inputs:
- catalina_home which specifies the tomcat installation root for 
	- conf/
		- web.xml
    - server.xml

## Install Inspec

```console 
$ gem install inspec
$ gem install inspec-bin 
```
## Test commands

```console
$ inspec exec . --input catalina_home="./test/pass"
$ inspec exec . --input catalina_home="./test/fail"
$ inspec exec . --input catalina_home="./test/empty"
```
All tests should fail for both fail and empty configurations.

## Execute against a target running tomcat container

Note this assumes inspec (and tomcat inspec profile) are running on the same host as the docker socket. Therefore neither inspec nor the inspec source controls are required to be deployed in the container which keeps the container image clean and supports adding new controls independently.

```console
# grab a docker image of tomcat and run it
$ docker run -p 8080:8080 tomcat:9.0.41-jdk15-openjdk-oracle

# get the container id
$ docker container ls
CONTAINER ID        IMAGE                                COMMAND             ...
f57bdc4051c7        tomcat:9.0.41-jdk15-openjdk-oracle   "catalina.sh run"   ...

# execute inspec against running container id
$ inspec exec . --input catalina_home=/usr/local/tomcat -t docker://f57bdc4051c7
```

The default tomcat configuration is not secure by default:
```console
Profile: InSpec Profile for Tomcat9 (tomcat9-x)
Version: 0.1.0
Target:  docker://f57bdc4051c7a742428fee584aa9b1a0944c2e92735a6dc52989c574f06dcae3

  ×  VS.TOM.C-01: Ensure HTTP header security filter enabled (2 failed)
     ×  web_xml_config http_header_security_filter? is expected to equal true
     
     expected true
          got false

     ×  web_xml_config http_header_security_url_pattern is expected to eq "/*"
     
     expected: "/*"
          got: nil
     
     (compared using ==)

  ×  VS.TOM.C-02: Ensure HSTS is set (3 failed)
     ×  web_xml_config hsts_enabled? is expected to equal true
     
     expected true
          got false

     ×  web_xml_config hsts_maxAgeSeconds is expected to be >= 31536000
     expected: >= 31536000
          got:    0
     ×  web_xml_config hsts_includeSubDomains? is expected to equal true
     
     expected true
          got false

  ×  VS.TOM.C-03: Ensure X-Frame-Options is enabled (2 failed)
     ×  web_xml_config xfo_enabled? is expected to equal true
     
     expected true
          got false

     ×  web_xml_config xfo_option is expected to eq "DENY"
     
     expected: "DENY"
          got: nil
     
     (compared using ==)

  ×  VS.TOM.C-04: Ensure HTTP header CORS filter enabled (2 failed)
     ×  web_xml_config http_header_cors_filter? is expected to equal true
     
     expected true
          got false

     ×  web_xml_config http_header_cors_url_pattern is expected to eq "/*"
     
     expected: "/*"
          got: nil
     
     (compared using ==)

  ×  VS.TOM.C-05: Ensure default servlet security (2 failed)
     ×  web_xml_config default_servlet_readonly? is expected to equal true
     
     expected true
          got nil

     ✔  web_xml_config default_servlet_listings? is expected to equal false
     ✔  web_xml_config default_servlet_debug is expected to eq 0
     ×  web_xml_config default_servlet_showserverinfo? is expected to equal false
     
     expected false
          got nil

     ✔  web_xml_config default_servlet_startup is expected to eq 1

Profile Summary: 0 successful controls, 5 control failures, 0 controls skipped
Test Summary: 3 successful, 11 failures, 0 skipped
```
