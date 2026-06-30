@isTest
public class RCA_QuoteDocGenCheckerTest {

    private static DocumentGenerationProcess createDgp(String statusValue) {
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
        cv = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
            LIMIT 1
        ];

        // Create DocumentTemplate
        DocumentTemplate tmpl = new DocumentTemplate(
            Name = 'CustomerQuoteDoc',
            Type = 'MicrosoftWord',
            TokenMappingType = 'JSON',
            TokenMappingMethodType = 'OmniDataTransform'
        );
        insert tmpl;

        DocumentTemplateContentDoc linkRec = new DocumentTemplateContentDoc(
            Name = 'Quote Output Doc',
            FileStageType = 'Original',
            DocumentTemplateId = tmpl.Id,
            ContentDocumentId = cv.ContentDocumentId
        );
        insert linkRec;

        Id fakeDocTempId = RCA_TestFactory.generateRecordId('DocumentTemplate');

         Map<String, Object> requestData = new Map<String, Object>{
            'keepIntermediate' => false,
            'title' => 'TestPDF',
            'templateContentVersionId' => cv.Id
        };

        DocumentGenerationProcess dgp = new DocumentGenerationProcess();
        dgp.Status = statusValue;
        dgp.ReferenceObject = q.Id;
        dgp.DocumentInputType = 'DocumentTemplate';
        dgp.DocGenApiVersionType = 'Advanced';
        dgp.Type = 'GenerateAndConvert';

        dgp.DataRaptorInput = '{"Id":"' + q.Id + '"}';
        dgp.DocumentTemplateId = tmpl.Id;
        dgp.RequestText = JSON.serialize(requestData);

        insert dgp;
        return dgp;
    }

    @isTest
    static void testGetProcessStatusSuccess() {
        DocumentGenerationProcess dgp = createDgp('Success');
        // Test
        Test.startTest();
        String result = RCA_QuoteDocGenChecker.getProcessStatus(dgp.Id);
        Test.stopTest();
        // Validate
        Assert.areEqual('Success', result, 'Status should return Success');
    }

    @isTest
    static void testGetProcessStatusFailure() {
        DocumentGenerationProcess dgp = createDgp('Failure');
        // Test
        Test.startTest();
        String result = RCA_QuoteDocGenChecker.getProcessStatus(dgp.Id);
        Test.stopTest();
        // Validate
        Assert.areEqual('Failure', result, 'Status should return Failure');
    }

    @isTest
    static void testGetProcessStatusInProgress() {
        DocumentGenerationProcess dgp = createDgp('InProgress');
        // Test
        Test.startTest();
        String result = RCA_QuoteDocGenChecker.getProcessStatus(dgp.Id);
        Test.stopTest();
        // Validate
        Assert.areEqual('InProgress', result, 'Status should return InProgress');
    }

    @isTest
    static void testNullIdThrowsError() {
        String errorMessage;
        String expectedErrorMessage = 'Error retrieving DocumentGenerationProcess: List has no rows for assignment to SObject';
        // Test
        Test.startTest();
        try {
            RCA_QuoteDocGenChecker.getProcessStatus(null);
        } catch (Exception ex) {
            System.debug('Exception Thrown Message: ' + ex.getMessage());
            // Validate
            errorMessage = ex.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(errorMessage, expectedErrorMessage, 'Expected an error message.');
    }
}