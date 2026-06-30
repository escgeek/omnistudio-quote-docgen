@isTest
public class RCA_TestFactory {

    public static Pricebook2 pb;

    public static Map<String, SObject> recordsMap = new Map<String, SObject>();

    public static void register(String objectName, SObject so){
        recordsMap.put(objectName, so);
    }

    public static Account createAccount(){
        return createAccount(true);
    }
    public static Account createAccount(Boolean insertFlag){
        String salt = salt();
        //Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        Account a = new Account(
            Name = salt + ' CPQ Test Account',
            Type = 'Prospect',
            BillingStreet = salt + ' Market Street',
            BillingCity = 'San Francisco',
            BillingState = 'California',
            BillingPostalCode = '94105',
            BillingCountry = 'United States',
            ShippingStreet = salt + ' Market Street',
            ShippingCity = 'San Francisco',
            ShippingState = 'California',
            ShippingPostalCode = '94105',
            ShippingCountry = 'United States'
        );
        if(insertFlag){
            insert a;
            register('Account', a);
        }
        return a;
    }

        public static Contact createContact(Id accountId){
        return createContact(accountId,true);
    }
    public static Contact createContact(Id accountId, Boolean insertFlag){
        String uniqueLastName = salt() + 'Elwood';
        Contact c = new Contact(
            FirstName = 'Jake',
            LastName = uniqueLastName,
            Email = 'Jake.' + uniqueLastName + '@gmail.com',
            AccountId = accountId,
            MailingStreet = salt() + ' W Addison St',
            MailingCity = 'Chicago',
            MailingState = 'Illinois',
            MailingPostalCode = '60613',
            MailingCountry = 'United States',
            LeadSource = 'Web'
        );
        if(insertFlag){
            insert c;
        }
        return c;
    }

    public static Opportunity createOpportunity(Id accountId){
        return createOpportunity(accountId,true);
    }
    public static Opportunity createOpportunity(Id accountId, boolean insertFlag){
        Date closeDate = Date.today().addMonths(1).toStartOfMonth().addDays(-1); // End of the current month
        Opportunity newOpp = new Opportunity(
            Name = 'RCA Test Opportunity - ' +  datetime.now().format(),
            AccountId = accountId,
            CloseDate = closeDate,
            //Pricebook2Id = priceBookId,
            StageName = 'Qualification' // Update this to your org's first opportunity stage
        );
        if(insertFlag){
            insert newOpp;
            register('Opportunity', newOpp);
        }
        return newOpp;
    }

    public static Quote createQuote(Id opportunityId, boolean insertFlag) {
        pb = (pb == null) ? createPriceBook('Sales', true) : pb;
        Quote q = new Quote(
            Name = 'RCA Test Quote - ' +  datetime.now().format(),
            OpportunityId = opportunityId,
            Pricebook2Id = pb.Id
        );
        if(insertFlag){
            insert q;
            register('Quote', q);
        }
        return q;
    }

    public static QuoteLineItem createQuoteLineItem(Id quoteId, Id productId, Id pbeId, Decimal unitPrice, Decimal quantity) {
        QuoteLineItem quoteLineItem = new QuoteLineItem(
            PricebookEntryId = pbeId,
            QuoteId = quoteId,
            Product2Id = productId,
            UnitPrice = unitPrice,
            Quantity = quantity
        );
        insert quoteLineItem;
        return quoteLineItem;
    }

    public static Product2 createProduct(){
        return createProduct(true);
    }
    public static Product2 createProduct(boolean insertFlag){
        Product2 p = new Product2(
            isActive = true,
            Name = 'Laptop',
            ProductCode = 'MODEL###' + String.valueOf(Math.random()).substring(2, 6)
        );
        if(insertFlag){ insert p; }
        return p;
    }

    public static PricebookEntry createPricebookEntry(Id pId, Decimal salesPrice){
        pb = (pb == null) ? createPriceBook('Sales', true) : pb;
        Id spbId = Test.getStandardPricebookId();
        salesPrice = (salesPrice == NULL) ? 0 : salesPrice;
        // Standard Price Book Entry
        PricebookEntry pbEntry = createPBERecord(spbId, pId, salesPrice);
        insert pbEntry;
        // Specific Test Price Book Entry
        pbEntry = createPBERecord(pb.Id, pId, salesPrice);
        insert pbEntry;
        return pbEntry;
    }
    //
    public static PricebookEntry createPBERecord(Id pbId, Id pId, Decimal salesPrice){
        return new PricebookEntry(
            pricebook2id = pbId,
            product2id = pId,
            unitprice = salesPrice,
            isActive = true
        );
    }
    //
    public static Pricebook2 createPriceBook(String pbName, boolean insertFlag){
        Pricebook2 pbook = new pricebook2(
            Name = pbName,
            IsActive = true
        );
        if(insertFlag){ insert pbook; }
        return pbook;
    }
    //
    public static String salt(){
        Datetime uniqueDate = dateTime.now();
        return uniqueDate.format('HHmmss');
    }
    /*********************************************************************************************
     * Generates a fake Salesforce Id that can be used in your test factory or
     * as a separate utility for generating record id's
     * Source from fflib_IDGenerator with a small update to make it easier to use
    *********************************************************************************************/
    private static Integer fakeIdCount = 0;
	private static final String ID_PATTERN = '000000000000';
	public static Id generateRecordId(String objectName){
        // Usage:
        // Id accountId = RCA_UtilityClass.generateRecordId('Account');
        // Debug returns: 001000000000001AAA, 001000000000002AAA, etc.
		fakeIdCount++;
        String keyPrefix = Schema.getGlobalDescribe().get(objectName)?.getDescribe().getKeyPrefix();
		String fakeIdPrefix = ID_PATTERN.substring(0, 12 - fakeIdCount.format().length());
		return Id.valueOf(keyPrefix + fakeIdPrefix + fakeIdCount);
	}

}