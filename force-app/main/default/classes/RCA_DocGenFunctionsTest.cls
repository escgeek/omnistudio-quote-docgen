/*
Covering the following classes:
- RCA_DocGenFunctions
- RCA_DocGenHelper
- RCA_DocGenLineModel
 */
@IsTest
private class RCA_DocGenFunctionsTest {

    // ------------------------------------------------------------------
    // Helper to invoke Callable
    // ------------------------------------------------------------------
    private static Object callFunction(String action, List<Object> argsList) {
        Map<String, Object> input = new Map<String, Object>{ 'arguments' => argsList };
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> callArgs = new Map<String, Object>{
            'input'   => input,
            'output'  => output,
            'options' => new Map<String, Object>()
        };
        RCA_DocGenFunctions func = new RCA_DocGenFunctions();
        func.call(action, callArgs);
        return output.get('result');
    }

    // ------------------------------------------------------------------
    // replaceBR
    // ------------------------------------------------------------------
    @IsTest
    static void replaceBR_Test() {
        Object result = callFunction('replaceBR', new List<Object>{
            'A<br>B<BR>C<Br>'
        });
        Assert.areEqual('A\nB\nC\n', result);
    }

    @IsTest
    static void replaceBR_Blank_Test() {
        Object result = callFunction('replaceBR', new List<Object>{ '' });
        Assert.areEqual('', result);
    }

    // ------------------------------------------------------------------
    // summarizeQuoteLines
    // ------------------------------------------------------------------
    @IsTest
    static void summarizeQuoteLines_Test() {

        Account a = RCA_TestFactory.createAccount();
        Contact c = RCA_TestFactory.createContact(a.Id);

        Product2 prod = RCA_TestFactory.createProduct();
        PricebookEntry pbe = RCA_TestFactory.createPricebookEntry(prod.Id, 100);
        Opportunity o = RCA_TestFactory.createOpportunity(a.Id);
        Quote q = RCA_TestFactory.createQuote(o.Id, true);
        QuoteLineItem qli = RCA_TestFactory.createQuoteLineItem(q.Id, prod.Id, pbe.Id, 100, 1);

        List<Object> wrapperList = new List<Object>{
            new Map<String,Object>{ 'Id' => qli.Id }
        };
        Map<String,Object> wrapper = new Map<String,Object>{
            'VLOCITY-FORMULA-LIST' => wrapperList
        };

        Test.startTest();
        Object result = callFunction('summarizeQuoteLines', new List<Object>{ wrapper });
        Test.stopTest();

        List<Object> finalOut = (List<Object>) result;
        Assert.areEqual(1, finalOut.size());

        Map<String,Object> row = (Map<String,Object>) finalOut[0];
        Assert.areEqual(prod.Name, row.get('productName'));
        Assert.areEqual(1, row.get('quantity'));
        Assert.areNotEqual(null, row.get('listPriceString'));
        Assert.areNotEqual(null, row.get('salesPriceString'));
        Assert.areNotEqual(null, row.get('salesTotalString'));
    }

    // ------------------------------------------------------------------
    // formatCurrency
    // ------------------------------------------------------------------
    @IsTest
    static void formatCurrency_Test() {
        // Simple USD test
        Object resultUsd = callFunction(
            'formatCurrency',
            new List<Object>{ 1234.56, 'USD' }
        );
        Assert.areEqual('$1,234.56', resultUsd, 'USD formatting incorrect');

        // Test with null currency -> should fallback to USD
        Object resultNull = callFunction(
            'formatCurrency',
            new List<Object>{ 1000, null }
        );
        Assert.areEqual('$1,000.00', resultNull, 'Null currency fallback incorrect');

        // EUR test only works if metadata exists - so we skip asserting exact output,
        // but we verify no exception and non-empty output.
        Object resultEur = callFunction(
            'formatCurrency',
            new List<Object>{ 1234.56, 'EUR' }
        );
        Assert.areNotEqual(null, resultEur, 'EUR result should not be null');
        Assert.areNotEqual('', resultEur, 'EUR result should not be blank');
    }
}