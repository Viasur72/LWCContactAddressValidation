/**
 * Created by cnaranjo on 10/31/22.
 */
@IsTest
private class LWC_ContactAddressValidationTest {

    @TestSetup
    static void setup() {
        TestDataFactory.createContact(1).get(0);
    }

    private static Contact getContact() {
        return [
                SELECT Id, FirstName, LastName, MailingStreet, Address_Verified__c,
                        MailingCity, MailingCountry, MailingPostalCode
                FROM Contact
                WHERE FirstName = 'FirstNameTest'
        ];
    }

    @IsTest
    static void testLoadContact() {
        //Give
        Contact contact = getContact();

        // When
        Test.startTest();
        Contact returnedContact = LWC_ContactAddressValidation.loadContact(contact.Id);
        Test.stopTest();
    }

    @IsTest
    static void testValidationAddressInputFields() {
        //Give
        Map<String, Object> addressParameters = getContactWithParameters();
        Test.setMock(HttpCalloutMock.class, new LWC_ContactAddressValidationMockCallout());

        // When
        Test.startTest();
        Map<String, Object> result = LWC_ContactAddressValidation.validationAddressInputFields(addressParameters);
        Test.stopTest();

    }

    @IsTest
    static void testValidationAddressUpdateFields() {
        //Give
        Map<String, Object> addressParameters = getContactWithParameters();

        // When
        Test.startTest();
        Map<String, Object> result = LWC_ContactAddressValidation.validationAddressUpdateFields(addressParameters);
        Test.stopTest();

    }

    @IsTest
    static void testValidationAddressUpdateFieldsOneFieldMissing() {
        //Give
        String message = LWC_ContactAddressValidation.PLEASE_FILL_ALL_FIELDS_ON_UPDATE;
        Map<String, Object> addressParameters = getContactWithParametersWithNullValue();

        // When
        Test.startTest();
        Map<String, Object> result = LWC_ContactAddressValidation.validationAddressUpdateFields(addressParameters);
        Test.stopTest();

        // Then
        System.assertEquals(result.get('message'), message, 'Message is not the correct one');
        System.assertEquals(result.get('error'), true, 'Error value is not the correct one');
    }

    @IsTest
    static void testValidationAddressUpdateFieldsMailingCountryToShort() {
        //Give
        String message = LWC_ContactAddressValidation.COUNTRY_LENGTH_TOO_SHORT_ON_UPDATE;
        Map<String, Object> addressParameters = getContactWithParameters();
        addressParameters.put('mailingCountry', 'A');

        // When
        Test.startTest();
        Map<String, Object> result = LWC_ContactAddressValidation.validationAddressUpdateFields(addressParameters);
        Test.stopTest();

        // Then
        System.assertEquals(result.get('message'), message, 'Message is not the correct one');
        System.assertEquals(result.get('error'), true, 'Error value is not the correct one');
    }

    @IsTest
    static void testValidationAddressInputFieldsOneFieldMissing() {
        //Give
        LWC_ContactAddressValidation.allowHTTPCallout = false;
        String message = LWC_ContactAddressValidation.PLEASE_FILL_ALL_FIELDS;
        Map<String, Object> addressParameters = getContactWithParametersWithNullValue();

        // When
        Test.startTest();
        Map<String, Object> result = LWC_ContactAddressValidation.validationAddressInputFields(addressParameters);
        Test.stopTest();

        // Then
        System.assertEquals(result.get('message'), message, 'Message is not the correct one');
        System.assertEquals(result.get('error'), true, 'Error value is not the correct one');
    }

    @IsTest
    static void testValidationAddressInputFieldsMailingCodeToShort() {
        //Give
        LWC_ContactAddressValidation.allowHTTPCallout = false;
        String message = LWC_ContactAddressValidation.COUNTRY_LENGTH_TOO_SHORT;
        Map<String, Object> addressParameters = getContactWithParameters();
        addressParameters.put('mailingCountry', 'A');

        // When
        Test.startTest();
        Map<String, Object> result = LWC_ContactAddressValidation.validationAddressInputFields(addressParameters);
        Test.stopTest();

        // Then
        System.assertEquals(result.get('message'), message, 'Message is not the correct one');
        System.assertEquals(result.get('error'), true, 'Error value is not the correct one');
    }

    @IsTest
    static Map<String, Object> getContactWithParameters() {
        Contact contact = getContact();
        Map<String, Object> addressParameters = new Map<String, Object>();
        addressParameters.put('mailingCountry', 'AUS');
        addressParameters.put('mailingPostalCode', '5212');
        addressParameters.put('mailingStreet', '14 Frenchman Drive');
        addressParameters.put('mailingCity', 'Port Elliot');
        addressParameters.put('recordId', contact.Id);

        return addressParameters;
    }

    static Map<String, Object> getContactWithParametersWithNullValue() {
        Contact contact = getContact();
        Map<String, Object> addressParameters = new Map<String, Object>();
        addressParameters.put('mailingCountry', 'AUS');
        addressParameters.put('mailingPostalCode', null);
        addressParameters.put('mailingStreet', '14 Frenchman Drive');
        addressParameters.put('mailingCity', 'Port Elliot');
        addressParameters.put('recordId', contact.Id);

        return addressParameters;
    }

}