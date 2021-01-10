
require 'nokogiri'

# Helper methods to support introspection of web.xml
class WebXmlConfig < Inspec.resource(1)
  name 'web_xml_config'

  desc '
    web xml config to enforce buildtime assurance tests for Tomcat 9
  '

  example "
    describe web_xml_config do
      its('http_header_security_filter') { should be true }
    end
  "

  HTTP_HDR_SEC_FILTER_JAVA_CLASS =
    'org.apache.catalina.filters.HttpHeaderSecurityFilter'.freeze

  HTTP_HDR_CORS_FILTER_JAVA_CLASS =
    'org.apache.catalina.filters.CorsFilter'.freeze

  HTTP_DEFAULT_SERVLET_JAVA_CLASS =
    'org.apache.catalina.servlets.DefaultServlet'.freeze

  def initialize(opts = {})
    raise ArgumentError ':catalina_home MUST be set in options hash' unless opts.key?(:catalina_home)
    web_conf_file = inspec.file("#{opts[:catalina_home]}/conf/web.xml")
    return skip_resource("File '#{web_conf_file}' not found") unless web_conf_file.exist?
    @doc = Nokogiri::XML(web_conf_file.content)
    @doc.remove_namespaces!
  end

  #
  # default servlet methods
  #
  def default_servlet_readonly?
    e = @doc.xpath(get_defaultservlet_xpath('readonly'))
    ro = false
    ro = e.children.to_s.eql?('true') ? true : false unless e.empty?
  end

  def default_servlet_listings?
    e = @doc.xpath(get_defaultservlet_xpath('listings'))
    l = true
    l = e.children.to_s.eql?('false') ? false : true unless e.empty?
  end

  def default_servlet_debug
    e = @doc.xpath(get_defaultservlet_xpath('debug'))
    d = 1
    d = e.children.to_s unless e.empty?
    d.to_i
  end

  def default_servlet_showserverinfo?
    e = @doc.xpath(get_defaultservlet_xpath('showServerInfo'))
    s = true
    s = e.children.to_s.eql?('false') ? false : true unless e.empty?
  end

  def default_servlet_startup
    e = @doc.xpath("/web-app/servlet[servlet-class='#{HTTP_DEFAULT_SERVLET_JAVA_CLASS}']/load-on-startup")
    pos = 0
    pos = e.children.to_s unless e.empty?
    pos.to_i
  end

  #
  # http header security filter
  #
  def http_header_security_filter?
    e = @doc.xpath("/web-app/filter[filter-class='#{HTTP_HDR_SEC_FILTER_JAVA_CLASS}']")
    !e.empty?
  end

  def http_header_security_url_pattern
    get_filter_mapping_url_pattern(HTTP_HDR_SEC_FILTER_JAVA_CLASS)
  end

  def hsts_enabled?
    e = @doc.xpath(get_filter_xpath(HTTP_HDR_SEC_FILTER_JAVA_CLASS, 'hstsEnabled'))
    enabled = false
    enabled = e.children.to_s.eql?('true') unless e.empty?
    enabled
  end

  def hsts_maxage_seconds
    e = @doc.xpath(get_filter_xpath(HTTP_HDR_SEC_FILTER_JAVA_CLASS, 'hstsMaxAgeSeconds'))
    age = nil
    age = e.children.to_s unless e.empty?
    age.to_i
  end

  def hsts_include_subdomains?
    e = @doc.xpath(get_filter_xpath(HTTP_HDR_SEC_FILTER_JAVA_CLASS, 'hstsIncludeSubDomains'))
    inc = false
    inc = e.children.to_s.eql?('true') unless e.empty?
    inc
  end

  def xfo_enabled?
    e = @doc.xpath(get_filter_xpath(HTTP_HDR_SEC_FILTER_JAVA_CLASS, 'antiClickJackingEnabled'))
    xfo = false
    xfo = e.children.to_s.eql?('true') unless e.empty?
    xfo
  end

  def xfo_option
    e = @doc.xpath(get_filter_xpath(HTTP_HDR_SEC_FILTER_JAVA_CLASS, 'antiClickJackingOption'))
    xfo = nil
    xfo = e.children.to_s unless e.empty?
    xfo
  end

  #
  # http header cors filter
  #
  def http_header_cors_filter?
    e = @doc.xpath("/web-app/filter[filter-class='#{HTTP_HDR_CORS_FILTER_JAVA_CLASS}']")
    !e.empty?
  end

  def http_header_cors_url_pattern
    get_filter_mapping_url_pattern(HTTP_HDR_CORS_FILTER_JAVA_CLASS)
  end

  #
  # cookieconfig
  #
  def cookie_config_httponly?
    e = @doc.xpath('/web-app/session-config/cookie-config/http-only')
    r = false
    r = e.children.to_s.eql?('true') unless e.empty?
    r
  end

  def cookie_config_secure?
    e = @doc.xpath('/web-app/session-config/cookie-config/secure')
    r = false
    r = e.children.to_s.eql?('true') unless e.empty?
    r
  end

  private

  def get_filter_name(filter_class)
    e = @doc.xpath("/web-app/filter[filter-class='#{filter_class}']/filter-name")
    filter_name = nil
    filter_name = e.children.to_s unless e.empty?
    filter_name
  end

  def get_filter_mapping_url_pattern(filter_class)
    ptn = nil
    filter_name = get_filter_name(filter_class)
    if !filter_name.nil?
      e = @doc.xpath("/web-app/filter-mapping[filter-name='#{filter_name}']/url-pattern")
      ptn = e.children.to_s unless e.empty?
    end
    ptn
  end

  def get_filter_xpath(filter_class, param_name)
    "/web-app/filter[filter-class='#{filter_class}']/init-param[param-name='#{param_name}']/param-value"
  end

  def get_defaultservlet_xpath(param_name)
    "/web-app/servlet[servlet-class='#{HTTP_DEFAULT_SERVLET_JAVA_CLASS}']/init-param[param-name='#{param_name}']/param-value"
  end
end
