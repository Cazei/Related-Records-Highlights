import { createElement } from 'lwc';
import {setImmediate} from 'timers';
import getHighlightItems from '@salesforce/apex/RelatedRecordsHighlightsController.getHighlightItems';
import relatedRecordsHighlights from 'c/relatedRecordsHighlights';


jest.mock(
    '@salesforce/apex/RelatedRecordsHighlightsController.getHighlightItems',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

const HIGHLIGHT_ITEMS_SUCCESS = [
    {
      "fields": [
        { "label": "Subject", "name": "Subject" },
        { "label": "Status", "name": "Status" },
        { "label": "Case Type", "name": "Type" }
      ],
      "header": "Open Incidents",
      "icon": "standard:incident",
      "itemId": "HI1",
      "numOfItems": 1,
      "records": [
        {
          "Id": "5007Q0000090umVQAQ",
          "Subject": "Case about Laptops",
          "Status": "Working",
          "Type": "Incident"
        }
      ],
      "sortOrder": 1
    },
    {
      "fields": [
        { "label": "Full Name", "name": "Name" },
        { "label": "Title", "name": "Title" },
        { "label": "Email", "name": "Email" }
      ],
      "header": "Stale Contacts",
      "icon": "standard:contact",
      "itemId": "HI2",
      "numOfItems": 0,
      "records": [],
      "sortOrder": 2
    },
    {
      "fields": [
        { "label": "Full Name", "name": "Name" },
        { "label": "Title", "name": "Title" },
        { "label": "Email", "name": "Email" },
        { "label": "Business Phone", "name": "Phone" }
      ],
      "header": "Happy Contacts",
      "icon": "standard:contact",
      "itemId": "HI3",
      "numOfItems": 3,
      "records": [
        {
          "Id": "0037Q00001CGS1PQAX",
          "Name": "Franz Baptiste",
          "FirstName": "Franz",
          "Title": "Peasant"
        },
        {
          "Id": "0037Q00001CGS4XQAX",
          "Name": "José Pedroz",
          "FirstName": "José",
          "Title": "Burgher"
        },
        {
          "Id": "0037Q00001CGS4XQAX",
          "Name": "Franz Habsburg",
          "FirstName": "Anton",
          "Title": "Emperor"
        }
      ],
      "sortOrder": 3
    }
  ];


  function flushPromises() {
    // eslint-disable-next-line no-undef
    return new Promise(resolve => setImmediate(resolve));
}


describe('c-related-records-highlights', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('3 Highlight Items should be rendered', async () => {
        // Arrange

        getHighlightItems.mockResolvedValue(HIGHLIGHT_ITEMS_SUCCESS);

        const element = createElement('c-related-records-highlights', {
            is: relatedRecordsHighlights
        });
        element.recordId = 'fakeId';
        element.componentId = 'cmpId';

        // Act
        document.body.appendChild(element);

        return flushPromises().then(() => {

            const container = element.shadowRoot.querySelectorAll('.highlight-item-container');
            expect(container.length).toBe(1);
            
        }).then(() => {
            const details  = element.shadowRoot.querySelectorAll('.highlight-item');
            expect(details.length).toBe(3);
            
            const highlightItemLinks  = element.shadowRoot.querySelectorAll('.highlight-item-text-link');
            expect(highlightItemLinks.length).toBe(3);
            expect(highlightItemLinks[0].textContent).toBe('Open Incidents: 1');
            expect(highlightItemLinks[1].textContent).toBe('Stale Contacts: 0');
            expect(highlightItemLinks[2].textContent).toBe('Happy Contacts: 3');
        })
    });
});