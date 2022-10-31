import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { fireToast } from 'c/lwcutils';
import apexAddressInputFields from '@salesforce/apex/LWC_ContactAddressValidation.validationAddressInputFields';
import apexAddressUpdateFields from '@salesforce/apex/LWC_ContactAddressValidation.validationAddressUpdateFields';
import MAILING_STREET from '@salesforce/schema/Contact.MailingStreet';
import MAILING_CITY from '@salesforce/schema/Contact.MailingCity';
import MAILING_COUNTRY from '@salesforce/schema/Contact.MailingCountry';
import MAILING_POSTAL_CODE from '@salesforce/schema/Contact.MailingPostalCode';
import ADDRESS_VERIFIED from '@salesforce/schema/Contact.Address_Verified__c';

const fields = [MAILING_STREET, MAILING_CITY, MAILING_COUNTRY, MAILING_POSTAL_CODE, ADDRESS_VERIFIED];

export default class Contactaddressvalidation extends LightningElement {
  @api recordId;
  @track showspinner = false;
  @track addressVerified;
  @track errorMessage;
  @track validated;
  @track mailingCity;
  @track mailingCountry;
  @track mailingPostalCode;
  @track mailingStreet;
  @track overwriteAddress = true;

  @wire(getRecord, { recordId: '$recordId', fields })
  contact ({ error, data }) {
    if (error) {
      this.errorMessage = error;
    } else if (data) {
      this.mailingCity = data.fields.MailingCity.value;
      this.mailingCountry = data.fields.MailingCountry.value;
      this.mailingPostalCode = data.fields.MailingPostalCode.value;
      this.mailingStreet = data.fields.MailingStreet.value;
      this.addressVerified = data.fields.Address_Verified__c.value;

      if (this.addressVerified) {
        this.validated = true;
      }
    }
  }

  handleFieldChange (event) {
    if (event.target.name === 'mailingStreet') {
      this.mailingStreet = event.target.value;
      this.overwriteAddress = false;
    }
    if (event.target.name === 'mailingCity') {
      this.mailingCity = event.target.value;
      this.overwriteAddress = false;
    }
    if (event.target.name === 'mailingPostalCode') {
      this.mailingPostalCode = event.target.value;
      this.overwriteAddress = false;
    }
    if (event.target.name === 'mailingCountry') {
      this.mailingCountry = event.target.value;
      this.overwriteAddress = false;
    }
  }

  submitValidation () {
    let spinner = this.template.querySelector('c-lwcspinner');
    spinner.openSpinner();

    let addressParameters = {};
    addressParameters.mailingStreet = this.mailingStreet;
    addressParameters.mailingCountry = this.mailingCountry;
    addressParameters.mailingPostalCode = this.mailingPostalCode;
    addressParameters.mailingCity = this.mailingCity;
    addressParameters.recordId = this.recordId;

    apexAddressInputFields({
      addressParameters: addressParameters
    })
      .then(result => {
        if (result['error']) {
          fireToast(this, 'error', 'Error', result['message']);
        } else {
          if (result['verified']) {
            this.validated = true;
            fireToast(this, 'success', 'Success', result['message']);
          } else {
            this.validated = false;
            fireToast(this, 'success', 'Success', result['message']);
          }
        }
      })
      .catch(error => {
        fireToast(this, 'error', 'Error', 'Something went wrong');
        console.log('Something went wrong');
      })
      .finally(() => {
        spinner.closeSpinner();
      });
  }

  updateAddress () {
    let spinner = this.template.querySelector('c-lwcspinner');
    spinner.openSpinner();

    let addressParameters = {};
    addressParameters.mailingStreet = this.mailingStreet;
    addressParameters.mailingCountry = this.mailingCountry;
    addressParameters.mailingPostalCode = this.mailingPostalCode;
    addressParameters.mailingCity = this.mailingCity;
    addressParameters.recordId = this.recordId;

    apexAddressUpdateFields({
      addressParameters: addressParameters
    })
      .then(result => {
        if (result['error']) {
          fireToast(this, 'error', 'Error', result['message']);
        } else {
          fireToast(this, 'success', 'Success', result['message']);
        }
      })
      .catch(error => {
        fireToast(this, 'error', 'Error', 'Something went wrong');
        console.log('Something went wrong');
      })
      .finally(() => {
        spinner.closeSpinner();
        getRecordNotifyChange([{ recordId: this.recordId }]);
        this.overwriteAddress = true;
      });
  }

}