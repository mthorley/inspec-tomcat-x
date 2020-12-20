require "rexml/document"

class WebXmlConfig < Inspec.resource(1)
  name "web_xml_config"

  desc "
    web xml config to enforce buildtime assurance tests for Tomcat 9
  "

  example "
    describe web_xml_config do
      it { should exist }
      its('http_header_security_filter') { should be true }
    end
  "

  HTTP_HDR_SEC_FILTER_JAVA_CLASS = 
    'org.apache.catalina.filters.HttpHeaderSecurityFilter'

  HTTP_HDR_CORS_FILTER_JAVA_CLASS = 
    'org.apache.catalina.filters.CorsFilter'

  def initialize(path = nil)
    @path = path || "${TOMCAT-HOME}/conf/web.xml"
    @file = File.new(@path)

    begin
      @doc = REXML::Document.new(@file)

    rescue StandardError => e
      raise Inspec::Exceptions::ResourceSkipped, "#{@file}: #{e.message}"
    end
  end
  
  def exists?
    File.exist?(@path)
  end
    
  def http_header_security_filter
    find_filter_index_for(HTTP_HDR_SEC_FILTER_JAVA_CLASS) > 0
  end

  def http_header_security_url_pattern
    r = ""
    i = find_filter_index_for(HTTP_HDR_SEC_FILTER_JAVA_CLASS)
    if (i>0)
      filter_name = REXML::XPath.first(@doc, "//filter[" + i.to_s + "]/filter-name").text
      r = filter_mapping_value_for(filter_name, "url-pattern")
    end
    r
  end

  def hsts_enabled?
    param_value_for(HTTP_HDR_SEC_FILTER_JAVA_CLASS, 
      'hstsEnabled')=='true' ? true : false
  end

  def hsts_maxAgeSeconds
    param_value_for(HTTP_HDR_SEC_FILTER_JAVA_CLASS, 
      'hstsMaxAgeSeconds').to_i
  end
  
  def hsts_includeSubDomains?
    param_value_for(HTTP_HDR_SEC_FILTER_JAVA_CLASS, 
      'hstsIncludeSubDomains')=='true' ? true : false
  end
  
  def xfo_enabled?
    param_value_for(HTTP_HDR_SEC_FILTER_JAVA_CLASS, 
      'antiClickJackingEnabled')=='true' ? true : false
  end

  def xfo_option
    param_value_for(HTTP_HDR_SEC_FILTER_JAVA_CLASS, 
      'antiClickJackingOption')
  end

  def http_header_cors_filter?
    find_filter_index_for(HTTP_HDR_CORS_FILTER_JAVA_CLASS) > 0
  end

private

  # Returns the param-value element for a param-name, given its filter-class.
  # 
  # Given the xml:
  #   <filter-class>org.apache.clazz</filter-class>
  #   <init-param>
  #     <param-name>hsts</param-name>
  #     <param-value>true</param-value>
  #   </init-param>
  # 
  # Invoking param_value_for("org.apache.clazz", "hsts") would return true.
  #
  def param_value_for(classname, name)
    r = nil
    i = find_filter_index_for(classname)
    REXML::XPath.each(@doc, "//filter[" + i.to_s + "]/init-param") { |e|
      if e[1].name == "param-name" && e[1].text == name 
        if e[3].name == "param-value"
          r = e[3].text
        end
      end
    }
    r
  end

  # find the filter index for a Java classname
  def find_filter_index_for(classname) 
    index = 0
    n = REXML::XPath.first(@doc, "count(//filter)")
    for i in 1..n do
      REXML::XPath.each(@doc, "//filter[" + i.to_s + "]/*") { |e|
        if e.name == "filter-class" && e.text == classname
          index = i
        end
      }
    end
    index
  end

  # Returns a peer element value for a filter-name.
  # 
  # Given the xml:
  #   <filter-mapping>
  #     <filter-name>httpHeaderSecurity</filter-name>
  #     <url-pattern>/*</url-pattern>
  #   </filter-mapping>
  #
  # Invoking filter_mapping_value_for("httpHeaderSecurity", "url-pattern") would return '/*'.
  #
  def filter_mapping_value_for(filter_name, name)
    r = nil
    i = find_filter_mapping_index_for(filter_name)
    if (i>0)
      REXML::XPath.each(@doc, "//filter-mapping[" + i.to_s + "]/*") { |e|
        if e.name == name
          r = e.text
        end
      }
    end
    r
  end

  # find the filter_mapping index for a filter name
  def find_filter_mapping_index_for(filter_name)
    index = 0
    n = REXML::XPath.first(@doc, "count(//filter-mapping)")
    for i in 1..n do
      REXML::XPath.each(@doc, "//filter-mapping[" + i.to_s + "]/*") { |e|
        if e.name == "filter-name" && e.text == filter_name
          index = i
        end
      }
    end
    index
  end

end
