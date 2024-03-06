export class Column {
    constructor(label, fieldName,type,typeAttributes){
        this.label = label;
        this.fieldName =  fieldName;
        if(type){
            this.type = type;
        }
        if(typeAttributes){
            this.typeAttributes = typeAttributes;
        }
    }
}