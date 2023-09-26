<#assign start0 = .now>
<#assign jpath=handlers("JsonHandler")>
<#assign unit_map = '{"humidity": "relativeHumidityUnit", "pressure": "hectopascal", "temperature":"degreeCelcius", "sound":"decibel","luminosity":"lux","co2":"partsPerMillion","uv":"wattPerSquareMetre","o3":"partsPerMillion","pm2_5":"partsPerMillion","pm10":"partsPerMillion"}' >
<#assign property_map = '{"humidity": "relativeHumidity", "pressure": "atmosphoricPressure", "temperature":"ambientTemperature", "sound":"noiseLevel","luminosity":"illuminance","co2":"cO2Concentration","uv":"uVIndex","o3":"o3Concentration","pm2_5":"pM2.5Concentration","pm10":"pM10Concentration"}' >
<#assign datax = sensor_data?eval>

<#assign rdf>
{
    "@context":"https://auroralh2020.github.io/auroral-ontology-contexts/foggy/context.json",
    "measures":[
        <#list datax.data as row>
            <#assign name =row.parameter>
            <#assign timestamp =row.timestamp?c?number>
            <#assign value = row.value>
        {
                    "@type": "saref:Measurement",
                    "id": "urn:uuid:upm:sensor:[=name]:[=timestamp?replace(",","")]",
                    "timestamp": "[=timestamp?number_to_datetime?iso("Europe/Rome")]",
                    "value": "[=value?replace(',','')]",
                    "relates": "[=jpath.filter(name, property_map)]",
                    "measuredIn": "[=jpath.filter(name, unit_map)]"
                }
                <#if row?is_last><#else>,</#if>
        </#list>
    ]
}
</#assign>


<#assign config = {"data-format" : "json-ld", "output-format" : "nt"}>
<@action type="RdfCast" data=rdf conf=config; result>
<#assign rdf = result>
</@action>


<#assign start1 = .now>

<#assign body="INSERT DATA {   GRAPH <https://ts.fogger3.linkeddata.es/abced>  { " +rdf+ " } }">
<#assign graph="https://ts.fogger3.linkeddata.es/repositories/data-cloud/statements">
<#assign dataset>
{
            "method": "POST",
            "url": "[=graph]",
            "body": "[=body?js_string]",
            "headers" : {  "Content-Type" : "application/sparql-update" }
}
</#assign>


<#assign result = providers("HttpProvider",dataset)>
[=result]

<#assign start2 = .now>
<#-- Inicio, TiempoFinTransformacion, TiempoFinTransaccion -->
[=start0?iso_utc_ms], [=start1?iso_utc_ms], [=start2?iso_utc_ms] 
