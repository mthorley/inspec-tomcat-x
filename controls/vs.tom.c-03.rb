
control 'VS.TOM.C-03' do
  impact 0.7
  title 'Ensure X-Frame-Options is enabled'
  desc 'Prevent clickjacking: Do not allow the browser to render the page inside an frame or iframe.'

  ref 'APP-WEB-C004', url: 'confluence'

  describe web_xml_config(catalina_home: input('catalina_home')) do
    its('xfo_enabled?') { should be true }
    its('xfo_option') { should eq('DENY') }
  end
end
