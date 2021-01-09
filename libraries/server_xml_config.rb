# server.xml

require 'nokogiri'

class ServerXmlConfig < Inspec.resource(1)
  name "server_xml_config"

  desc "
    server xml config to enforce buildtime assurance tests for Tomcat 9
  "

  example "
    describe server_xml_config do
      its('connectors_poweredby_header_disabled?') { should be false }
    end
  "

  def initialize(opts = {})
    raise ArgumentError ':catalina_home MUST be set in options hash' unless opts.key?(:catalina_home)
    server_conf_file = inspec.file("#{opts[:catalina_home]}/conf/server.xml")
    return skip_resource("File '#{server_conf_file}' not found") unless server_conf_file.exist?
    @doc = Nokogiri::XML(server_conf_file.content)
    @doc.remove_namespaces!
  end

  # for all connectors we expect xpoweredBy attribute to be false
  def connectors_poweredby_header_disabled?
  	attrs = @doc.xpath("//Connector/@xpoweredBy")
  	disabled = false
  	if !attrs.empty?
      attrs.each do |a|
        if a.to_s.eql?("false")
          disabled = true
        else
          disabled = false
          break
        end
      end
    end
    disabled
  end

end