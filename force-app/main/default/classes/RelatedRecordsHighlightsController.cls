public with sharing class RelatedRecordsHighlightsController {

    @TestVisible
    public static RelatedRecordsHighlightsController.Selector recordsSelector;
    @TestVisible
    public static Map<String, Related_Records_Highlight_Panel_Setting__mdt> settings;
    @TestVisible
    public static Boolean throwException = false;
    @TestVisible
    public static Boolean throwQueryException = false;

    @AuraEnabled
    public static List<HighlightItemWrapper> getHighlightItems(
        String recordId,
        String componentId
    ) {
        recordsSelector = new Selector();
        Map<String, List<String>> errorMap = new Map<String, List<String>>();
        try {
            if(Test.isRunningTest() && throwException){
                throw new QueryException();
            }

            List<HighlightItemWrapper> wrappers = new List<HighlightItemWrapper>();

            if(settings == null){
                settings = Related_Records_Highlight_Panel_Setting__mdt.getAll();
            }

            Integer itemIdIterator = 0;
            for (
                Related_Records_Highlight_Panel_Setting__mdt setting : settings.values()
            ) {
                List<String> componentIds = setting.Component_Id__c
                    ?.split(',') ?? new List<String>();

                if (!componentIds.contains(componentId)) {
                    continue;
                }

                Map<String, String> binds = new Map<String, String>{
                    'recordId' => recordId
                };
                String query = setting.Items_Query__c;

                String currentItemId = 'HI' + itemIdIterator;

                HighlightItemWrapper wrapper = new HighlightItemWrapper();
                wrapper.itemId = currentItemId;
                wrapper.header = setting.Item_Name__c;
                wrapper.icon = setting.Icon__c;
                wrapper.sortOrder = (Integer) setting.Sort_Order__c;
                try {
                    if(Test.isRunningTest() && throwQueryException){
                        throw new QueryException('Testing Exception');
                    }
                    List<SObject> records = recordsSelector.getRecordsDynamic(
                        query,
                        binds,
                        AccessLevel.USER_MODE
                    );

                    wrapper.records = records;
                    wrapper.numOfItems = records?.size();
                    wrapper.fields = parseForFieldLabel(
                        setting.Table_Columns__c.split(','),
                        setting.SObject_Name__c
                    );
                } catch (QueryException qe) {
                    wrapper.numOfItems = 0;
                    wrapper.records = null;
                    wrapper.errors = new List<String>{
                        formatErrorMessage(qe, setting.Item_Name__c)
                    };
                }
                wrappers.add(wrapper);
                itemIdIterator++;
            }
            wrappers.sort();
            return wrappers;
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String formatErrorMessage(Exception ex, String itemName) {
        return String.format(
            '{0} query failed due to: "{1}"',
            new List<String>{ itemName, ex.getMessage() }
        );
    }

    private static List<Field> parseForFieldLabel(
        List<String> fieldsToParse,
        String ObjectName
    ) {
        List<Field> fieldList = new List<Field>();

        Schema.DescribeSObjectResult result = Schema.describeSObjects(
            new List<String>{ ObjectName }
        )[0];
        Map<String, Schema.SObjectField> fieldsMap = result.fields.getMap();
        for (String name : fieldsToParse) {
            Field f = new Field(
                fieldsMap?.get(name)?.getDescribe()?.getLabel(),
                name
            );
            fieldList.add(f);
        }
        return fieldList;
    }

    @TestVisible
    private virtual with sharing class Selector {
        public virtual List<SObject> getRecordsDynamic (String query,Map<String,String> binds,AccessLevel queryMode){
            return (List<SObject>) Database.queryWithBinds(
                query,
                binds,
                queryMode
            );
        }
    }

    public class HighlightItemWrapper implements Comparable {
        @AuraEnabled
        public String itemId { get; set; }
        @AuraEnabled
        public String header { get; set; }
        @AuraEnabled
        public String icon { get; set; }
        @AuraEnabled
        public Integer numOfItems { get; set; }
        @AuraEnabled
        public Integer sortOrder { get; set; }
        @AuraEnabled
        public List<Field> fields { get; set; }
        @AuraEnabled
        public List<SObject> records { get; set; }
        @AuraEnabled
        public List<String> errors { get; set; }

        public Integer compareTo(Object compareTo) {
            HighlightItemWrapper compareToWrapper = (HighlightItemWrapper) compareTo;
            if (sortOrder == compareToWrapper.sortOrder)
                return 0;
            if (sortOrder > compareToWrapper.sortOrder)
                return 1;
            return -1;
        }
    }

    public class Field {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String name;

        public Field(String label, String name) {
            this.label = label;
            this.name = name;
        }
    }
}
