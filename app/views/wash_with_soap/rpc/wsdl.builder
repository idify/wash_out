xml.instruct!
xml.wsdl:definitions, 'xmlns:wsdl' => 'http://schemas.xmlsoap.org/wsdl/',
                'xmlns:soap' => 'http://schemas.xmlsoap.org/wsdl/soap/',
                'xmlns:xs' => 'http://www.w3.org/2001/XMLSchema',
                'xmlns:tns' => 'http://www.sonos.com/Services/1.1',
                'xmlns:ns0' => "http://schemas.xmlsoap.org/soap/envelope/",
                'xmlns:ns1' => "http://www.sonos.com/Services/1.1",
                'name' => @name,
                'targetNamespace' => 'http://www.sonos.com/Services/1.1' do
  xml.wsdl:types do
    xml.tag! "xs:schema", :targetNamespace => @namespace, :elementFormDefault=>"qualified", :xmlns => 'http://www.w3.org/2001/XMLSchema' do
      defined = []
      @map.each do |operation, formats|
        xml.tag! "xs:element",:name => "#{operation}" do
          xml.tag! "xs:complexType" do
            xml.tag! "xs:sequence" do
              formats[:in].each do |p|
                xml.tag! "xs:element", :ref=>"tns:#{p.name}"
              end
            end
          end
        end     
        xml.tag! "xs:element",:name => "#{formats[:response_tag]}" do
          xml.tag! "xs:complexType" do
            xml.tag! "xs:sequence" do
              formats[:out].each do |p|
                xml.tag! "xs:element", :name=>"#{p.name}", :type=>"tns:#{p.type}"
              end
            end
          end
        end
      end
    end
  end
  
  xml.wsdl:portType, :name => "#{@name}Soap" do
    @map.each do |operation, formats|
      xml.tag! "wsdl:operation",:name => "#{operation}" do
        xml.tag! "wsdl:input", :message=>"tns:#{operation}In"
        xml.tag! "wsdl:output", :message=>"tns:#{operation}Out"
      end
    end
  end
  
  xml.tag! "wsdl:message", :name => "credentials" do
    xml.tag! "wsdl:part", :name=>"credentials", :element=>"tns:credentials"
  end
  @map.each do |operation, formats|
    xml.tag! "wsdl:message", :name => "#{operation}In" do
      xml.tag! "wsdl:part", :name=>"parameters", :element=>"tns:#{operation}"
    end
    xml.tag! "wsdl:message", :name => "#{operation}Out" do
      xml.tag! "wsdl:part", :name=>"parameters", :element=>"tns:#{formats[:response_tag]}"
    end
  end

  xml.wsdl:binding, :name => "#{@name}Soap", :type => "tns:#{@name}Soap" do
    xml.tag! "soap:binding", :transport => 'http://schemas.xmlsoap.org/soap/http'
    @map.keys.each do |operation|
      xml.wsdl:operation, :name => operation do
        xml.tag! "soap:operation", :soapAction => operation, :style=>"document"
        xml.wsdl:input do
          xml.tag! "soap:header",
            :use => "literal", :message=>"tns:credentials", :part=>"credentials"
          xml.tag! "soap:body",
            :use => "literal"
        end
        xml.wsdl:output do
          xml.tag! "soap:body",
            :use => "literal"
        end
      end
    end
  end

  xml.wsdl:service, :name => "#{@name}" do
    xml.wsdl:port, :name => "#{@name}Soap", :binding => "tns:#{@name}Soap" do
      xml.tag! "soap:address", :location => send("#{@name}_action_url")
    end
  end
end
