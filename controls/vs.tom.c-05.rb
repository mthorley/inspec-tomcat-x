
control 'VS.TOM.C-05' do
  impact 1.0
  title 'Ensure default servlet security'
  desc "Default servlet must be:
    - 'Readonly' is set to true to prevent modification or deletion of static resources
    - Must not enable directory 'listings' to prevent DOS attacks consuming significant CPU/memory where large number of files exist
    - Ensure debug is set 0
    - Ensure 'showServerInfo' is set to false to prevent information technology leakage
    - First to load on startup
  "

  describe web_xml_config(catalina_home: input('catalina_home')) do
    its('default_servlet_readonly?') { should be true }
    its('default_servlet_listings?') { should be false }
    its('default_servlet_debug') { should eq 0 }
    its('default_servlet_showserverinfo?') { should be false }
    its('default_servlet_startup') { should eq 1 }
  end
end
