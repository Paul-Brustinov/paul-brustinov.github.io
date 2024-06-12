SELECT @JSON FOR XML PATH('root'), TYPE;
SELECT CONCAT('<json_data><![CDATA[', @json, ']]></json_data>') AS json_xml;
