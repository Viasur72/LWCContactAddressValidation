/**
 * Created by cnaranjo on 10/29/22.
 */

public inherited sharing class ContactService implements IContactService {

    private static final fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<SObjectType>{
                    Contact.SObjectType
            });

    @TestVisible
    private static IContactService instance;

    public static IContactService getInstance() {
        if (instance == null) {
            instance = new ContactService();
        }
        return instance;
    }

    public interface IContactService {
        void updateAddressValidationField(Id recordId);
        void updateMailingAddressFields(LWC_ContactAddressValidation.MailingAddressUpdatedFields updatedFields);
    }

    public static void updateAddressValidationField(Id recordId) {
        List<Contact> contacts = [SELECT Address_Verified__c FROM Contact WHERE Id = :recordId];
        for (Contact contact : contacts) {
            contact.Address_Verified__c = true;
            uow.registerDirty(contact);
        }

        uow.commitWork();
    }

    public static void updateMailingAddressFields(LWC_ContactAddressValidation.MailingAddressUpdatedFields updatedFields) {
        List<Contact> contacts = [
                SELECT MailingStreet, MailingCity, MailingCountry, MailingPostalCode
                FROM Contact
                WHERE Id = :updatedFields.recordId
        ];

        for (Contact contact : contacts) {
            if (contact.MailingStreet != updatedFields.mailingStreet) {
                contact.MailingStreet = updatedFields.mailingStreet;
            }
            if (contact.MailingCity != updatedFields.mailingCity) {
                contact.MailingCity = updatedFields.mailingCity;
            }
            if (contact.MailingCountry != updatedFields.mailingCountry) {
                contact.MailingCountry = updatedFields.mailingCountry;
            }
            if (contact.MailingPostalCode != updatedFields.mailingPostalCode) {
                contact.MailingPostalCode = updatedFields.mailingPostalCode;
            }

            uow.registerDirty(contact);
        }

        uow.commitWork();
    }

}