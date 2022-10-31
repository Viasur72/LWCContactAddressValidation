/**
 * Created by cnaranjo on 10/30/22.
 */
@IsTest
public class TestDataFactory {

    public static List<Contact> createContact(Integer numContacts) {
        List<Contact> contacts = createContacts(numContacts);
        insert contacts;
        return contacts;
    }

    public static List<Contact> createContacts(Integer numContacts) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < numContacts; i++) {
            Contact contact = new Contact();
            contact.FirstName = 'FirstNameTest';
            contact.LastName = 'LastNameTest';
            contact.MailingStreet = '234 Test Street';
            contact.MailingCity = 'Amsterdam';
            contact.MailingCountry = 'NL';
            contact.MailingPostalCode = 'ERTG34';
            contacts.add(contact);
        }

        return contacts;
    }
}