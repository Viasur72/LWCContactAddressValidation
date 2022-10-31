/**
 * Created by cnaranjo on 10/29/22.
 */

public with sharing class ValidationAddressListsInput {

        public class Components {
            public String administrative_area;
            public String administrative_area_long;
            public String administrative_area_short;
            public String country_iso_3;
            public String locality;
            public String postal_code;
            public String postal_code_short;
            public String premise;
            public String premise_number;
            public String thoroughfare;
            public String thoroughfare_name;
            public String thoroughfare_trailing_type;
        }

        public class Changes {
            public Components_Z components;
        }

        public String address1;
        public String address2;
        public Components components;
        public Metadata metadata;
        public Analysis analysis;

        public class Analysis {
            public String verification_status;
            public String address_precision;
            public String max_address_precision;
            public Changes changes;
        }

        public class Metadata {
            public String address_format;
        }

        public class Components_Z {
            public String administrative_area;
            public String locality;
            public String postal_code_short;
            public String premise;
            public String thoroughfare;
            public String thoroughfare_type;
        }

    }
