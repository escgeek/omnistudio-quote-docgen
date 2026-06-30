@IsTest
public class RCA_DocGenListViewTest {

    @IsTest
    static void docGenListViewTest() {
        // Data
        Account acc = RCA_TestFactory.createAccount();
        Opportunity opp = RCA_TestFactory.createOpportunity(acc.Id);
        Quote q = RCA_TestFactory.createQuote(opp.Id, true);

        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test PDF content')
        );
        insert cv;

        // Query ContentDocumentId after insert
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = q.Id,
            ShareType = 'V'
        );
        insert cdl;

        Test.startTest();
        Integer countResult = RCA_DocGenListView.getTotalCount(q.Id);
        List<SObject> data = RCA_DocGenListView.getData(
            0,                              // startIndex
            10,                             // batchSize
            q.Id,                           // recordId
            'ContentDocument.CreatedDate',  // sortBy
            'DESC'                          // sortDirection
        );
        Test.stopTest();

        System.assertEquals(1, countResult, 'Should count 1 linked ContentDocument');
        System.assertEquals(1, data.size(), 'Should return exactly 1 row');
        ContentDocumentLink returned = (ContentDocumentLink) data[0];
        System.assertEquals(cv.ContentDocumentId, returned.ContentDocumentId, 'Returned doc ID must match');
    }
}