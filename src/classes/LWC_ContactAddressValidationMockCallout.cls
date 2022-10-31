/**
 * Created by cnaranjo on 10/31/22.
 */

@IsTest
global with sharing class LWC_ContactAddressValidationMockCallout implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('Success');
        res.setHeader('Content-Type', 'application/json');
        res.setBody('' +
                '[\n' +
                '    {\n' +
                '        "address1": "14 Frenchman Drive",\n' +
                '        "address2": "Port Elliot SA 5212",\n' +
                '        "components": {\n' +
                '            "administrative_area": "SA",\n' +
                '            "administrative_area_long": "South Australia",\n' +
                '            "administrative_area_short": "SA",\n' +
                '            "country_iso_3": "AUS",\n' +
                '            "locality": "Port Elliot",\n' +
                '            "postal_code": "5212",\n' +
                '            "postal_code_short": "5212",\n' +
                '            "premise": "14",\n' +
                '            "premise_number": "14",\n' +
                '            "thoroughfare": "Frenchman Drive",\n' +
                '            "thoroughfare_name": "Frenchman",\n' +
                '            "thoroughfare_trailing_type": "Drive"\n' +
                '        },\n' +
                '        "metadata": {\n' +
                '            "latitude": -35.528361,\n' +
                '            "longitude": 138.685208,\n' +
                '            "geocode_precision": "DeliveryPoint",\n' +
                '            "max_geocode_precision": "DeliveryPoint",\n' +
                '            "address_format": "premise thoroughfare|locality administrative_area postal_code"\n' +
                '        },\n' +
                '        "analysis": {\n' +
                '            "verification_status": "Verified",\n' +
                '            "address_precision": "DeliveryPoint",\n' +
                '            "max_address_precision": "DeliveryPoint",\n' +
                '            "changes": {\n' +
                '                "components": {\n' +
                '                    "administrative_area": "Verified-NoChange",\n' +
                '                    "locality": "Verified-NoChange",\n' +
                '                    "postal_code_short": "Verified-NoChange",\n' +
                '                    "premise": "Verified-NoChange",\n' +
                '                    "thoroughfare": "Verified-NoChange",\n' +
                '                    "thoroughfare_type": "Verified-NoChange"\n' +
                '                }\n' +
                '            }\n' +
                '        }\n' +
                '    }\n' +
                ']'); return res;
    }

}