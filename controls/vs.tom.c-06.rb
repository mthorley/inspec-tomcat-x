
control "VS.TOM.C-06" do
  impact 1.0
  title "Ensure cookie set to httponly and secure=true"
  desc ""
  
  describe web_xml_config(catalina_home: input("catalina_home")) do
    its("cookie_config_httponly?") { should be true }
    its("cookie_config_secure?") { should be true }
  end

end
