/**
 * Created by cnaranjo on 10/30/22.
 */
@IsTest
private class ContactServiceTest {

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
    private static void testUpdateAddressValidationField() {
        //Given
        Contact contact = getContact();

        //When
        Test.startTest();
        ContactService.getInstance().updateAddressValidationField(contact.Id);
        Test.stopTest();

        //Then
        Contact afterContact = [SELECT Address_Verified__c FROM Contact];
        System.assertEquals(true, afterContact.Address_Verified__c, 'Address_Verified__c input incorrect');
    }

    @IsTest
    private static void updateAddressValidationField() {
        //Given
        Contact contact = getContact();
        LWC_ContactAddressValidation.MailingAddressUpdatedFields updatedFields =
                new LWC_ContactAddressValidation.MailingAddressUpdatedFields();

        updatedFields.mailingStreet = '2 Test Straat';
        updatedFields.mailingCity = 'Den Haag';
        updatedFields.mailingCountry = 'BE';
        updatedFields.mailingPostalCode = 'AAEE55';
        updatedFields.recordId = contact.Id;

        //When
        Test.startTest();
        ContactService.getInstance().updateMailingAddressFields(updatedFields);
        Test.stopTest();

        //Then
        Contact afterContact = [SELECT MailingStreet, MailingCity, MailingCountry, MailingPostalCode FROM Contact];
        System.assertEquals('2 Test Straat', afterContact.MailingStreet, 'MailingStreet input incorrect');
        System.assertEquals('Den Haag', afterContact.MailingCity, 'MailingCity input incorrect');
        System.assertEquals('BE', afterContact.MailingCountry, 'MailingCountry input incorrect');
        System.assertEquals('AAEE55', afterContact.MailingPostalCode, 'MailingPostalCode input incorrect');
    }

}