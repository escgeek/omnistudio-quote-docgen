@IsTest
public class RCA_DocGenCurrencyTest {

    @IsTest
    static void testSuccess() {
        test.startTest();
        String result1 = RCA_DocGenCurrency.formatCurrency((Double) 1234.56, 'USD');
        String result2 = RCA_DocGenCurrency.formatCurrency((Double) 1234.56, 'EUR');
        String result3 = RCA_DocGenCurrency.formatCurrency((Double) 6500, 'JPY');
        test.stopTest();
        Assert.areEqual('$1,234.56', result1);
        Assert.areEqual('€1.234,56', result2);
        Assert.areEqual('¥6,500', result3);
    }

    @isTest
    static void testFailure(){
        test.startTest();
        String result1 = RCA_DocGenCurrency.formatCurrency((Double) 1234.56, '123');
        test.stopTest();
        Assert.areEqual('$1,234.56', result1);
    }

    @isTest
    static void mapSeparatorTest(){
        List<String> pickListValues = new List<String>{'Comma','Dot','Space','Other'};
        test.startTest();
        for(String s : pickListValues){
            RCA_DocGenCurrency.mapSeparator(s);
        }
        test.stopTest();
    }
    @isTest
    static void inputNumberTest(){
        String inputNumber = '123.45';
        test.startTest();
        String result1 = RCA_DocGenCurrency.applyThousands(inputNumber, '');
        test.stopTest();
        Assert.areEqual(inputNumber, result1);
    }
}