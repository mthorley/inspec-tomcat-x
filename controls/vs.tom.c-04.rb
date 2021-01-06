
control "VS.TOM.C-04" do
  impact 0.7 
  title "Ensure HTTP header CORS filter enabled"
  desc "HTTP header CORS filter required to enable secure response headers for all paths"

  describe web_xml_config(catalina_home: input("catalina_home")) do
    its("http_header_cors_filter?") { should be true }
    its("http_header_cors_url_pattern") { should eq "/*" }
  end

end
