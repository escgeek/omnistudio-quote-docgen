@IsTest
public class RCA_QuoteDocGenFlowTest {

    @TestSetup
    static void createData(){
        Account a = RCA_TestFactory.createAccount();
        Contact c = RCA_TestFactory.createContact(a.Id);
        Opportunity o = RCA_TestFactory.createOpportunity(a.Id);
        Quote q = RCA_TestFactory.createQuote(o.Id, true);

        // Create ContentVersion first (Salesforce auto-generates ContentDocumentId)
        ContentVersion cv = new ContentVersion(
            Title = 'TestDoc',
            PathOnClient = 'TestDoc.pdf',
            VersionData = Blob.valueOf('Dummy PDF data')
        );
        insert cv;

        // Re-query to obtain the auto-created ContentDocumentId
        cv = [SELECT Id, ContentDocumentId
            	FROM ContentVersion
            	WHERE Id = :cv.Id
            	LIMIT 1];

        // Create DocumentTemplate
        DocumentTemplate dt = new DocumentTemplate(
            Name = 'CustomerQuoteDoc',
            Type = 'MicrosoftWord',
            TokenMappingType = 'JSON',
            TokenMappingMethodType = 'OmniDataTransform'
        );
        insert dt;

        DocumentTemplateContentDoc linkRecord = new DocumentTemplateContentDoc(
            Name = 'Quote Output Doc',
            FileStageType = 'Original',
            DocumentTemplateId = dt.Id,
            ContentDocumentId = cv.ContentDocumentId
        );
        insert linkRecord;
    }

    // ------------------------------------------------------------
    // SUCCESS TEST
    // ------------------------------------------------------------
    @IsTest
    static void testGenerateSuccess() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];

        Test.startTest();
        RCA_QuoteDocGenFlow.Request req = new RCA_QuoteDocGenFlow.Request();
        req.quoteId = q.Id;
        req.quoteDocName = 'Test Document';

        List<RCA_QuoteDocGenFlow.Result> results = RCA_QuoteDocGenFlow.generate(new List<RCA_QuoteDocGenFlow.Request>{req});
        Test.stopTest();
        Assert.areEqual(1, results.size());
        Assert.areEqual(null, results[0].errorMessage);
        Assert.areEqual(true, results[0].success);
        Assert.areNotEqual(null, results[0].dgpId);
    }

    // ------------------------------------------------------------
    // NEGATIVE TEST - MISSING TEMPLATE
    // ------------------------------------------------------------
    @IsTest
    static void testMissingTemplate() {
        // Remove template + link created in @TestSetup
        delete [SELECT Id FROM DocumentTemplateContentDoc LIMIT 10];
        delete [SELECT Id FROM DocumentTemplate LIMIT 10];

        Quote q = [SELECT Id FROM Quote LIMIT 1];

        RCA_QuoteDocGenFlow.Request req = new RCA_QuoteDocGenFlow.Request();
        req.quoteId = q.Id;
        req.quoteDocName = 'Test Document';

        Test.startTest();
        List<RCA_QuoteDocGenFlow.Result> results = RCA_QuoteDocGenFlow.generate(new List<RCA_QuoteDocGenFlow.Request>{req});
        Test.stopTest();

        Assert.areEqual(false, results[0].success, 'Should fail when template is missing');
        Assert.areNotEqual(null, results[0].errorMessage, 'Should contain an error message');
    }

    @IsTest
    static void testMissingDocumentTemplateContentDoc() {
        // Ensure template still exists
        DocumentTemplate dt = [SELECT Id FROM DocumentTemplate LIMIT 1];

        // Remove only the link so docLinks becomes empty
        delete [SELECT Id FROM DocumentTemplateContentDoc WHERE DocumentTemplateId = :dt.Id LIMIT 10];

        Quote q = [SELECT Id FROM Quote LIMIT 1];

        Test.startTest();
        RCA_QuoteDocGenFlow.Request req = new RCA_QuoteDocGenFlow.Request();
        req.quoteId = q.Id;
        req.quoteDocName = 'Test Document';

        List<RCA_QuoteDocGenFlow.Result> results = RCA_QuoteDocGenFlow.generate(new List<RCA_QuoteDocGenFlow.Request>{req});
        Test.stopTest();

        Assert.areEqual(false, results[0].success);
        Assert.areEqual('DocumentTemplateContentDoc not found for template.', results[0].errorMessage);
    }

    // ------------------------------------------------------------
    // DIRECT TEST OF testDocGen METHOD
    // ------------------------------------------------------------
    @IsTest
    static void testWrapper() {
        Quote q = [SELECT Id FROM Quote LIMIT 1];

        Test.startTest();
        RCA_QuoteDocGenFlow.testDocGen(q.Id);
        Test.stopTest();

        List<DocumentGenerationProcess> dgp = [
            SELECT Id, ReferenceObject
            FROM DocumentGenerationProcess
            WHERE ReferenceObject = :q.Id
        ];

        Assert.areEqual(1, dgp.size());
    }

    @isTest static void testGenerate_ExceptionPath(){
        Id quoteId = [SELECT Id FROM Quote LIMIT 1].Id;
        Test.startTest();
        RCA_QuoteDocGenFlow.throwError = true;
        List<RCA_QuoteDocGenFlow.Result> resultList = RCA_QuoteDocGenFlow.testDocGen(quoteId);
        Test.stopTest();
        for(RCA_QuoteDocGenFlow.Result res : resultList){
            Assert.isFalse(res.success, 'Should return failure');
        }
    }
}