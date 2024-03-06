@IsTest
public with sharing class RelatedRecordsHighlightsControllerTests {

    @isTest
    private static void three_highlights_should_be_returned_when_three_have_been_configured() {
        // Test data setup
        List<Contact> fakeContacts = new List<Contact>();
        for(Integer i = 0; i < 20; i++){
            Contact c = new Contact(
                FirstName = 'test',
                LastName = 'test'+i
            );
            fakeContacts.add(c);
        } 
        
        List<Case> fakeCases = new List<Case>();
        for(Integer i = 0; i < 20; i++){
            Case c = new Case(
                Subject = 'test ' + i,
                description = 'test'
            );
            fakeCases.add(c);
        } 
        FakeSelector selector = new FakeSelector(fakeCases,fakeContacts);

        Map<String, Related_Records_Highlight_Panel_Setting__mdt> settings = generateSettingsMap();

        RelatedRecordsHighlightsController.settings = settings;
        RelatedRecordsHighlightsController.recordsSelector = selector;

        // Actual test
        Test.startTest();
        List<RelatedRecordsHighlightsController.HighlightItemWrapper> wrappers = RelatedRecordsHighlightsController.getHighlightItems('SomeId','AccountPage');
        Test.stopTest();
    
        // Asserts
        Assert.isNotNull(wrappers);
        Assert.areEqual(3,wrappers.size());
    }
    @isTest
    private static void should_only_return_wrappers_for_the_provided_componentId() {
        // Test data setup
        List<Contact> fakeContacts = new List<Contact>();
        for(Integer i = 0; i < 5; i++){
            Contact c = new Contact(
                FirstName = 'test',
                LastName = 'test'+i
            );
            fakeContacts.add(c);
        } 
        
        List<Case> fakeCases = new List<Case>();
        for(Integer i = 0; i < 5; i++){
            Case c = new Case(
                Subject = 'test ' + i,
                description = 'test'
            );
            fakeCases.add(c);
        } 
        FakeSelector selector = new FakeSelector(fakeCases,fakeContacts);

        Map<String, Related_Records_Highlight_Panel_Setting__mdt> settings = generateSettingsMap();
        settings.get('Cases').Component_Id__c = '';

        RelatedRecordsHighlightsController.settings = settings;
        RelatedRecordsHighlightsController.recordsSelector = selector;

        // Actual test
        Test.startTest();
        List<RelatedRecordsHighlightsController.HighlightItemWrapper> wrappers = RelatedRecordsHighlightsController.getHighlightItems('SomeId','AccountPage');
        Test.stopTest();
    
        // Asserts
        Assert.isNotNull(wrappers);
        Assert.areEqual(2,wrappers.size());
    }
    @isTest
    private static void failed_query_should_return_wrapper_with_error() {
        // Test data setup
        List<Contact> fakeContacts = new List<Contact>();
        for(Integer i = 0; i < 5; i++){
            Contact c = new Contact(
                FirstName = 'test',
                LastName = 'test'+i
            );
            fakeContacts.add(c);
        } 
        
        List<Case> fakeCases = new List<Case>();
        for(Integer i = 0; i < 5; i++){
            Case c = new Case(
                Subject = 'test ' + i,
                description = 'test'
            );
            fakeCases.add(c);
        } 
        FakeSelector selector = new FakeSelector(fakeCases,fakeContacts);

        Map<String, Related_Records_Highlight_Panel_Setting__mdt> settings = generateSettingsMap();
        
        RelatedRecordsHighlightsController.settings = new Map<String,Related_Records_Highlight_Panel_Setting__mdt>{'Cases' => settings.get('Cases')};
        RelatedRecordsHighlightsController.recordsSelector = selector;
        RelatedRecordsHighlightsController.throwQueryException = true;

        // Actual test
        Test.startTest();
        List<RelatedRecordsHighlightsController.HighlightItemWrapper> wrappers = RelatedRecordsHighlightsController.getHighlightItems('SomeId','AccountPage');
        Test.stopTest();
    
        // Asserts
        Assert.isTrue(wrappers[0].errors.size() > 0,'The wrapper should have errors.');
        Assert.isTrue(wrappers[0].numOfItems == 0,'The wrapper record counter should be 0');
        Assert.isNull(wrappers[0].records,'There should be no records in this wrapper.');
    }
    @IsTest
    private static void generic_uncaught_exception_should_be_rethrown_as_aurahandeledException(){
        RelatedRecordsHighlightsController.throwException = true;

        Exception caughtException;
        try {
            List<RelatedRecordsHighlightsController.HighlightItemWrapper> wrappers = RelatedRecordsHighlightsController.getHighlightItems('SomeId','AccountPage');
        }catch(Exception ex){
            caughtException = ex;
        }

        Assert.isNotNull(caughtException, 'An exception should have been caught.');
        Assert.isInstanceOfType(caughtException, AuraHandledException.class,'');
    }

    @IsTest
    private static void returned_wrappers_should_be_sorted_in_ascending_order(){
        // Test data setup
        List<Contact> fakeContacts = new List<Contact>();
        for(Integer i = 0; i < 5; i++){
            Contact c = new Contact(
                FirstName = 'test',
                LastName = 'test'+i
            );
            fakeContacts.add(c);
        } 
        
        List<Case> fakeCases = new List<Case>();
        for(Integer i = 0; i < 5; i++){
            Case c = new Case(
                Subject = 'test ' + i,
                description = 'test'
            );
            fakeCases.add(c);
        } 
        FakeSelector selector = new FakeSelector(fakeCases,fakeContacts);

        Map<String, Related_Records_Highlight_Panel_Setting__mdt> settings = generateSettingsMap();

        RelatedRecordsHighlightsController.settings = settings;
        RelatedRecordsHighlightsController.recordsSelector = selector;

        // Actual test
        Test.startTest();
        List<RelatedRecordsHighlightsController.HighlightItemWrapper> wrappers = RelatedRecordsHighlightsController.getHighlightItems('SomeId','AccountPage');
        Test.stopTest();

        // Asserts
        Assert.isTrue(wrappers[0].sortOrder < wrappers[1].sortOrder, 'The wrappers are not in the expected order');
        Assert.isTrue(wrappers[1].sortOrder < wrappers[2].sortOrder, 'The wrappers are not in the expected order');
        
    }

    private static Map<String,Related_Records_Highlight_Panel_Setting__mdt> generateSettingsMap(){

        Related_Records_Highlight_Panel_Setting__mdt casesSetting = new Related_Records_Highlight_Panel_Setting__mdt(
            Label = 'Cases',
            DeveloperName = 'Cases',
            SObject_Name__c = 'Case',
            Item_Name__c = 'Cases',
            Items_Query__c = 'Select Id,Subject,Type FROM Case WHERE Id = :recordId',
            Icon__c = 'standard:case',
            Sort_Order__c = 2,
            Table_Columns__c = 'Subject,Type',
            Component_Id__c = 'AccountPage'
        );

        Related_Records_Highlight_Panel_Setting__mdt contactsSetting = new Related_Records_Highlight_Panel_Setting__mdt(
            Label = 'Contacts',
            DeveloperName = 'Contacts',
            SObject_Name__c = 'Contact',
            Item_Name__c = 'Contacts',
            Items_Query__c = 'Select Id,Name,Title FROM Contact WHERE AccountId = :recordId',
            Icon__c = 'standard:contact',
            Sort_Order__c = 0,
            Table_Columns__c = 'Name,Title',
            Component_Id__c = 'AccountPage'
        );

        Related_Records_Highlight_Panel_Setting__mdt unhappyContactsSetting = new Related_Records_Highlight_Panel_Setting__mdt(
            Label = 'Unhappy Contacts',
            DeveloperName = 'Unhappy_Contacts',
            SObject_Name__c = 'Contact',
            Item_Name__c = 'Contacts',
            Items_Query__c = 'Select Id,Name,Title FROM Contact WHERE AccountId = :recordId',
            Icon__c = 'standard:contact',
            Sort_Order__c = 1,
            Table_Columns__c = 'Name,Title',
            Component_Id__c = 'AccountPage'
        );

        Map<String,Related_Records_Highlight_Panel_Setting__mdt> settingsMap = new Map<String,Related_Records_Highlight_Panel_Setting__mdt>{
            casesSetting.DeveloperName => casesSetting,
            contactsSetting.DeveloperName => contactsSetting,
            unhappyContactsSetting.DeveloperName => unhappyContactsSetting
        };
        return settingsMap; 
    }

    /**
     * A fake selector is used so that we can test with real fake data, and make the test org-agnostic.
    */
    private inherited sharing class FakeSelector extends RelatedRecordsHighlightsController.Selector {
        private List<Contact> theContactRecords;
        private List<Case> theCaseRecords;
        public FakeSelector(List<Case> theCases, List<Contact> theContacts){
            this.theCaseRecords = theCases;
            this.theContactRecords = theContacts;
        }

        public override List<SObject> getRecordsDynamic(String query,Map<String,String> binds,AccessLevel queryMode) {

            if(query.contains('Case')){
                return this.theCaseRecords;
            }

            if(query.contains('Contact')){
                return this.theContactRecords;
            }
            return new List<SObject>();
        }
    }
}
