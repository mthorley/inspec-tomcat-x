
ONE_YEAR_IN_SECS = 31536000

control "VS.TOM.C-02" do
  impact 0.7 
  title "Ensure HSTS is set"
  desc "Enforce HTTP Strict Transport Security (HSTS) header: force HTTPS"

  ref 'APP-WEB-C001', url: 'confluence'

  describe web_xml_config(catalina_home: input("catalina_home")) do
    its("hsts_enabled?") { should be true }
    its("hsts_maxAgeSeconds") { should be >= ONE_YEAR_IN_SECS }
    its("hsts_includeSubDomains?") { should be true }
  end
end
