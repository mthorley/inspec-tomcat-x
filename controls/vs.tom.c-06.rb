
control 'VS.TOM.C-06' do
  impact 1.0
  title 'Ensure cookie security'
  desc 'Ensure cookies set httponly and secure=true'

  describe web_xml_config(catalina_home: input('catalina_home')) do
    its('cookie_config_httponly?') { should be true }
    its('cookie_config_secure?') { should be true }
  end
end
