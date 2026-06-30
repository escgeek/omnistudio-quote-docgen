/*
Test Class:RCA_DocGenFunctionsTest
 */
public class RCA_DocGenLineModel {

    public Id recordId;
    public String currencyCode;
    public String productName = '';
    public Integer quantity = 1;
    public Double listPrice = 0;
    public Double discount = 0;
    public Double salesPrice = 0;
    public Double salesTotal = 0;
    public String listPriceString;
    public String salesPriceString;
    public String salesTotalString;

    public Map<String,Object> toMap() {
        return new Map<String,Object>{
            'recordId'         => recordId,
            'currencyCode'     => currencyCode,
            'productName'      => productName,
            'quantity'         => quantity,
            'listPrice'        => listPrice,
            'discount'         => discount,
            'salesPrice'       => salesPrice,
            'salesTotal'       => salesTotal,
            'listPriceString'  => listPriceString,
            'salesPriceString' => salesPriceString,
            'salesTotalString' => salesTotalString
        };
    }
}