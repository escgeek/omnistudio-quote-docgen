@IsTest public class RCA_DocGenUtilitiesTest {

    @IsTest static void createDocNameTest(){
        // Data
        Account a = RCA_TestFactory.createAccount();
        Contact c = RCA_TestFactory.createContact(a.Id);
        Opportunity o = RCA_TestFactory.createOpportunity(a.Id);
        Quote q = RCA_TestFactory.createQuote(o.Id, true);
        // Start
        Test.startTest();
        String validateName = RCA_DocGenUtilities.createDocName(q.Id);
        Test.stopTest();
    }

}