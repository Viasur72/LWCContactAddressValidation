/**
 * Created by cnaranjo on 10/29/22.
 */
public with sharing class LWC_ContactAddressValidation {
    public static final String FAILED_MESSAGE = 'Failed to load Contact data. Please contact your administrator';
    public static final String SUCCESS_MESSAGE = 'Success! Address Validated!';
    public static final String VERIFICATION_FAILED = 'Insufficient values sent for verification';
    public static final String PARTIALLY_VERIFIED = 'Verification was partially completed';
    public static final String AMBIGUOUS_VERIFICATION = 'Verification was ambiguous, not fully completed';
    public static final String PLEASE_FILL_ALL_FIELDS = 'Please, make sure all fields are filled';
    public static final String PLEASE_FILL_ALL_FIELDS_ON_UPDATE = 'Please, make sure all fields are filled before updating record';
    public static final String COUNTRY_LENGTH_TOO_SHORT = 'Mailing country is to short';
    public static final String COUNTRY_LENGTH_TOO_SHORT_ON_UPDATE = 'Failing to update address.Mailing country is to short';
    public static final String SUCCESS_MESSAGE_ON_UPDATE = 'Success! Address Updated!';
    private static String mailingCity;
    private static String mailingCountry;
    private static String mailingPostalCode;
    private static String mailingStreet;
    public static Boolean allowHTTPCallout = true;

    public class ValidationException extends Exception {
    }

    @AuraEnabled(Cacheable=true)
    public static Contact loadContact(Id recordId) {
        return [
                SELECT Name, MailingCity, MailingCountry, MailingPostalCode, MailingStreet, Address_Verified__c
                FROM Contact
                WHERE Id = :recordId
        ];
    }

    @AuraEnabled
    public static Map<String, Object> validationAddressUpdateFields(Map<String, Object> addressParameters) {
        Map<String, Object> result = new Map<String, Object>();
        String mailingCountryString = (String) addressParameters.get('mailingCountry');
        Integer mailingCountryStringLength = mailingCountryString.length();
        Boolean error = false;
        String message = '';

        Boolean checkIncomingValues = parametersCheck(addressParameters);

        if (!checkIncomingValues) {
            error = true;
            message = PLEASE_FILL_ALL_FIELDS_ON_UPDATE;
        }

        if (mailingCountryStringLength <= 1) {
            error = true;
            message = COUNTRY_LENGTH_TOO_SHORT_ON_UPDATE;
        }

        if (!error) {
            try {
                LWC_ContactAddressValidation.MailingAddressUpdatedFields updatedFields =
                        new LWC_ContactAddressValidation.MailingAddressUpdatedFields();

                updatedFields.mailingPostalCode = (String) addressParameters.get('mailingPostalCode');
                updatedFields.mailingStreet = (String) addressParameters.get('mailingStreet');
                updatedFields.mailingCity = (String) addressParameters.get('mailingCity');
                updatedFields.mailingCountry = (String) addressParameters.get('mailingCountry');
                updatedFields.recordId = (Id) addressParameters.get('recordId');
                ContactService.getInstance().updateMailingAddressFields(updatedFields);
                message = SUCCESS_MESSAGE_ON_UPDATE;

            } catch (ValidationException e) {
                message = e.getMessage();
                error = true;
            }
        }

        result.put('message', message);
        result.put('error', error);
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> validationAddressInputFields(Map<String, Object> addressParameters) {
        ValidationAddressListsInput.Analysis analysis = new ValidationAddressListsInput.Analysis();
        Map<String, Object> result = new Map<String, Object>();
        Id recordId = (Id) addressParameters.get('recordId');
        String mailingCountryString = (String) addressParameters.get('mailingCountry');
        Integer mailingCountryStringLength = mailingCountryString.length();
        Boolean error = false;
        String verificationStatus;
        Boolean verified;
        String message = '';

        Boolean checkIncomingValues = parametersCheck(addressParameters);

        if (!checkIncomingValues) {
            error = true;
            message = PLEASE_FILL_ALL_FIELDS;
        }

        if (mailingCountryStringLength <= 1) {
            error = true;
            message = COUNTRY_LENGTH_TOO_SHORT;
        }

        if (!error && allowHTTPCallout) {
            String endpoint = generateEndPoint(addressParameters);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            Http http = new Http();
            HttpResponse res = http.send(req);
            String responseBody = res.getBody();

            try {

                if (addressParameters.isEmpty()) {
                    throw new ValidationException(FAILED_MESSAGE);
                }

                if (res.getStatusCode() != 200) {
                    throw new ValidationException('Call out failed: ' + res.getStatusCode() + ' ' + res.getStatus());
                } else {
                    List<ValidationAddressListsInput> responseBodyResult =
                            (List<ValidationAddressListsInput>) JSON.deserialize(responseBody, List<ValidationAddressListsInput>.class);

                    for (ValidationAddressListsInput validationAddressListsInput : responseBodyResult) {
                        analysis = new ValidationAddressListsInput.Analysis();
                        analysis = validationAddressListsInput.analysis;
                    }

                    verificationStatus = analysis.verification_status;
                    System.debug('verificationStatus ' + verificationStatus);

                    if (verificationStatus == 'Verified') {
                        verified = true;
                        ContactService.getInstance().updateAddressValidationField(recordId);
                        message = SUCCESS_MESSAGE;
                    } else if (verificationStatus == 'None') {
                        verificationStatus = 'None';
                        message = VERIFICATION_FAILED;
                    } else if (verificationStatus == 'Partial') {
                        verificationStatus = 'Partial';
                        message = PARTIALLY_VERIFIED;
                    } else if (verificationStatus == 'Ambiguous') {
                        verificationStatus = 'Ambiguous';
                        message = AMBIGUOUS_VERIFICATION;
                    }
                }

            } catch (ValidationException e) {
                message = e.getMessage();
                error = true;
            }
        }

        result.put('message', message);
        result.put('error', error);
        result.put('verified', verified);
        return result;
    }

    private static Boolean parametersCheck(Map<String, Object> addressParameters) {
        Boolean allChecked = true;
        mailingCity = (String) addressParameters.get('mailingCity');
        mailingCountry = (String) addressParameters.get('mailingCountry');
        mailingPostalCode = (String) addressParameters.get('mailingPostalCode');
        mailingStreet = (String) addressParameters.get('mailingStreet');

        if (String.isBlank(mailingCity)
                || String.isBlank(mailingCountry)
                || String.isBlank(mailingPostalCode)
                || String.isBlank(mailingStreet)) {
            allChecked = false;
        }
        return allChecked;
    }

    private static String generateEndPoint(Map<String, Object> addressParameters) {
        // TODO: Note - This should be move to Auth. Provider, Named Credentials, etc
        //  for the purpose of this demo we are going to insert it here as endpoint
        //  which should never be the case on a real scenario.
        String endPoint = 'https://international-street.api.smartystreets.com/' +
                'verify?auth-id=626a4b52-ee56-6986-14df-5b562a9b1fdf' +
                '&auth-token=1sBsDPtZNKG3Qr3mVM6P';

        String country = '&country=';
        String address1 = '&address1=';
        String address2 = '&address2=';
        String locality = '&locality=';
        String postal_code = '&postal_code=';
        String geocode = '&geocode=true';
        String method = '&method=get';

        mailingCity = EncodingUtil.urlEncode((String) addressParameters.get('mailingCity'), 'UTF-8');
        mailingCountry = EncodingUtil.urlEncode((String) addressParameters.get('mailingCountry'), 'UTF-8');
        mailingPostalCode = EncodingUtil.urlEncode((String) addressParameters.get('mailingPostalCode'), 'UTF-8');
        mailingStreet = EncodingUtil.urlEncode((String) addressParameters.get('mailingStreet'), 'UTF-8');

        endPoint += country + mailingCountry + address1 + mailingStreet +
                address2 + locality + mailingCity + postal_code +
                mailingPostalCode + geocode + method;

        return endPoint;
    }

    public class MailingAddressUpdatedFields {
        public String mailingCountry;
        public String mailingStreet;
        public String mailingPostalCode;
        public String mailingCity;
        public Id recordId;
    }

}