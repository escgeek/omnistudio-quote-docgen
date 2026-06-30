/*
Test Class:RCA_DocGenFunctionsTest
 */
public class RCA_DocGenHelper {

    // ============================================================
    // PUBLIC ENTRY FUNCTIONS
    // ============================================================

    public static String replaceBR(List<Object> args) {
        String inputString = (String) args[0] ?? '';
        if (String.isBlank(inputString)) {
            return inputString;
        }
        return inputString.replaceAll('(?i)<br>', '\n');
    }

    public static List<Object> summarizeQuoteLines(List<Object> args) {
        Set<Id> qliIds = extractIds(args);
        List<QuoteLineItem> qliList = fetchQlis(qliIds);
        List<Object> result = new List<Object>();
        for (QuoteLineItem qli : qliList) {
            RCA_DocGenLineModel m = new RCA_DocGenLineModel();
            m.recordId         = qli.Id;
            m.currencyCode     = qli.CurrencyIsoCode;
            m.productName      = qli.Product2 != null ? qli.Product2.Name : '';
            m.quantity         = (Integer) qli.Quantity;
            m.listPrice        = qli.ListPrice ?? 0;
            m.discount         = qli.Discount ?? 0;
            m.salesPrice       = qli.UnitPrice ?? 0;
            m.salesTotal       = qli.TotalPrice ?? 0;
            m.listPriceString  = RCA_DocGenCurrency.formatCurrency(m.listPrice, m.currencyCode);
            m.salesPriceString = RCA_DocGenCurrency.formatCurrency(m.salesPrice, m.currencyCode);
            m.salesTotalString = RCA_DocGenCurrency.formatCurrency(m.salesTotal, m.currencyCode);
            result.add(m.toMap());
        }
        System.debug('result: ' + result);
        return result;
    }

    // ============================================================
    // VLOCITY → SOQL
    // ============================================================

    private static Set<Id> extractIds(List<Object> args) {
        Set<Id> idSet = new Set<Id>();
        Map<String,Object> root = (Map<String,Object>) args[0];
        Object rawList = root.get('VLOCITY-FORMULA-LIST');

        for (Object e : (List<Object>) rawList) {
            Map<String,Object> row = (Map<String,Object>) e;
            Id idVal = (Id) row.get('Id');
            if (idVal != null) {
                idSet.add(idVal);
            }
        }
        return idSet;
    }

    private static List<QuoteLineItem> fetchQlis(Set<Id> idSet) {
        return [
            SELECT  Id,
                    CurrencyIsoCode,
                    ListPrice,
                    Discount,
                    UnitPrice,
                    TotalPrice,
                    Quantity,
                    Product2.Name
            FROM QuoteLineItem
            WHERE Id IN :idSet
        ];
    }

    // ============================================================
    // FORMATTING HELPERS
    // ============================================================

    public static String formatCurrency(List<Object> args) {
        Double amount = (args[0] != null) ? Double.valueOf(String.valueOf(args[0])) : 0.00;
        String currencyCode = String.valueOf(args[1]) ?? 'USD';

        return RCA_DocGenCurrency.formatCurrency(amount, currencyCode);
    }
}