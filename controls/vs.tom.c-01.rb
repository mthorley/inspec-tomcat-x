
control 'VS.TOM.C-01' do
  impact 0.7
  title 'Ensure HTTP header security filter enabled'
  desc "
    HTTP header security filter required to enable secure response headers for all paths.
    Rationale:
    This is a pre-requisite to enabling secure HTTP response headers and MUST be enabled for all paths
    by ensuring the url pattern is '/*'
    "

  ref 'Internal Controlset', url: 'confluence'

  describe web_xml_config(catalina_home: input('catalina_home')) do
    its('http_header_security_filter?') { should be true }
    its('http_header_security_url_pattern') { should eq '/*' }
  end
end
