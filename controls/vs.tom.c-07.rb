
control 'VS.TOM.C-07' do
  impact 1.0
  title 'Ensure xpoweredBy HTTP header is disabled'
  desc 'Ensure xpoweredBy HTTP header is disabled for all connectors to prevent information technology leakage'

  tag cis: '2.4'

  describe server_xml_config(catalina_home: input('catalina_home')) do
    its('connectors_poweredby_header_disabled?') { should be true }
  end
end
