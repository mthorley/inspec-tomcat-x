# Tomcat9 Controls

ONE_YEAR_IN_SECS = 31536000

control "VS.TOM.C-01" do
  impact 0.7 
  title "Ensure HTTP header security filter enabled"
  desc "HTTP header security filter required to enable secure response headers for all paths"
  describe web_xml_config(input('webxml_path')) do
    it { should exist }
    its("http_header_security_filter") { should be true }
    its("http_header_security_url_pattern") { should eq "/*" }
  end
end

control "APP-WEB-C001" do
  impact 0.7 
  title "Ensure HSTS is set"
  desc "Enforce HTTP Strict Transport Security (HSTS) header: force HTTPS"
  describe web_xml_config(input('webxml_path')) do
    its("hsts_enabled?") { should be true }
    its("hsts_maxAgeSeconds") { should be >= ONE_YEAR_IN_SECS }
    its("hsts_includeSubDomains?") { should be true }
  end
end

control "APP-WEB-C004" do
  impact 0.7
  title "Ensure X-Frame-Options is enabled"
  desc "Prevent clickjacking: Do not allow the browser to render the page inside an frame or iframe."
  describe web_xml_config(input('webxml_path')) do
    its("xfo_enabled?") { should be true }
    its("xfo_option") { should eq('DENY') }
  end
end

control "VS.TOM.C-04" do
  impact 0.7 
  title "Ensure HTTP header CORS filter enabled"
  desc "HTTP header CORS filter required to enable secure response headers for all paths"
  describe web_xml_config(input('webxml_path')) do
    its("http_header_cors_filter?") { should be true }
  end
end